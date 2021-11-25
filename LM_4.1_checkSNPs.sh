#!/bin/bash --login
#SBATCH -o /scratch/b.bssc1d/Linkage_Mapping/logs/batch_LM_4.1.%A.out.txt
#SBATCH -e /scratch/b.bssc1d/Linkage_Mapping/logs/batch_LM_4.1.%A.err.txt
#SBATCH --ntasks=1
#SBATCH --time=12:00:00
#SBATCH --mail-user=daniel.wood@bangor.ac.uk
#SBATCH --mail-type=ALL 

#Here I would like to look at the number of SNPs in the merged files before and after filtering, paticularly...
#a) The mean depth per site
#b) The proportion of ref, alt and heterozygotes present.
#c) And then compare this to i) the filtered sites and ii) what this means for the parents...

#Looks to be a bit of a pain running this in parallel, so I will just do all the jobs in parallel instead...
module load parallel
module load samtools
module load picard/2.20.2
module load bcftools
module load vcftools
module load anaconda/2020.02

source ~/.bashrc;
source activate;
source activate /scratch/b.bssc1d/plot_vcfstats

dat=$(date +%Y_%m_%d);

dir1="/scratch/b.bssc1d/Linkage_Mapping"; #For QB

name="QB";
dir2="/scratch/b.bssc1d/Linkage_Mapping/QB_Raw"; #For QB

this_step="$dir1/QB_LM_4.1_Progress.txt";
qx_names="/home/b.bssc1d/scripts/Linkage_Mapping/QB_Names_LGConly.txt.tocopy.txt";

raw_vcf="$dir2/$name.merged_snps.vcf";

#So want to I guess do... 

if grep -q "$name LM_4.1_Complete" $this_step; 
	then echo "LM_4.1_Complete";
else 
	echo "$name Starting 4.1" >> $this_step && bcftools stats -s - $raw_vcf > $raw_vcf.stats && echo "$name LM_4.1_Complete" >> $this_step;
fi;

#Get ones that are present in 80% of samples, do things on this.
if grep -q "LM_4.2_Complete" $this_step; 
	then echo "LM_4.2_Complete";
else 
	echo "$name Starting 4.2" >> $this_step && bcftools view -i 'F_MISSING<0.2' -m2 -M2 -v snps -Ob -o $raw_vcf.LM4.2.bcf.gz $raw_vcf && bcftools stats -s - $raw_vcf.LM4.2.bcf.gz > $raw_vcf.LM4.2.bcf.gz.stats && echo "$name LM_4.2_Complete" >> $this_step;
fi;


if grep -q "LM_4.3_Complete" $this_step; 
	then echo "LM_4.3_Complete";
else 
	echo "$name Starting 4.3" >> $this_step && bcftools plugin setGT $raw_vcf -- -t q -n . -i "FMT/DP<7 | FMT/GQ < 20 | QUAL <15 | (FMT/GQ > 0 & ((DP4[2]+DP4[3])/(DP4[0]+DP4[1]) <0.3333))" | bcftools view -i 'F_MISSING<0.2' -m2 -M2 -v snps -Ob -o $raw_vcf.LM.4.3.bcf.gz && bcftools stats -s - $raw_vcf.LM.4.3.bcf.gz > $raw_vcf.LM4.3.bcf.gz.stats && echo "$name LM_4.3_Complete" >> $this_step;
fi;

#Filter how you thought would be sensible...

