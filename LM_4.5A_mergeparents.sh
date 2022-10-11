#!/bin/bash --login
#SBATCH -o /scratch/b.bssc1d/Linkage_Mapping/logs/LM_4.5_%A.out.txt
#SBATCH -e /scratch/b.bssc1d/Linkage_Mapping/logs/LM_4.5_%A.err.txt
#SBATCH --ntasks=2
#SBATCH --time=12:00:00
#SBATCH --partition=highmem
#SBATCH --mem-per-cpu=15G;

#cross="QA";
cross="QB";
#cross="QCE";

#Output: $outdir/$cross.Parents.merged.filt1.bcf.gz:
#e.g. LM1_QA/QA.Parents.merged.filt1.bcf.gz

#Inputs
parents="/home/b.bssc1d/scripts/S1_QTL/${cross}_Parents.txt"; #Parent1Name\tParent1_R1.fq.gz\tParent1_R2.fq.gz
dir="/scratch/b.bssc1d/Linkage_Mapping/LM_4.2_ParentCalls"; #location of bcf.gz parent files
outdir="/scratch/b.bssc1d/Linkage_Mapping/LM1_${cross}"; 
progdir="/scratch/b.bssc1d/Linkage_Mapping"; #where you want the progress file
name="$cross.Parents";

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

#Gets the individual parent files from the previous steps...

bcftools index $P1;
bcftools index $P2;

#1 merge sets of SNPs
#Merges snps | gets rid of those with more than 20% missing data [for 2 parents, equivalent to both being genotyped | fills in tags like MAF etc. | calculates stats....

bcftools merge $P1 $P2 | bcftools view -i 'F_MISSING<0.2' | bcftools +fill-tags -Ob -o $outdir/$name.merged.bcf.gz -- && bcftools stats $outdir/$name.merged.bcf.gz > $outdir/$name.merged.stats && prog="${prog}2";

#Filter for biallelic SNps...
#gets biallelic snps | removes those with MAF=0 [i.e. 1/1 1/1] | includes only sites with at least one homozygote. This should leave sites that have 2 alleles, and at least one homozyote.

bcftools view -m2 -M2 $outdir/$name.merged.bcf.gz | bcftools filter -i 'INFO/MAF > 0' | bcftools view -g hom -Ob -o $outdir/$name.merged.filt1.bcf.gz && bcftools stats --af-bins -s - $outdir/$name.merged.filt1.bcf.gz > $outdir/$name.merged.filt1.stats && prog="${prog}3";

#Convert to vcf
bcftools view -Ov -o $outdir/$name.filt1.vcf $outdir/$name.merged.filt1.bcf.gz && prog="${prog}4";

if [[ $prog == "1234" ]]; then echo "$name $prog $dat LM_4.5A_Complete" >> $progdir/LM_4.5A_Progress.txt; else echo "$name $dat error code $prog" >> $progdir/LM_4.5A_Progress.txt; fi;
