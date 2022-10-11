#!/bin/bash --login
#SBATCH -o /scratch/b.bssc1d/Linkage_Mapping/logs/LM_6.0_.%A.out.txt
#SBATCH -e /scratch/b.bssc1d/Linkage_Mapping/logs/LM_6.0_.%A.err.txt
#SBATCH --ntasks=1
#SBATCH --time=12:00:00
#SBATCH --partition=htc
module load parallel;
module load bcftools;

#Description: this will go through your LOD array, which you can update, and estimates the number of chromosomes for each. 
#Want to maximise the number of markers in your 12 chromosomes.
#Outputs: ${cross}_LM_6.0_Progress.txt: this will have the numbers on each chromosome for the various markers. Choose based on this. 

#Aiming for 12 chromosomes.

#Uncomment both the cross and the array
#cross="QA";
#lod_array=( 5 15 25 35 45 55 48 50 52 );
#30-45 might be best, still no enough linkage groups though.
#lod_array=( 5 15 25 35 45 55 48 50 52 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 25 26 27 28 29 30);

#cross="QB";
#lod_array=( 5 15 25 35 45 55 48 50 52 );
#35-45 looks best
#lod_array=( 5 15 25 35 45 55 48 50 52 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44);
#lod=32 gives the best score in terms of numbers of markers in the appropriate chromosomes.
#So that's good.
#Let's advance this to the next stage. Worry about QA and QCE once the final runs have been set.

cross="QCE";
#lod_array=( 5 15 25 35 45 55 48 50 52 );
#Could be somewhere between 15 and 40?
#lod_array=( 5 15 25 35 45 55 48 50 52 15 16 17 18 19 20 21 22 24 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44);
lod_array=($(seq 1 1 55));

dir1="/scratch/b.bssc1d/Linkage_Mapping/LM1_${cross}";
progdir="/scratch/b.bssc1d/Linkage_Mapping";
this_step="$progdir/${cross}_LM_6.0_Progress.txt";
vcf="/scratch/b.bssc1d/Linkage_Mapping/LM1_$cross/${cross}_Parents_F2s.vcf";
ped="$vcf.ped";

dat=$(date +%Y_%m_%d);

#1 Do parentcall, if it's not already done
if [ ! -f $ped.parentcall ]; then
	perl -p -i -e 's/:.*?\t/\t/g' $vcf;
	java -cp ~/LepMap3/bin ParentCall2 data = $ped vcfFile = $vcf > $ped.parentcall;
fi

parentcall=$ped.parentcall;

step_des="LM_6.0";

truncate -s 0 $this_step;

echo "$dat LM_6.0_started" >> $this_step;
for lod in "${lod_array[@]}"
	do echo $lod;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=$lod sizeLimit=25 distortionLod=1 informativeMask=3 grandparentPhase=1 > $parentcall.$step_des.$lod;
	echo "$dat lodLimit=$lod" >> $this_step;
	perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.$step_des.$lod &>> $this_step;	
done
echo "$dat LM_6.0_Complete" >> $this_step;


