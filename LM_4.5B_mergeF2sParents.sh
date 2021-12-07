#!/bin/bash --login
#SBATCH -o batch_LM_4.5_.%A.out.txt
#SBATCH -e batch_LM_4.5_.%A.err.txt
#SBATCH --ntasks=2
#SBATCH --time=12:00:00
#SBATCH --partition=htc

#Just sh it, won't take very long. Nice.

dir1="/scratch/b.bssc1d/Linkage_Mapping/LM_4.2_ParentCalls";
dir2="/scratch/b.bssc1d/Linkage_Mapping/QB_Raw";
progdir="/scratch/b.bssc1d/Linkage_Mapping";


#So let's get the parents for each cross into a nice file...

#QA
#parents="/home/b.bssc1d/scripts/Linkage_Mapping/QA_Parents.txt";
#name="QA_Parents"
#dir1="/scratch/b.bssc1d/6Pop_Resequencing";
#dir2="/scratch/b.bssc1d/Linkage_Mapping";
#QA_file="QA_Parents.merged.filtered3.bcf.gz";
#Parent_File="merged_snps_lowmem.filter2.bcf.gz";

#QB
#parents="/home/b.bssc1d/scripts/Linkage_Mapping/QA_Parents.txt";
#name="QB_Parents"
parent_file="/scratch/b.bssc1d/Linkage_Mapping/LM_4.2_ParentCalls/QB_Parents.merged.filt1.bcf.gz";
F2_file="/scratch/b.bssc1d/Linkage_Mapping/QB_Raw/QB.merged_snps_lowmem.filter2.bcf.gz";

module load bcftools
module load parallel

bcftools index -f $parent_file;
bcftools index -f $F2_file;

#bcftools index -f $dir2/$Parent_File;
bcftools isec -p $dir1/QBplusF2s $F2_file $parent_file;
bcftools view $dir1/QBplusF2s/0002.vcf -Ob -o $dir1/QBplusF2s/0002.bcf.gz;
bcftools view $dir1/QBplusF2s/0003.vcf -Ob -o $dir1/QBplusF2s/0003.bcf.gz;
bcftools index $dir1/QBplusF2s/0002.bcf.gz;
bcftools index $dir1/QBplusF2s/0003.bcf.gz;

bcftools merge $dir1/QBplusF2s/0002.bcf.gz $dir1/QBplusF2s/0003.bcf.gz > $dir1/QB_Parents_F2s.vcf && bcftools stats -s - $dir1/QB_Parents_F2s.vcf > $dir1/QB_Parents_F2s.vcf.stats;


