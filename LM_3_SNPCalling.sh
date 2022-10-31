#!/bin/bash --login
#SBATCH -o /scratch/b.bssc1d/Linkage_Mapping/logs/LM_3.%A.out.txt
#SBATCH -e /scratch/b.bssc1d/Linkage_Mapping/logs/LM_3.%A.err.txt
#SBATCH --ntasks=20
#SBATCH --time=12:00:00
#SBATCH --mail-user=daniel.wood@bangor.ac.uk
#SBATCH --mail-type=ALL 

module load parallel
module load samtools
module load picard/2.20.2
module load bcftools
module load vcftools

#QA - to do... - running 11/02/22
#dir="/scratch/b.bssc1d/Linkage_Mapping/LM1_QA"; #For QA
#qx_names="/home/b.bssc1d/scripts/S1_QTL/QA_SRA_files.txt";# new? 
#this_step="/scratch/b.bssc1d/Linkage_Mapping/QA_LM_2_Progress.txt";
#previous_step="/scratch/b.bssc1d/Linkage_Mapping/QA_LM1A_Progress.txt";

#QB - done pre 11/02/22
#dir="/scratch/b.bssc1d/Linkage_Mapping/QB_Raw";
#qx_names="/home/b.bssc1d/scripts/Linkage_Mapping/QB_Names_LGConly.txt.tocopy.txt"; #...from what you've done so far?
#this_step="/scratch/b.bssc1d/Linkage_Mapping/QB2_LM1A_Progress.txt";

#QB - with correct files this time... - running 11/02/22
#dir="/scratch/b.bssc1d/Linkage_Mapping/LM1A_QB";
#qx_names="/home/b.bssc1d/scripts/S1_QTL/QB_SRA_files.txt "; #From SRA...
#this_step="/scratch/b.bssc1d/Linkage_Mapping/QB_LM1A_Progress.txt";
#previous_step="/scratch/b.bssc1d/Linkage_Mapping/QB_LM1A_Progress.txt";

#QB (old)
#previous_step="$dir1/QB_LM1A_Progress.txt";
#this_step="$dir1/QB_LM_2_Progress.txt";
#qx_names="/home/b.bssc1d/scripts/Linkage_Mapping/QB_Names_LGConly.txt.tocopy.txt";
#dir="/scratch/b.bssc1d/Linkage_Mapping/QB_Raw"; #For QB

#cross="QA";
cross="QB"
#cross="QCE";

progdir="/scratch/b.bssc1d/Linkage_Mapping";
dir="/scratch/b.bssc1d/Linkage_Mapping/LM1_${cross}"; #For QCE
previous_step="/scratch/b.bssc1d/Linkage_Mapping/${cross}_LM_2_Progress.txt";
qx_names="/home/b.bssc1d/scripts/S1_QTL/${cross}_SRA_files.txt";

step_3A="$progdir/${cross}_LM_3A_Progress.txt";
step_3B="$progdir/${cross}_LM_3B_Progress.txt";
step_3C="$progdir/${cross}_LM_3C_Progress.txt";

echo $previous_step;

genome="/scratch/b.bssc1d/6Pop_Resequencing/TGS_GC_fmlrc.scaff_seqs.fa";
dat=$(date +%Y_%m_%d);

TMPDIR="/scratch/b.bssc1d/temp_parallel";
export TMPDIR;

perl ~/scripts/Linkage_Mapping/list_keepdelete.pl $qx_names $previous_step LM_2_Complete $step_3A Step_3A_Complete $dat.LM3AToDo

parallel --colsep "\t" -j 20 "echo Started {1} >> $step_3A && bcftools mpileup -Ou -d 1000 --gvcf 7 --fasta-ref $genome $dir/{1}.bwa.sorted.bam | bcftools call -Ob -m --gvcf 7 -f GQ -o $dir/{1}.bam.DP7.bcf.gz && echo {1} $dat Step_3A_Complete >> $step_3A" :::: $qx_names.kdel.$dat.LM3AToDo;

#Done: 06/01/22

perl ~/scripts/Linkage_Mapping/list_keepdelete.pl $qx_names $step_3A Step_3A_Complete $step_3B Step_3B_Complete $dat.LM3BToDo

parallel --colsep "\t" -j 20 "echo Started {1} >> $step_3B && bcftools norm -m +any --fasta-ref $genome $dir/{1}.bam.DP7.bcf.gz -Ob -o $dir/{1}.bam.DP7.bcf.gz.norm &&  bcftools index -f $dir/{1}.bam.DP7.bcf.gz.norm && echo {1} $dat Step_3B_Complete >> $step_3B" :::: $qx_names.kdel.$dat.LM3BToDo; 

#Done: 06/01/22

perl ~/scripts/Linkage_Mapping/list_keepdelete.pl $qx_names $step_3B Step_3B_Complete $step_3C Step_3C_Complete $dat.LM3CToDo

parallel --colsep "\t" -j 20 "echo Started $dat {1} >> $step_3C && bcftools +fill-tags $dir/{1}.bam.DP7.bcf.gz.norm -- -t all | bcftools filter -e 'QUAL<15' -Ob -o $dir/{1}.bam.DP7.bcf.gz.norm.q15 && bcftools index -f $dir/{1}.bam.DP7.bcf.gz.norm.q15 && bcftools stats $dir/{1}.bam.DP7.bcf.gz.norm.q15 > $dir/{1}.bam.DP7.bcf.gz.norm.q15.stats &&  echo {1} $dat Step_3C_Complete >> $step_3C" :::: $qx_names.kdel.$dat.LM3CToDo; 

#So you just get rid of the QUAL<15 ones here. 
#What did we learn from that other SNP calling can't remember...

#Done: 06/01/22 

echo "End of script";
