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

#How many SNPs?
function check_snps {
	module load bcftools;
	bcf_file=$1;
	echo "$bcf_file number of SNPs...";
	grep "^SN.*number of SNPs" $bcf_file.stats | cut -f4;
	echo "$bcf_file number of scaffolds...";
	bcftools view $bcf_file | grep -v '^#' | cut -f1 | sort | uniq | wc -l;
}
export -f check_snps;

#grep "^SN.*number of SNPs" $raw_grandparent_vcf.LM4.1C.bcf.gz.stats | cut -f4;
#How many scaffolds?
#echo "$raw_grandparent_vcf.LM4.1C.bcf.gz number of scaffolds";
#bcftools view $raw_grandparent_vcf.LM4.1C.bcf.gz | grep -v '^#' | cut -f1 | sort | uniq | wc -l;

#########################################
# Section 1: Genotyped F2 questions...
#########################################

#So want to I guess do... 

raw_F2_vcf="$dir2/$name.merged_snps.vcf";

#1 Get SNPs that are present in 80% of samples in raw files, do things on this.
if grep -q "LM_4.1A_Complete" $this_step; 
	then echo "LM_4.1A_Complete";
else 
	echo "$name Starting 4.1A" >> $this_step && bcftools view -i 'F_MISSING<0.2' -m2 -M2 -v snps -Ob -o $raw_F2_vcf.LM4.1A.bcf.gz $raw_F2_vcf && bcftools stats -s - $raw_F2_vcf.LM4.1A.bcf.gz > $raw_F2_vcf.LM4.1A.bcf.gz.stats && echo "$name LM_4.1A_Complete" >> $this_step;
fi;

check_snps $raw_F2_vcf.LM4.1A.bcf.gz;

######

#Do the same for the filtered files...
filtered_F2_vcf="$dir2/QB.merged_snps_lowmem.filter2.bcf.gz";
if grep -q "LM_4.1B_Complete" $this_step; 
	then echo "LM_4.1B_Complete";
else 
	echo "$name Starting 4.1B" >> $this_step && bcftools view -i 'F_MISSING<0.2' -m2 -M2 -v snps -Ob -o $filtered_F2_vcf.LM4.1B.bcf.gz $filtered_F2_vcf && bcftools stats -s - $filtered_F2_vcf.LM4.1B.bcf.gz > $filtered_F2_vcf.LM4.1B.bcf.gz.stats && echo "$name LM_4.1B_Complete" >> $this_step;
fi;

check_snps $filtered_F2_vcf.LM4.1B.bcf.gz;

#######################################
# Section 2: Grandparent SNPs...
#######################################


#Generated from...alt_S1B files...
raw_grandparent_vcf="/scratch/b.bssc1d/Linkage_Mapping/LM_4.2_ParentCalls/alt_S1B.RAW.QB_Parents.merged.bcf.gz";
echo $raw_grandparent_vcf;
ls $raw_grandparent_vcf;
if grep -q "LM_4.1C_Complete" $this_step; 
	then echo "LM_4.1C_Complete";
else 
	echo "$name Starting 4.1C" >> $this_step && bcftools view -i 'F_MISSING<0.2' -m2 -M2 -v snps -Ob -o $raw_grandparent_vcf.LM4.1C.bcf.gz $raw_grandparent_vcf && bcftools stats -s - $raw_grandparent_vcf.LM4.1C.bcf.gz > $raw_grandparent_vcf.LM4.1C.bcf.gz.stats && echo "$name LM_4.1C_Complete" >> $this_step;
fi;

check_snps $raw_grandparent_vcf.LM4.1C.bcf.gz;

#####

filtered_grandparent_vcf="/scratch/b.bssc1d/Linkage_Mapping/LM_4.2_ParentCalls/QB_Parents.merged.filt1.bcf.gz";

if grep -q "LM_4.1D_Complete" $this_step; 
	then echo "LM_4.1D_Complete";
else 
	echo "$name Starting 4.1D" >> $this_step && bcftools view -i 'F_MISSING<0.2' -m2 -M2 -v snps -Ob -o $filtered_grandparent_vcf.LM4.1D.bcf.gz $filtered_grandparent_vcf && bcftools stats -s - $filtered_grandparent_vcf.LM4.1D.bcf.gz > $filtered_grandparent_vcf.LM4.1D.bcf.gz.stats && echo "$name LM_4.1C_Complete" >> $this_step;
fi;

check_snps $filtered_grandparent_vcf.LM4.1D.bcf.gz;

echo "$filtered_grandparent_vcf.LM4.1D.bcf.gz number of SNPs";
grep "^SN.*number of SNPs" $filtered_grandparent_vcf.LM4.1D.bcf.gz.stats | cut -f4;
#How many scaffolds?
echo "$filtered_grandparent_vcf.LM4.1D.bcf.gz number of scaffolds";
bcftools view $filtered_grandparent_vcf.LM4.1D.bcf.gz | grep -v '^#' | cut -f1 | sort | uniq | wc -l;

#######################
#3 When we merge these files?
#######################

#Note - I think we have to filter semi-sensibly on grandparents.
merged_grandparentraw="/scratch/b.bssc1d/Linkage_Mapping/LM_4.2_ParentCalls/alt_S1B_QB_Parents_F2s.vcf";
#Stats already generated as part of previous SNPs.
check_snps $merged_grandparentraw;

merged_grandparentfiltered="/scratch/b.bssc1d/Linkage_Mapping/LM_4.2_ParentCalls/QB_Parents_F2s.vcf";
check_snps $merged_grandparentfiltered;

