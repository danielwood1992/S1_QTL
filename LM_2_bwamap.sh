#!/bin/bash --login
#SBATCH -o /scratch/b.bssc1d/Linkage_Mapping/logs/LM_2.%A.out.txt
#SBATCH -e /scratch/b.bssc1d/Linkage_Mapping/logs/LM_2.%A.err.txt
#SBATCH --ntasks=30
#SBATCH --time=10:00:00
#SBATCH --mem-per-cpu=4G
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

#Old stuff...

#I think this should now work?

#QB - done pre 11/02/22
#dir="/scratch/b.bssc1d/Linkage_Mapping/QB_Raw";
#qx_names="/home/b.bssc1d/scripts/Linkage_Mapping/QB_Names_LGConly.txt.tocopy.txt"; #...from what you've done so far?
#this_step="/scratch/b.bssc1d/Linkage_Mapping/QB2_LM1A_Progress.txt";

#cross="QA";
cross="QB";
#cross="QCE";

dir="/scratch/b.bssc1d/Linkage_Mapping/LM1_${cross}";
this_step="/scratch/b.bssc1d/Linkage_Mapping/${cross}_LM_2_Progress.txt";
qx_names="/home/b.bssc1d/scripts/S1_QTL/${cross}_SRA_files.txt";
previous_step="/scratch/b.bssc1d/Linkage_Mapping/${cross}_LM1A_Progress.txt";

perl ~/scripts/Linkage_Mapping/list_keepdelete.pl $qx_names $previous_step Step_LM_1A_Complete $this_step LM_2_Complete $dat.LM2ToDo;
names=$qx_names.kdel.$dat.LM2ToDo; 

#Test
##names=$qx_names;
#echo "parallel --colsep "\t" -j 10 --delay 0.2 echo {1} $dat Started >> $this_step && bwa mem -t 2 $genome $dir/{1}_filtered.trimmo.paired.gz | samtools fixmate -m - -  | samtools sort - | samtools view -q 20 -o $dir/{1}.bwa.sorted.bam - && samtools index $dir/{1}.bwa.sorted.bam && echo {1} $dat LM_2_Complete >> $this_step && echo done" :::: $names; 

TMPDIR="/scratch/b.bssc1d/temp_parallel";
export TMPDIR;
parallel --colsep "\t" -j 15 --delay 0.2 --tmpdir /scratch/b.bssc1d/ "echo {1} $dat Started >> $this_step && bwa mem -t 2 $genome $dir/{1}_filtered.trimmo.paired.gz | samtools fixmate -m - -  | samtools sort - | samtools view -q 20 -o $dir/{1}.bwa.sorted.bam - && samtools index $dir/{1}.bwa.sorted.bam && echo {1} $dat LM_2_Complete >> $this_step && echo done" :::: $names; 
