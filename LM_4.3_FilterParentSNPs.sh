##JOB_NUM##

#For example...

reusable_pipeline="/home/b.bssc1d/scripts/reusable_slurm_pipeline";
names="/home/b.bssc1d/scripts/Linkage_Mapping/QTL_Parents.txt";
progdir="/scratch/b.bssc1d/Linkage_Mapping";

dat=$(date +%Y_%m_%d);

perl $reusable_pipeline/list_keepdelete.pl $names $progdir/LM_4.2_Progress.txt LM_4.2_Complete $progdir/LM_4.3_Progress.txt LM_4.3_Complete $dat.LM_4.3ToDo

names=$names.kdel.$dat.LM_4.3ToDo;

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

module load bcftools;

#tests
#file_list=$names;
#nicename=$(sed -n "1p" $file_list | cut -f1);
#name=$(sed -n "1p" $file_list | cut -f2);

#0 Get names/setup
echo "slurm ${SLURM_ARRAY_TASK_ID}";
file_list=$1;
echo "file list $file_list";
nicename=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $file_list | cut -f1);
name=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $file_list | cut -f2);
echo "nice name $nicename";
echo "name $name";

genome="/scratch/b.bssc1d/6Pop_Resequencing/TGS_GC_fmlrc.scaff_seqs.fa";
progdir="/scratch/b.bssc1d/Linkage_Mapping";
dir="/scratch/b.bssc1d/Linkage_Mapping/LM_4.2_ParentCalls";
dat=$(date +%Y_%m_%d);

bcf_name="${name}_1.fq.gz_filtered.gz.trimmo.paired.gz.bwa.bam.rmdp.${nicename}.DP7.bcf.gz";

echo "Started $dat $nicename" >> $progdir/LM_4.3_Progress.txt; 
prog=1;

#1 Left normalise
#need to add genome...
bcftools norm -m +any --fasta-ref $genome $dir/$bcf_name -Ob -o $dir/$bcf_name.norm && prog="${prog}2"; 

#2 Filter
bcftools filter -e 'FMT/DP<4 | FMT/GQ<15 | QUAL<15 | FMT/DP>15 | (FMT/GQ > 0 & ((DP4[2]+DP4[3])/(DP4[0]+DP4[1])<0.33333))' -Ob -o $dir/$name.$nicename.DP7.251121filt.bcf.gz $dir/$bcf_name.norm && prog="${prog}3";  

#3 Calculate stats...
bcftools stats $dir/$name.$nicename.DP7.251121filt.bcf.gz > $dir/$name.$nicename.DP7.251121filt.stats && prog="${prog}4";

#4 Index
bcftools index $dir/$name.$nicename.DP7.251121filt.bcf.gz && prog="${prog}5";

#5 Report progress
if [[ $prog == "12345" ]]; then echo "$name $prog $dat LM_4.3_Complete" >> $progdir/LM_4.3_Progress.txt; else echo "$name $dat error code $prog" >> $progdir/LM_4.3_Progress.txt; fi;

