#!/bin/bash --login
#SBATCH -o batch_LM_4.5_.%A.out.txt
#SBATCH -e batch_LM_4.5_.%A.err.txt
#SBATCH --ntasks=1
#SBATCH --time=12:00:00
#SBATCH --partition=htc
module load parallel;

#QA
#dir1="/scratch/b.bssc1d/Linkage_Mapping";
#ped="QA_Parents_Offspring.vcf.ped";
#vcf="QA_Parents_Offspring.vcf";

#QB
dir1="/scratch/b.bssc1d/Linkage_Mapping/LM_4.2_ParentCalls";
dir2="/scratch/b.bssc1d/Linkage_Mapping/LM_6_LepMap3/QB";

vcf="QB_Parents_F2s.vcf";
ped="QB_Parents_F2s.vcf.ped";

#Runtime instant...
perl -p -e 's/:.*?\t/\t/g' $dir1/$vcf > $dir2/$vcf;

## ParentCall2: calls parental genotypes (based on genotype likelihoods?)
#Runtime/memory basically instant...
java -cp ~/LepMap3/bin ParentCall2 data = $dir1/$ped vcfFile = $dir2/$vcf > $dir2/$ped.parentcall;
#Note - this also removes segregation distored markers, p < 0.001, by default; 
java -cp ~/LepMap3/bin ParentCall2 data = $dir1/$ped vcfFile = $dir2/$vcf  removeNonInformative=1 > $dir2/$ped.parentcall.noninf;

#Filter by segregation distortion (default = ?). Remove noninformative (I guess these can't really be useful?).
#Runtime/memory basically instant
#java -cp ~/LepMap3/bin Filtering2 data = $dir2/$ped.parentcall removeNonInformative=1 > $dir2/$ped.parentcall.call;
#

#arr=("5" "10" "15" "20" "25" "30" "35" "40" "45" "50");
arr=("45" "47" "49" "51" "55");

#for i in "${arr[@]}";
#	do java -cp ~/LepMap3/bin SeparateChromosomes2 data = $dir2/$ped.parentcall lodLimit=$i distortionLod=1 > $dir2/$ped.parentcall.map.lod.$i;
#	echo $i >> $dir2/QB_LOD_Summary.txt;
#	perl ~/scripts/Linkage_Mapping/LM_6B_summarise.pl $dir2/$ped.parentcall.map.lod.$i >> $dir2/QB_LOD_Summary.txt;
#done;

#arr=("26" "27" "28" "29");
#arr=("30" "31" "32" "33");

#arr=("35" "37" "39" "41" "43");

#for i in "${arr[@]}";
#	do java -cp ~/LepMap3/bin SeparateChromosomes2 data = $dir2/$ped.parentcall.call lodLimit=$i theta=0.03 > $dir2/$ped.parentcall.call.map.lod.$i;
#	echo $i >> $dir2/QB_LOD_Summary.txt;
#	perl ~/scripts/Linkage_Mapping/LM_6B_summarise.pl $dir2/$ped.parentcall.call.map.lod.$i >> $dir2/QB_LOD_Summary.txt;
#	done;

#Looking at these, a LOD of 31 seems to collapse things into the 12 chromosomes we'd expect (plus a few small fragments).

#QB: check impact of theta...

#QA
#arr=("0.01" "0.03" "0.05" "0.08");
#for i in "${arr[@]}";
#	do java -cp ~/LepMap3/bin SeparateChromosomes2 data = $dir/$ped.parentcall.call lodLimit=28 theta=$i > $dir/$ped.parentcall.call.map.lod.28.$i;
#	perl ~/scripts/Linkage_Mapping/LM_6B_summarise.pl $dir/$ped.parentcall.call.map.lod.28.$i;
#done;

#QB
#arr=("0.01" "0.03" "0.05" "0.08");
#for i in "${arr[@]}";
#	do java -cp ~/LepMap3/bin SeparateChromosomes2 data = $dir2/$ped.parentcall.call lodLimit=37 theta=$i > $dir2/$ped.parentcall.call.map.lod.37.$i;
#	echo "37 theta=$i" >> $dir2/QB_LOD_Summary.txt;
#	perl ~/scripts/Linkage_Mapping/LM_6B_summarise.pl $dir2/$ped.parentcall.call.map.lod.37.$i >> $dir2/QB_LOD_Summary.txt;
#done;



#Ok, so...for each linkage group...we want to a) 
#Set an initial order based on the order of markers within contigs (and then randomly assign contigs I guess for each run)
#Run these 10 times and then get the best order for each chromosome...
#So we need to 
#a) Find out which contigs are in which linkage groups
#So it seems like in the *final file, the order of numbers in the file corresponds to the order in the *call.call file. So then you can figure out which markers are in which linkage groups.
#Will be easy to write a script to get these...but how do you then convert this into an initial marker order? 
#b) Find out how to put in an initial marker order
#evaluateOrder=*order.txt: load initial marker order (single chromosome) from a file...
#So maybe what we need to do is...
#c) Find out how to generate this order...
#d) Find how to do these one at a time...

#QA
#java -cp ~/LepMap3/bin SeparateChromosomes2 data = $dir/$ped.parentcall.call lodLimit=31 theta=0.03 > $dir/$ped.parentcall.call.map.lod.31.final;

#QB
#java -cp ~/LepMap3/bin SeparateChromosomes2 data = $dir2/$ped.parentcall lodLimit=48 distortionLod=1 > $dir2/$ped.parentcall.map.lod.48.final;
#java -cp ~/LepMap3/bin JoinSingles2All map=$dir2/$ped.parentcall.map.lod.48.final data=$dir2/$ped.parentcall lodLimit=20 iterate=1 > $dir2/$ped.parentcall..map.lod.48.final.joinsingles2all #&& perl ~/scripts/S1_QTL/LM_6B_summarise.pl $dir2/$ped.parentcall.call.map.lod.48.final.joinsingles2all; 
#java -cp ~/LepMap3/bin LMPlot $dir2/$ped.parentcall.map.lod.48.final.joinsingles2all > $dir2/$ped.parentcall..map.lod.48.final.joinsingles2all.plot
#Well anyway. Let's try and get a map out of this...
#So not particularly sure how best to resolve this bit. And the  thing isn't helping that much.
#Could try just selecting the largest ones and attempting to fit the additional linkage groups into these?

#Ok well with this can't seem to resolve chromosome 12 into linkage groups particularly well.

#So we have the *final file. 

