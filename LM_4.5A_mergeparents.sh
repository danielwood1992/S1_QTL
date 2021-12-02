#!/bin/bash --login
#SBATCH -o /scratch/b.bssc1d/Linkage_Mapping/logs/LM_4.5_%A.out.txt
#SBATCH -e /scratch/b.bssc1d/Linkage_Mapping/logs/LM_4.5_%A.err.txt
#SBATCH --ntasks=2
#SBATCH --time=12:00:00
#SBATCH --partition=highmem
#SBATCH --mem-per-cpu=15G;

#So let's get the parents for each cross into a nice file...

#parents="/home/b.bssc1d/scripts/Linkage_Mapping/QA_Parents.txt";
#name="QA_Parents"
parents="/home/b.bssc1d/scripts/S1_QTL/QB_Parents.txt";
dir="/scratch/b.bssc1d/Linkage_Mapping/LM_4.2_ParentCalls";
name="QB_Parents"

dat=$(date +%Y_%m_%d);

#Ok so I guess what we need to do first is...get the normalised things..
module load bcftools
module load parallel

prog=1;

P1_1=$(awk 'NR==1' $parents | cut -f1);
P1_2=$(awk 'NR==1' $parents | cut -f2);
P1="$dir/$P1_2.$P1_1.DP7.251121filt.bcf.gz";
ls $P1;

P2_1=$(awk 'NR==2' $parents | cut -f1);
P2_2=$(awk 'NR==2' $parents | cut -f2);
P2="$dir/$P2_2.$P2_1.DP7.251121filt.bcf.gz";
ls $P2;

bcftools index $P1;
bcftools index $P2;

#1 merge sets of SNPs
bcftools merge -Ob -o $dir/$name.merged.bcf.gz $P1 $P2 && prog="${prog}2";

#Filter for biallelic SNps...
bcftools view -Ob -o $dir/$name.merged.filt1.bcf.gz -m2 -M2 $dir/$name.merged.bcf.gz && prog="${prog}3";

#So then this does what...sets things with FMT/DP < 2 to 0, removes sites with one of the parents missing...
bcftools plugin setGT $dir/$name.merged.filt1.bcf.gz -- -t q -n . -i "FMT/DP < 2" | bcftools view -v snps -i 'F_MISSING<0.2' -Ob -o $dir/$name.merged.filt2.bcf.gz && prog="${prog}4";

#So here there has to be at least one homozygote: so either both homozygotes (but biallelic) or one het and one hom.
bcftools view $dir/$name.merged.filt2.bcf.gz --genotype hom -Ob -o $dir/$name.merged.filt3.bcf.gz && prog="${prog}5";

#Convert to vcf
bcftools view -Ov -o $dir/$name.filt3.vcf $dir/$name.merged.filt3.bcf.gz && prog="${prog}6";

if [[ $prog == "123456" ]]; then echo "$name LM_4.5A_Complete" >> $dir/LM_4.5A_Progress.txt; else echo "$name error code $prog" >> $dir/LM_4.5A_Progress.txt; fi;
