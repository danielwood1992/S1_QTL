#!/bin/bash --login
#SBATCH -o /scratch/b.bssc1d/Linkage_Mapping/logs/LM_7.0_.%A.out.txt
#SBATCH -e /scratch/b.bssc1d/Linkage_Mapping/logs/LM_7.0_.%A.err.txt
#SBATCH --ntasks=12
#SBATCH --time=24:00:00
module load parallel;

#So for the first 12 chromosomes (or however many you've got...)
#Should create N starting files based on your contigs, and then run OrderMarkers2 on these. You can then summarise the best for each one.
#Input: cross, marker assignments from LM_6.0.
#What this does: a load of stuff to identify the best marker order within each chromosome.
#Outputs: the maps for each of 20 attempts, for each chromosome. You will also get $map.OrderSummary.$dat.txt.sum.cut2.sed; this will give for each chromosome the best order, and their likelihoods.
.

#So you need to specify your final map here, from evaluating in LM_6.0

#cross="QA";
#map="/scratch/b.bssc1d/Linkage_Mapping/LM1_QA/QA_Parents_F2s.vcf.ped.parentcall.LM_6.0.27"

#cross="QB";
#map="/scratch/b.bssc1d/Linkage_Mapping/LM1_QB/QB_Parents_F2s.vcf.ped.parentcall.LM_6.0.32";

cross="QCE";
map="/scratch/b.bssc1d/Linkage_Mapping/LM1_QCE/QCE_Parents_F2s.vcf.ped.parentcall.LM_6.0.22";

############

vcf="/scratch/b.bssc1d/Linkage_Mapping/LM1_$cross/${cross}_Parents_F2s.vcf";
ped="$vcf.ped";
parentcall="$ped.parentcall";
chrom_num=12;

N=20;

##############

array=($(seq 1 1 $chrom_num));
dat=$(date "+Y%_%m_%d");

#Note - shell variables are not visible to child processes (aka a function) unless they are exported.

export dir=$dir;
export ped=$ped;
export vcf=$vcf;
export dat=$dat;
export map=$map;
export parentcall=$parentcall;
export N=$N;

truncate -s 0 $map.OrderSummary.$dat.txt; 
estchrom () {
	echo $1; #This is the chromosomes...

	for i in $(seq 1 $N); 
		do echo $i; echo $1;
		echo $1; perl ~/scripts/Linkage_Mapping/LM_6C_order2markers.pl $map $parentcall $1 $i; 
		java -cp ~/LepMap3/bin OrderMarkers2 data=$parentcall map=$map grandparentPhase=1 chromosome=$1 numThreads=1 evaluateOrder=$map.LG.$1.$i outputPhasedData=1 informativeMask=3  interference1=1 interference2=1 sexAveraged=1 > $map.LG.MUH.$1.$i.order;
		awk -f ~/LepMap3/map2genotypes.awk $map.LG.MUH.$1.$i.order > $map.LG.MUH.$1.$i.order.postawk;
		likeline=$(grep likelihood $map.LG.MUH.$1.$i.order); 
		likeline=${likeline/*= /}; #Rempves everything up to the equals...
		echo -e "$1\t$map.LG.MUH.$1.$i.order\t$likeline" >> $map.OrderSummary.$dat.txt;
	done;
} 
export -f estchrom

parallel --tmpdir /scratch/b.bssc1d -j 12 --delay 0.2 "estchrom {1}" ::: ${array[@]};
perl ~/scripts/Linkage_Mapping/LM_7B_BestOrderPerChrom.pl $map.OrderSummary.$dat.txt;
cut -f2 $map.OrderSummary.$dat.txt.sum > $map.OrderSummary.$dat.txt.sum.cut2;
sed -n 's/$/.postawk/g' $map.OrderSummary.$dat.txt.sum.cut2 > $map.OrderSummary.$dat.txt.sum.cut2.sed; 
#So you also get a genomic map from this.
perl /home/b.bssc1d/scripts/S1_QTL/LM_7C_GetGenomicPositions.pl $map.OrderSummary.$dat.txt.sum.cut2.sed $parentcall;

