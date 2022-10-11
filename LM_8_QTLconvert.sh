#Requires: LM_8A, LM_8B, LM_8C scripts.
#Input: list of...order files...
script_8B="/home/b.bssc1d/scripts/S1_QTL/LM_8B_changenames.pl";
script_8C="/home/b.bssc1d/scripts/S1_QTL/LM_8C_BiggestScaffPerChrom.pl";

#QA
cross_dir="/scratch/b.bssc1d/Linkage_Mapping/LM1_QA";
ma_list="/scratch/b.bssc1d/Linkage_Mapping/LM1_QA/QA_Parents_F2s.vcf.ped.parentcall.LM_6.0.27.OrderSummary.Y%m_31.txt.sum";
ind_list="/home/b.bssc1d/scripts/S1_QTL/QA_SRA_files.txt";
ped="/scratch/b.bssc1d/Linkage_Mapping/LM1_QA/QA_Parents_F2s.vcf.ped";
parents=2;

#QB
#cross_dir="/scratch/b.bssc1d/Linkage_Mapping/LM1_QB";
#map_list="/scratch/b.bssc1d/Linkage_Mapping/LM1_QB/QB_Parents_F2s.vcf.ped.parentcall.LM_6.0.32.OrderSummary.Y%m_17.txt.sum";
#ind_list="/home/b.bssc1d/scripts/S1_QTL/QB_SRA_files.txt";
#ped="/scratch/b.bssc1d/Linkage_Mapping/LM1_QB/QB_Parents_F2s.vcf.ped";
parents=2;

#QC
cross_dir="/scratch/b.bssc1d/Linkage_Mapping/LM1_QCE";
map_list="/scratch/b.bssc1d/Linkage_Mapping/LM1_QCE/QCE_Parents_F2s.vcf.ped.parentcall.LM_6.0.22.OrderSummary.Y%m_31.txt.sum";
ind_list="/home/b.bssc1d/scripts/S1_QTL/QCE_SRA_files.txt";
ped="/scratch/b.bssc1d/Linkage_Mapping/LM1_QCE/QCE_Parents_F2s.vcf.ped";
parents=4;



truncate -s 0 $map_list.new;
while read line;
	do echo $line;
	#Gets the file name (postawk)
	line2=$(echo $line | cut -f2 -d' ').postawk;
	echo $line2;
	#Gets the chromosome number
	chrom=$(echo $line | cut -f1 -d' ');
	echo $chrom;
	#Concatenates the chromosome number to the beginning of every line
	awk -v var="$chrom\t" '{print var $0}' $line2 > $line2.new;
	#Replaces the 1's and 2's with A's, B's, H's etc.
	perl -p -i -e 's/1 1/A/g' $line2.new;
	perl -p -i -e 's/1 2/H/g' $line2.new;
	perl -p -i -e 's/2 1/H/g' $line2.new;
	perl -p -i -e 's/2 2/B/g' $line2.new;
	perl -p -i -e 's/0 0/NA/g' $line2.new;
	echo $line2.new >> $map_list.new;
done < $map_list; 
#Concatenates all of them for each chromosome into a new file
xargs -rd'\n' cat > $map_list.concat < $map_list.new;
#Removes a line from the ped file for ease of making into one table...
if [ $parents == 2 ] 
then
	cut -f1,2,4- $ped > $ped.cut;
else
	cut -f1,2,3,5,6,11- $ped > $ped.cut;
	
fi 
#Concats them all together
cat $ped.cut $map_list.concat > $map_list.concat2;
perl $script_8B $ind_list $map_list.concat2 ${cross_dir}/;
perl $script_8C $map_list.concat2.goodnames $ped.parentcall;


