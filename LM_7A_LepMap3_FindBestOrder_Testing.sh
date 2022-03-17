#!/bin/bash --login
#SBATCH -o /scratch/b.bssc1d/Linkage_Mapping/LM_7A_.%A.out.txt
#SBATCH -e /scratch/b.bssc1d/Linkage_Mapping/LM_7A_.%A.err.txt
#SBATCH --ntasks=6
#SBATCH --time=12:00:00
module load parallel;
dir="/scratch/b.bssc1d/Linkage_Mapping/LM_6_LepMap3/QB";

#QA
#dir="/scratch/b.bssc1d/Linkage_Mapping";
#ped="QA_Parents_Offspring.vcf.ped";
#vcf="QA_Parents_Offspring.vcf";

#QB
ped="QB_Parents_F2s.vcf.ped";
vcf="QB_Parents_F2s.vcf";

#So for the first 12 chromosomes (or however many you've got...)
#Should create 10 starting files based on your contigs, and then run OrderMarkers2 on these. You can then summarise the best for each one.

#First need to get your map that you're happy with (see previous script).

#map=$dir/$ped.parentcall.map.lod.31.final
map=$dir/"QB_Parents_F2s.vcf.ped.parentcall.LM_6B.A.lim35";
parentcall=$dir/"QB_Parents_F2s.vcf.ped.parentcall";
chrom_num=12;

array=($(seq 1 1 $chrom_num));
#Note - shell variables are not visible to child processes unless they are exported.

#QA
#export dir="whatever/it/was";
#export ped="QA_Parents_Offspring.vcf.ped";
#export vcf="QA_Parents_Offspring.vcf";
#export dat=$(date +Y%_%m_%d);

#QB
dat=$(date "+Y%_%m_%d");

export dir=$dir;
export ped=$ped;
export vcf=$vcf;
export dat=$dat;
export map=$map;
export parentcall=$parentcall;

ls $map;

#You could probably further parallelise this but it doesn't really take that long. 
truncate -s 0 $dir/OrderSummary.$dat.txt; 
#Ok so...
estchrom () {
	echo $1; #This is the chromosomes...

	for i in {1..1}; 
		do echo $i;  echo $1;
		echo $1; perl ~/scripts/Linkage_Mapping/LM_6C_order2markers.pl $map $parentcall $1 $i; 
		java -cp ~/LepMap3/bin OrderMarkers2 data=$parentcall map=$map grandparentPhase=1 chromosome=$1 numThreads=1 evaluateOrder=$map.LG.$1.$i outputPhasedData=2 informativeMask=3  interference1=1 interference2=1 sexAveraged=1 > $map.LG.MUH.$1.$i.order;
		awk -f ~/LepMap3/map2genotypes.awk $map.LG.MUH.$1.$i.order > $map.LG.MUH.$1.$i.order.postawk;
		likeline=$(grep likelihood $map.LG.MUH.$1.$i.order); 
		likeline=${likeline/*= /}; #Rempves everything up to the equals...
		echo -e "$1\t$map.LG.MUH.$1.$i.order\t$likeline" >> $dir/OrderSummary.$dat.txt;
	done;
} 
export -f estchrom

parallel -j 6 --delay 0.2 "estchrom {1}" ::: ${array[@]};
perl ~/scripts/Linkage_Mapping/LM_7B_BestOrderPerChrom.pl $dir/OrderSummary.$dat.txt;


