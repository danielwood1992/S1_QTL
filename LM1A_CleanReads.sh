#!/bin/bash --login
#SBATCH --partition=htc
#SBATCH --ntasks=20
#SBATCH --time=1-12:00:00
#SBATCH -o %A.out.txt
#SBATCH -e %A.err.txt
#SBATCH --mail-user=daniel.wood@bangor.ac.uk
#SBATCH --mail-type=ALL

export PERL5LIB=~/perl5/lib/perl5/
module add FastQC/0.11.8
module add trimmomatic/0.39
module load parallel

#woof
#Before you start, unzip stuff using for file in *bz2; do bzip2 -d $file; done
#Make file list using echo $PWD/*fastq >> qx_names_file

dat=$(date +%Y_%m_%d);
slurm_scripts="/home/b.bssc1d/scripts/Linkage_Mapping";
#dir="/scratch/b.bssc1d/Linkage_Mapping"; #For QA
dir="/scratch/b.bssc1d/Linkage_Mapping/QB_Raw"; #For QA
this_step="/scratch/b.bssc1d/Linkage_Mapping/QB_Raw/QB_LM1A_Progress.txt";
###qx_names="/scratch/b.bssc1d/Linkage_Mapping/QA_Names_Path.txt"; #QA
qx_names="/home/b.bssc1d/scripts/Linkage_Mapping/QB_Names_LGConly.txt.tocopy.txt";

perl $slurm_scripts/list_delete.pl $qx_names $this_step Step_1_Complete $dat.LM1ToDo

parallel -N 1 -j 19 --delay 0.2 "echo {} $dat Started >> $this_step && bzip2 -d $dir/{}.bz2; perl ~/bin/NGSQCToolkit_v2.3.3/QC/IlluQC.pl -se $dir/{} 1 A -l 70 -s 20 -t 1 -z g -o $dir && java -jar $TRIMMOMATIC SE $dir/{/}_filtered.gz $dir/{/}_filtered.trimmo.paired.gz SLIDINGWINDOW:4:15 MINLEN:70 && echo {} $dat Step_1_Complete >> $this_step" :::: $qx_names.$dat.LM1ToDo
