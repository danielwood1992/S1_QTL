##JOB_NUM##

#For example...

reusable_pipeline="/home/b.bssc1d/scripts/reusable_slurm_pipeline";
names="/home/b.bssc1d/scripts/Linkage_Mapping/QTL_Parents.txt";
progdir="/scratch/b.bssc1d/Linkage_Mapping";

dat=$(date +%Y_%m_%d);

perl $reusable_pipeline/list_keepdelete.pl $names $progdir/LM_4.2_Progress.txt LM_4.2_Complete $progdir/LM_4.3_Progress.txt LM_4.3_Complete $dat.LM_4.2ToDo

names=$names.kdel.$dat.LM_4.2ToDo;

ARRAY_NUM=$(cat $names | wc -l);
ARRAY_NUM="$ARRAY_NUM $names";

echo $ARRAY_NUM;

##ARRAY_BIT##
#!/bin/bash --login
#SBATCH --ntasks=1
#SBATCH --time=12:00:00
#SBATCH --partition=highmem
#SBATCH --mem-per-cpu=10G
#SBATCH --array=?
#SBATCH -o /scratch/b.bssc1d/Linkage_Mapping/logs/LM_4.3-%A_%a-%J.out
#SBATCH -e /scratch/b.bssc1d/Linkage_Mapping/logs/LM_4.3-%A_%a-%J.err

file_list=$1;
nicename=$(sed -n "${SLURM_ARRAY_TASKID}p" $file_list | cut -f1);
name=$(sed -n "${SLURM_ARRAY_TASKID}p" $file_list | cut -f2);

progdir="/scratch/b.bssc1d/Linkage_Mapping";
dir="/scratch/b.bssc1d/Linkage_Mapping/LM_4.2_ParentCalls";

this_step="$progdir/LM_4.3_Progress.txt"

echo "Started $dat $nicename" >> $this_step &&
	      bcftools plugin setGT $dir/$name.$nicename.DP7.bcf.gz -- -t q -n . -i "FMT/DP<7 | FMT/GQ<20 | QUAL<15 | (FMT/GQ > 0 & ((DP4[2]+DP4[3])/(DP4[0]+DP4[1])<0.33333))"  |  bcftools view -i 'F_MISSING<0.2' -m2 -M2 -v snps  -Ob -o $dir/$name.$nicename.DP7.251121filt.bcf.gz &&
      echo "$nicename $dat LM_4.3_Complete" >> $this_step;
