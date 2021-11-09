#!/bin/bash --login
#SBATCH -o batch_LM_2.%A.out.txt
#SBATCH -e batch_LM_2.%A.err.txt
#SBATCH --ntasks=20
#SBATCH --time=23:00:00
#SBATCH --partition=htc
#SBATCH --mail-user=daniel.wood@bangor.ac.uk
#SBATCH --mail-type=ALL 

#So here I will call SNPs using bcftools, try and do most of the analysis as this all needs to be done mega quickly...

#Looks to be a bit of a pain running this in parallel, so I will just do all the jobs in parallel instead...
module load parallel
module load samtools
module load picard/2.20.2
module load bcftools
module load vcftools

genome="/scratch/b.bssc1d/6Pop_Resequencing/TGS_GC_fmlrc.scaff_seqs.fa";
dat=$(date +%Y_%m_%d);

dir1="/scratch/b.bssc1d/Cleaned_Reads_v2";
#dir2="/scratch/b.bssc1d/Linkage_Mapping"; #For QA
dir2="/scratch/b.bssc1d/Linkage_Mapping/QB_Raw"; #For QB
#read_list="/scratch/b.bssc1d/Linkage_Mapping/sam_list";

previous_step="$dir2/QB_LM_2_Progress.txt";
step_3A="$dir2/QB_LM_3A_Progress.txt";
qx_names="/home/b.bssc1d/scripts/Linkage_Mapping/QB_Names_LGConly.txt.tocopy.txt";

perl ~/scripts/Linkage_Mapping/list_keepdelete.pl $qx_names $previous_step Step_2_Complete $step_3A Step_3A_Complete $dat.LM3AToDo

parallel --colsep "\t" -j 19 "echo Started {1} >> $step_3A && bcftools mpileup -Ou -d 1000 --gvcf 7 --fasta-ref $genome $dir2/{1}.bwa.sorted.bam | bcftools call -Ob -m --gvcf 7 -f GQ -o $dir2/{1}.bam.DP7.bcf.gz && echo {1} $dat Step_3A_Complete >> $step_3A" :::: $qx_names.kdel.$dat.LM3AToDo;

step_3B="$dir2/QB_LM_3B_Progress.txt";
perl ~/scripts/Linkage_Mapping/list_keepdelete.pl $qx_names $step_3A Step_3A_Complete $step_3B Step_3B_Complete $dat.LM3BToDo

parallel --colsep "\t" -j 19 "echo Started {1} >> $step_3B && bcftools norm -m +any --fasta-ref $genome $dir2/{1}.bam.DP7.bcf.gz -Ob -o $dir2/{1}.bam.DP7.bcf.gz.norm &&  bcftools index -f $dir2/{1}.bam.DP7.bcf.gz.norm && echo {1} $dat Step_3B_Complete >> $step_3B" :::: $qx_names.kdel.$dat.LM3BToDo;
