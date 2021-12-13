#!/bin/bash --login
#SBATCH -o batch_LM_4.5_.%A.out.txt
#SBATCH -e batch_LM_4.5_.%A.err.txt
#SBATCH --ntasks=12
#SBATCH --time=12:00:00
#SBATCH --partition=highmem
module load parallel;
dir="/scratch/b.bssc1d/Linkage_Mapping";
dir2="/scratch/b.bssc1d/Linkage_Mapping/LM_6_LepMap3/QB"
ped="QA_Parents_Offspring.vcf.ped";
vcf="QA_Parents_Offspring.vcf";

#So for the first 12 chromosomes (or however many you've got...)
#Should create 10 starting files based on your contigs, and then run OrderMarkers2 on these. You can then summarise the best for each one.

#First need to get your map that you're happy with (see previous script).

map=$dir/$ped.parentcall.map.lod.31.final
map=$dir2/"QB_Parents_F2s.vcf.ped.parentcall.map.lod.48.final.joinsingles2all";
chrom_num=13;

array=($(seq 1 1 $chrom_num));
#Note - shell variables are not visible to child processes unless they are exported.

#export dir="/scratch/b.bssc1d/Linkage_Mapping";
export ped="QA_Parents_Offspring.vcf.ped";
export vcf="QA_Parents_Offspring.vcf";
export dat=$(date +Y%_%m_%d);
#You could probably further parallelise this but it doesn't really take that long. 
truncate -s 0 $dir/OrderSummary.$dat.txt; 
estchrom () {
	echo $1; 

	for i in {1..10}; 
		do echo $i;  echo $1;
		echo $1; perl ~/scripts/Linkage_Mapping/LM_6C_order2markers.pl $dir/$ped.parentcall.call.map.lod.31.final $dir/$ped.parentcall.call $1 $i; 
		java -cp ~/LepMap3/bin OrderMarkers2 data=$dir/$ped.parentcall.call map=$dir/$ped.parentcall.call.map.lod.31.final grandparentPhase=1 chromosome=$1 numThreads=1 evaluateOrder=$dir/$ped.parentcall.call.map.lod.31.final.LG.$1.$i outputPhasedData=2> $dir/$ped.parentcall.call.map.lod.31.final.LG.$1.$i.order; 
		likeline=$(grep likelihood $dir/$ped.parentcall.call.map.lod.31.final.LG.$1.$i.order); 
		likeline=${likeline/*= /}; #Rempves everything up to the equals...
		echo "$1\t$dir/$ped.parentcall.call.map.lod.31.final.LG.$1.$i.order\t$likeline" >> $dir/OrderSummary.$dat.txt;
	done;
} 
export -f estchrom
parallel -j 1 --delay 0.2 "estchrom {1}" ::: ${array[@]};
#perl ~/scripts/Linkage_Mapping/LM_7B_BestOrderPerChrom.pl $dir/OrderSummary.$dat.txt;


