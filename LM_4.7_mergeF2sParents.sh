#!/bin/bash --login
#SBATCH -o /scratch/b.bssc1d/Linkage_Mapping/logs/batch_LM_4.7_%A.out.txt
#SBATCH -e /scratch/b.bssc1d/Linkage_Mapping/logs/batch_LM_4.7_%A.err.txt
#SBATCH --ntasks=1
#SBATCH --time=12:00:00
#SBATCH --partition=htc

#Run on the login node, only takes a second.
#NOTE: Check the $outdir/${cross}_ParentsPlusF2s_0.05/README.txt: make sure the megred files are what you want.

#Inputs: filtered combined parent vcf (from LM_4.5A)
#        filtered combined F2 vcf (from LM_4.6)
#Function: combines these files, taking only files with values in both
#parents and the F2s...
#Outputs : $outdir/${cross}_Parents_F2s.vcf
#        e.g. LM1_QA/QA_Parents_F2s.vcf

progdir="/scratch/b.bssc1d/Linkage_Mapping";

#cross="QA";
cross="QB";
#cross="QCE";

#Output of LM_4.5A
parent_file="/scratch/b.bssc1d/Linkage_Mapping/LM1_${cross}/${cross}.Parents.merged.filt1.bcf.gz";
#Output of LM_4.6
F2_file="/scratch/b.bssc1d/Linkage_Mapping/LM1_${cross}/${cross}.merged_snps_lowmem.filter2.vcf.0.05.bcf.gz";
outdir="/scratch/b.bssc1d/Linkage_Mapping/LM1_${cross}";

module load bcftools
module load parallel

bcftools index -f $parent_file;
bcftools index -f $F2_file;

#bcftools index -f $dir2/$Parent_File;
bcftools isec -p $outdir/${cross}_ParentsPlusF2s_0.05 $F2_file $parent_file;

bcftools view $outdir/${cross}_ParentsPlusF2s_0.05/0002.vcf -Ob -o $outdir/${cross}_ParentsPlusF2s_0.05/0002.bcf.gz;

bcftools view $outdir/${cross}_ParentsPlusF2s_0.05/0003.vcf -Ob -o $outdir/${cross}_ParentsPlusF2s_0.05/0003.bcf.gz;

bcftools index $outdir/${cross}_ParentsPlusF2s_0.05/0002.bcf.gz;
bcftools index $outdir/${cross}_ParentsPlusF2s_0.05/0003.bcf.gz;

bcftools merge $outdir/${cross}_ParentsPlusF2s_0.05/0002.bcf.gz $outdir/${cross}_ParentsPlusF2s_0.05/0003.bcf.gz > $outdir/${cross}_Parents_F2s.vcf && bcftools stats -s - $outdir/${cross}_Parents_F2s.vcf > $outdir/${cross}_Parents_F2s.vcf.stats;
