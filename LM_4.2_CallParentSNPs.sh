#!/bin/bash --login
#SBATCH -o batch_LM_4.5_.%A.out.txt
#SBATCH -e batch_LM_4.5_.%A.err.txt
#SBATCH --ntasks=8
#SBATCH --time=1-12:00:00
#SBATCH --partition=highmem

#So this script will be taking the parent bam files (generated as part of the RS pipeline) and calling SNPs from these. 
#Should try and at least be reasonably confident in the calls.
#The bams ready to be called have the suffix .fix. 
#Can then filter the parents in the next script?


#11/09/21: Presumably this didn' run...
#21/11/21: Run this - saving the results to /scratch/b.bssc1d/Linkage_Mapping/LM_4.2_ParentCalls. So should change this for next time to deposit things into this folder.
#21/11/21: This appears to have finished. 

parent_list="/home/b.bssc1d/scripts/Linkage_Mapping/QTL_Parents.txt";
genome="/scratch/b.bssc1d/6Pop_Resequencing/TGS_GC_fmlrc.scaff_seqs.fa";
dat=$(date +%Y_%m_%d);

#So let's get the parents for each cross into a nice file...
dir1="/scratch/b.bssc1d/6Pop_Resequencing";
dir2="/scratch/b.bssc1d/Linkage_Mapping";
#Ok so I guess what we need to do first is...get the normalised things..
module load bcftools
module load parallel

call_snps() {
	stem="$1";
	dir1="$2";
	genome="$3";
	dir2="$4";
	nice="$5";
	name="$stem"_1.fq.gz_filtered.gz.trimmo.paired.gz.bwa.bam.rmdp;
	echo "Started $dat $stem" >> $dir2/LM_4.2_Progress.txt && bcftools mpileup -Ou -d 1000 --gvcf 7 --fasta-ref $genome $dir1/$name | bcftools call -Ob -m --gvcf 7 -f GQ -o $dir2/$name.$nice.DP7.bcf.gz && echo Finished $dat $name >> $dir2/LM_4.2_Progress.txt;
#	echo "Started $dat $stem >> $dir2/LM_4.2_Progress.txt && bcftools mpileup -Ou -d 1000 --gvcf 7 --fasta-ref $genome $dir1/$name | bcftools call -Ob -m --gvcf 7 -f GQ -o $dir2/$name.$nice.DP7.bcf.gz && echo Finished $dat $name >> $dir2/LM_4.2_Progress.txt";


}
export -f call_snps;

parallel --colsep "\t" -j 7 "call_snps {2} $dir1 $genome $dir2 {1}" :::: $parent_list;
