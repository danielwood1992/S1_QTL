#!/bin/bash --login
#SBATCH -o /scratch/b.bssc1d/Linkage_Mapping/logs/LM_4.%A.out.txt
#SBATCH -e /scratch/b.bssc1d/Linkage_Mapping/logs/LM_4.%A.err.txt
#SBATCH --ntasks=15
#SBATHC --mem-per-cpu=4G
#SBATCH --time=12:00:00
#SBATCH --mail-user=daniel.wood@bangor.ac.uk
#SBATCH --mail-type=ALL 

#So here I will call SNPs using bcftools, try and do most of the analysis as this all needs to be done mega quickly...

#Looks to be a bit of a pain running this in parallel, so I will just do all the jobs in parallel instead...
module load parallel
module load samtools
module load picard/2.20.2
module load bcftools
module load vcftools

#What a gross script. Update this at some point.

genome="/scratch/b.bssc1d/6Pop_Resequencing/TGS_GC_fmlrc.scaff_seqs.fa";
dat=$(date +%Y_%m_%d);

#dir1="/scratch/b.bssc1d/Linkage_Mapping"; #For QA
#dir="/scratch/b.bssc1d/Linkage_Mapping/QB_Raw"; #For QB

#previous_step="$dir1/QB_LM_3C_Progress.txt";
#this_step="$dir1/QB_LM_4_Progress.txt";
#16/02/22 - This is the old file, which contains 10 duplicates...
#qx_names="/home/b.bssc1d/scripts/Linkage_Mapping/QB_Names_LGConly.txt.tocopy.txt";

#So let's modify to use the new files...

#cross="QA";
cross="QB";
#cross="QCE";

#So we would need...what...a list of stuff? 
qx_names="/home/b.bssc1d/scripts/S1_QTL/${cross}_SRA_files.txt";
progdir="/scratch/b.bssc1d/Linkage_Mapping";
dir="/scratch/b.bssc1d/Linkage_Mapping/LM1_${cross}"; #Ok then.
this_step="$progdir/${cross}_LM_4.Progress.txt";

#1 Creating list of bcfs to pass to merge...
truncate -s 0 $dir/$cross.bcfs_tomerge.$dat;
before="$dir/";
after=".bam.DP7.bcf.gz.norm.q15";
awk -v before=$before -v after=$after '{print before$1after}' $qx_names > $dir/$cross.bcfs_tomerge.$dat;

#while read file; do echo $dir/$file.bam.DP7.bcf.gz.norm.q15;  done < $qx_names;

#2 doing the merging...
echo "Started $dat $cross" >> $this_step && bcftools merge --gvcf $genome --threads 15 -Ob -o $dir/$cross.merged_snps.bcf.gz -l $dir/$cross.bcfs_tomerge.$dat && bcftools view $dir/$cross.merged_snps.bcf.gz -Ov -o $dir/$cross.merged_snps.vcf && bcftools +fill-tags $dir/$cross.merged_snps.bcf.gz -- -t all | bcftools plugin setGT $dir/$cross.merged_snps.vcf -- -t q -n . -i "FMT/DP<7 | FMT/GQ<20 | QUAL<15 | (FMT/GQ > 0 & ((DP4[2]+DP4[3])/(DP4[0]+DP4[1])<0.33333))"  |  bcftools view -i 'F_MISSING<0.05' -m2 -M2 -v snps  -Ob -o $dir/$cross.merged_snps_lowmem.filter2.bcf.gz && bcftools view -Ov -o $dir/$cross.merged_snps_lowmem.filter2.vcf $dir/$cross.merged_snps_lowmem.filter2.bcf.gz && echo "$cross $dat Finished" >> $this_step;

#Note: bcftools plugin setGT $vcf -- -t q -n . -i "whatever"
# -- ; put options for plugin after this
# -t q -n . -i : repalaces sites that match the immediately following critera with missing data...
#Note: for now, I think there'll probably be enough coverage/other data to exclude the deph criteria? Not sure what the mean depth of these guys is?
#Maybe I am excluding too many sites. I'm not really sure what the right thing is to do here. 
#I guess we don't want to end up excluding loads of heterozygotes, but we do want them to be called correctly as heterozygotes?
#Surely the coverage will be sufficiently high that this shouldnt' matter? Let's do it; and then try again without it and check if it makes a difference...
#Well let's see how this goes...

