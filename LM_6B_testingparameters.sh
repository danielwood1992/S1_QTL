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
progdir="/scratch/b.bssc1d/Linkage_Mapping/";
name="QB";
this_step=$dir1/"QB_LM_6B_Progress.txt";
parentcall="/scratch/b.bssc1d/Linkage_Mapping/LM_6_LepMap3/QB/QB_Parents_F2s.vcf.ped.parentcall";
vcf="/scratch/b.bssc1d/Linkage_Mapping/LM_4.2_ParentCalls/QB_Parents_F2s.vcf";


#Question 1: Does grandparentphase=1 increase/decrease the number of things pu in LGs?

does_grandparent () {
	parentcall=$1;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=45 distortionLod=1 > $parentcall.LM_6B.A.nogrand;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=45 distortionLod=1 grandparentPhase=1 > $parentcall.LM_6B.A.grand;
	}

export does_grandparent;

if grep -q "LM_6B.A_Complete" $this_step; 
	then echo "LM_6B.A_Complete";
else 
	echo "$name Starting 4.1A" >> $this_step && does_grandparent $parentcall && echo "$name LM_6B.A_Complete" >> $this_step;
fi;

echo "No grandparent phase";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.A.nogrand;
echo "Grandparent phase";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.A.grand;

#Increased number of markers in linkage groups when you don't use grandparent phasing.
#So I guess...maybe we should use the unphased ones?

#Question 2: Impact of theta?

does_theta () {
	parentcall=$1;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=45 distortionLod=1 > $parentcall.LM_6B.B.theta0.03;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=45 distortionLod=1 theta=0.3 > $parentcall.LM_6B.B.theta0.3;
	}

export does_theta;

if grep -q "LM_6B.B_Complete" $this_step; 
	then echo "LM_6B.B_Complete";
else 
	echo "$name Starting 6.6B" >> $this_step && does_theta $parentcall && echo "$name LM_6B.B_Complete" >> $this_step;
fi;

echo "Theta = 0.03";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.B.theta0.03;
echo "Theta = 0.3";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.B.theta0.3;

#So increasing theta above the defualt seems to significantly reduce the number of linkage groups.
#Let's just leave it.

#Question 3: sizeLimit = 40; I'd say this probably makes sense? Gets rid of smaller contigs.

#But do these get added to other linkage groups?
does_size () {
	parentcall=$1;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=45 distortionLod=1 sizeLimit=40 > $parentcall.LM_6B.C.nosize;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=45 distortionLod=1> $parentcall.LM_6B.C.size40;
	}

export does_size;

if grep -q "LM_6B.C_Complete" $this_step; 
	then echo "LM_6B.C_Complete";
else 
	echo "$name Starting 6.6C" >> $this_step && does_size $parentcall && echo "$name LM_6B.C_Complete" >> $this_step;
fi;

echo "No Size Limit";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.C.nosize;
echo "Size Limit of 40";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.C.size40;
#Well...what are we supposed to do with those small linkage groups anyway? I don't really know. They're probably better joined into what we know are the 12 existing chromosomes.

#Question 4 (E) - Does the LOD distortion stop things being assigned to linkage groups?

does_lodfit () {
	parentcall=$1;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=45 sizeLimit=40 > $parentcall.LM_6B.C.nolod;
	}

export does_lodfit;

if grep -q "LM_6B.E_Complete" $this_step; 
	then echo "LM_6B.E_Complete";
else 
	echo "$name Starting 6.6E" >> $this_step && does_lodfit $parentcall && echo "$name LM_6B.E_Complete" >> $this_step;
fi;

echo "LOD distortion";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.C.size40;
echo "No LOD distortion filteing";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.C.nolod

#Answer: basiscally no, very similar numbers. Why would this be?
#Is there something wrong with the way I'm filtering this stuff?

#Question 5 (F) - What happens if we try much lower LOD scores? Do any of these markers then get included?

does_lodlim () {
	parentcall=$1;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=5 sizeLimit=40 > $parentcall.LM_6B.F.lim5;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=15 sizeLimit=40 > $parentcall.LM_6B.F.lim15;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=25 sizeLimit=40 > $parentcall.LM_6B.F.lim25;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=35 sizeLimit=40 > $parentcall.LM_6B.F.lim35;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=45 sizeLimit=40 > $parentcall.LM_6B.F.lim45;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=55 sizeLimit=40 > $parentcall.LM_6B.F.lim55;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=48 sizeLimit=40 > $parentcall.LM_6B.F.lim48;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=50 sizeLimit=40 > $parentcall.LM_6B.F.lim50;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$parentcall lodLimit=52 sizeLimit=40 > $parentcall.LM_6B.F.lim52;

	}
export does_lodlim;

if grep -q "LM_6B.F_Complete" $this_step; 
	then echo "LM_6B.F_Complete";
else 
	echo "$name Starting 6.6F" >> $this_step && does_lodlim $parentcall && echo "$name LM_6B.F_Complete" >> $this_step;
fi;

echo "lodLimit=5";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.F.lim5;
echo "lodLimit=15";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.F.lim15;
echo "lodLimit=25";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.F.lim25;
echo "lodLimit=35";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.F.lim35;
echo "lodLimit=45";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.F.lim45;
echo "lodLimit=55";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.F.lim55;
echo "lodLimit=48";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.F.lim48;
echo "lodLimit=50";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.F.lim50;
echo "lodLimit=52";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.F.lim52;

#So even with an extremely low LOD limit basisclly no change in how many markers are assigned to each chromosome.
#Update: lodLimit=50 seems to get out the number of chromosomes with a roughly balanced number of markers, which is nice.

#Question 5 (G) - are these ~2k markers noninformative? I just don't get where they're coming from...

noninf="/scratch/b.bssc1d/Linkage_Mapping/LM_6_LepMap3/QB/QB_Parents_F2s.vcf.ped.parentcall.noninf";

does_noninf () {
	noninf=$1;
	java -cp ~/LepMap3/bin SeparateChromosomes2 data=$noninf lodLimit=50 sizeLimit=40 > $parentcall.LM_6B.G.noninf;
	}

export does_noninf;

if grep -q "LM_6B.G_Complete" $this_step; 
	then echo "LM_6B.G_Complete";
else 
	echo "$name Starting 6.6G" >> $this_step && does_noninf $noninf && echo "$name LM_6B.G_Complete" >> $this_step;
fi;

echo "######";
echo "Including noninf";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.G.noninf;
echo "Excluding noninf";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $parentcall.LM_6B.F.lim50
echo "######"

#Wow ok great getting somewhere - so 1,800 of the 2,000 SNPs are classified as noninformative: 
#...but there shouln't be noninformative markers? Has something gone wrong in the filtering of the parental SNPs?

#Having compared markers manually, it's clear that the majority of these markers are excluded because the grandparents are heterozygous for them.
#I'm not sure how we could include them (many of them appear to segregate in a manner that makes sense).
#We can potentially just not include the grandparents altogether, this should be possible.

#####################
#So I guess it's now important to get additional markers...
#####################


#Question 5 - what LOD limit to set for JoinIndividualMarkers?
map2use=$parentcall.LM_6B.C.size40;
join_lod_lim () {
	parentcall=$1;
	java -cp ~/LepMap3/bin JoinSingles2All map=$map2use data=$parentcall lodLimit=2 iterate=1 > $map2use.lod2; 	
	java -cp ~/LepMap3/bin JoinSingles2All map=$map2use data=$parentcall lodLimit=5 iterate=1 > $map2use.lod5; 	
	java -cp ~/LepMap3/bin JoinSingles2All map=$map2use data=$parentcall lodLimit=15 iterate=1 > $map2use.lod15; 	
	java -cp ~/LepMap3/bin JoinSingles2All map=$map2use data=$parentcall lodLimit=30 iterate=1 > $map2use.lod30; 	
	}

export join_lod_lim;

if grep -q "LM_6B.D_Complete" $this_step; 
	then echo "LM_6B.D_Complete";
else 
	echo "$name Starting 6.6D" >> $this_step && join_lod_lim $parentcall && echo "$name LM_6B.D_Complete" >> $this_step;
fi;

echo "lod=2";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $map2use.lod2;
echo "lod=5";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $map2use.lod5;
echo "lod=15";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $map2use.lod15;
echo "lod=30";
perl ~/scripts/S1_QTL/LM_6B_summarise.pl $map2use.lod30;
#So JoinSingles2All basically doesn't add very many markers.
#I would like to know what these markers are that refused to be added...
perl ~/scripts/S1_QTL/LM_6D_Markers2vcf.pl $map2use.lod15 0;
#Looking at these SNPs...nothing obvious leaps out.
#Compare to ones that are included.
perl ~/scripts/S1_QTL/LM_6D_Markers2vcf.pl $map2use.lod15 1;
#Look at stats files.
bcftools stats -s - $vcf.LG0.vcf > $vcf.LG0.stats; 
bcftools stats -s - $vcf.LG1.vcf > $vcf.LG1.stats; 
#So a few SNPs in the LG0 file with extreme AF values (likely errors)
#Both have a large number of SNPs in the approximately 0.5 range.
#Can't really figure out the differences.
#I don't really understand what's up with these ones. But they don't seem 
#to be in linkage disequilibrium with the other ones. Or even each other, much.
#So not really sure what to make of this.
#Ordering the markers: well, this seems relatively straightforward/solvable.


