#!/bin/bash --login
#SBATCH -o batch_LM_4.5_.%A.out.txt
#SBATCH -e batch_LM_4.5_.%A.err.txt
#SBATCH --ntasks=1
#SBATCH --time=12:00:00
#SBATCH --partition=htc
module load parallel;
module load bcftools;
#QA
#dir1="/scratch/b.bssc1d/Linkage_Mapping";
#ped="QA_Parents_Offspring.vcf.ped";
#vcf="QA_Parents_Offspring.vcf";

#QB
dir1="/scratch/b.bssc1d/Linkage_Mapping/LM_6_LepMap3/QB";
progdir="/scratch/b.bssc1d/Linkage_Mapping";
name="QB";
this_step=$progdir/"QB_LM_6B_Progress.txt";
vcf="/scratch/b.bssc1d/Linkage_Mapping/LM_4.2_ParentCalls/QB_Parents_F2s.vcf";
ped="/scratch/b.bssc1d/Linkage_Mapping/LM_4.2_ParentCalls/QB_Parents_F2s.vcf.ped";

if [ ! -f $ped.parentcall ]; then
	perl -p -e 's/:.*?\t/\t/g' $vcf > $dir1/$(basename $vcf);
	java -cp ~/LepMap3/bin ParentCall2 data = $ped vcfFile = $dir1/$(basename $vcf) > $dir1/$(basename $ped).parentcall;
fi
parentcall=$dir1/$(basename $ped).parentcall;

#Question 1 (A)- What happens if we try much lower LOD scores? Do any of these markers then get included?
step_des="LM_6B.A";
does_lodlim () {
	parentcall=$1;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=5 sizeLimit=40 distortionLod=1 informativeMask=3 grandparentPhase=1 > $parentcall.$step_des.lim5;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=15 sizeLimit=40 distortionLod=1 informativeMask=3 grandparentPhase=1  > $parentcall.$step_des.lim15;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=25 sizeLimit=40 distortionLod=1 informativeMask=3 grandparentPhase=1   > $parentcall.$step_des.lim25;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=35 sizeLimit=40 distortionLod=1 informativeMask=3 grandparentPhase=1   > $parentcall.$step_des.lim35;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=45 sizeLimit=40 distortionLod=1 informativeMask=3 grandparentPhase=1   > $parentcall.$step_des.lim45;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=55 sizeLimit=40 distortionLod=1 informativeMask=3 grandparentPhase=1   > $parentcall.$step_des.lim55;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=48 sizeLimit=40 distortionLod=1 informativeMask=3 grandparentPhase=1  > $parentcall.$step_des.lim48;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=50 sizeLimit=40 distortionLod=1 informativeMask=3 grandparentPhase=1   > $parentcall.$step_des.lim50;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=52 sizeLimit=40 distortionLod=1 informativeMask=3 grandparentPhase=1   > $parentcall.$step_des.lim52;

	}
export does_lodlim;

if grep -q "$step_des.Complete" $this_step; 
	then echo "$step_des.Complete";
else 
	echo "$name Starting 6.6A" >> $this_step && does_lodlim $parentcall && echo "$name $step_des.Complete" >> $this_step;
fi;

echo "lodLimit=5";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.$step_des.lim5;
echo "lodLimit=15";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.$step_des.lim15;
echo "lodLimit=25";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.$step_des.lim25;
echo "lodLimit=35";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.$step_des.lim35;
echo "lodLimit=45";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.$step_des.lim45;
echo "lodLimit=55";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.$step_des.lim55;
echo "lodLimit=48";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.$step_des.lim48;
echo "lodLimit=50";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.$step_des.lim50;
echo "lodLimit=52";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.$step_des.lim52;





