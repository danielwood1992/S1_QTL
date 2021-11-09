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
module load bwa

genome="/scratch/b.bssc1d/6Pop_Resequencing/TGS_GC_fmlrc.scaff_seqs.fa";
dat=$(date +%Y_%m_%d);

dir1="/scratch/b.bssc1d/Cleaned_Reads_v2";
#dir2="/scratch/b.bssc1d/Linkage_Mapping"; #For QA
dir2="/scratch/b.bssc1d/Linkage_Mapping/QB_Raw"; #For QB

#read_list="/scratch/b.bssc1d/Linkage_Mapping/sam_list";

previous_step="$dir2/QB_LM1A_Progress.txt";
this_step="$dir2/QB_LM_2_Progress.txt";
qx_names="/home/b.bssc1d/scripts/Linkage_Mapping/QB_Names_LGConly.txt.tocopy.txt";

perl ~/scripts/Linkage_Mapping/list_keepdelete.pl $qx_names $previous_step Step_1_Complete $this_step Step_2_Complete $dat.LM2ToDo;

parallel --colsep "\t" -j 10 --delay 0.2 "echo {1} $dat Started >> $this_step && bwa mem -t 2 $genome $dir2/{1}_filtered.trimmo.paired.gz | samtools sort -o $dir2/{1}.bwa.sorted.bam && samtools index $dir2/{1}.bwa.sorted.bam && echo {1} $dat Step_2_Complete >> $this_step" :::: $qx_names.kdel.$dat.LM2ToDo; 



