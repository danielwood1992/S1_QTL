use POSIX;
use strict;

#Runtime? Instant
#Memory requirements: head node fine.
#WARNING: Assumes that grandparents are the last two entries in the vcf...
#(Note: manually check these names/add an option in the script...)
#
#Inputs: ${cross}_Parents_F2s.vcf (output of LM_4.7)

#For a multi family vcf, this will be a bit confusing.
#We will cheat here by assuming all the QEs are called "QE" and all the QAs are called "QA"
#This is because QCE comes from QC and QE
#These have the same grandparents but a different F1 parent

#This converts a joint vcf file (grandparents + F2s) 
#produced from LM_4.7 
#into a .ped file suitable for LepMap3
#defined from https://sourceforge.net/p/lep-map3/wiki/LM3%20Home/

#Multi-family file with shared grandparents - see https://sourceforge.net/p/lep-map3/discussion/general/thread/885598e615/
#Structure required (from test.ped from Pasi)
#CHR	POS	F1	F1	F1	F1	F1	F2	F2	F2	F2	F2
#CHR	POS	G1	G2	P1	P2	O1	G1	G3	P3	P4	O2
#CHR	POS	0	0	G1	G1	P1	0	0	G1	G3	P3
#CHR	POS	0	0	G2	G2	P2	0	0	G2	0	P4
#CHR	POS	1	2	1	2	0	1	2	1	2	0
#CHR	POS	0	0	0	0	0	0	0	0	0	0

#So here we will want to duplicate the grandparents etc.

#DW Note: Note - you need to use QA_5A for QA, QB
my $cross_name = "QCE";

my $file = "/scratch/b.bssc1d/Linkage_Mapping/LM1_$cross_name/$cross_name"."_Parents_F2s.vcf";
#lol so yeah you definitely should have renamed them, this will make everything needlessly complicated...

my $file_list = "/home/b.bssc1d/scripts/S1_QTL/$cross_name"."_SRA_files.txt";

my ($line, @temp, %which_hash);

open(IN, "<$file_list");
while(!eof(IN)){
	$line = readline *IN;
	chomp $line;
	@temp = split/\t/, $line;
	if ($temp[1] =~ m/QE/){
		$temp[1] = "QE";
		$which_hash{$temp[0]} = $temp[1];
	}elsif($temp[1] =~ m/QC/){
		$temp[1] = "QC";
		$which_hash{$temp[0]} = $temp[1];
	}else{
		print $temp[1]."\n";
		die "you will need to modify this script\n";
	}
}

#So now we do have a list of which is which, so that's good.

open(IN, "<$file");
open(OUT, ">$file.ped");
my ($line, @temp, $Grand1, $Grand2, @QAs, $out, $num_all, $num_F2s, $tmp1, $num_to_go_to, $item, $line3, $line4);
my ($line1, $line2, $line3, $line4, $line5, $line6);
while(!eof(IN)){
	$line = readline *IN;
	chomp $line;
	if ($line =~ m/^#CHROM/){
		@temp = split/\t/, $line;
		#So now we will need to....make the fancy new file, eh?
		$Grand1 = $temp[-1];
		print "Grandparent 1? $Grand1\n";
 		$Grand2 = $temp[-2];
		print "Grandparent 2? $Grand2\n";
		$num_to_go_to = scalar(@temp)-3;
		@QAs = @temp[ 9 .. $num_to_go_to ];
		#So, then...
		$num_F2s = scalar(@QAs);
		#So this is F2s plus 4 grandparents and 4 parents	
		$num_all = $num_F2s+8; 
		#Line 1: Cross name for each individual...	
	
		#$out = "$cross_name\t" x $num_all;
		#$out =~ s/\t$//g;
		#print $out."\n";
		#print OUT "CHROM\tPOS\t$out\n";

		#Line 2 : Individual name...Grandparents, then F1 dummies, then F2s.
		$out = join( "\t", @QAs);
		$line2 = "CHROM\tPOS\t$Grand1\t$Grand2\tF1A\tF1B\t$Grand1\t$Grand2\tF1C\tF1D\t".$out;
	
		#So now it gets complicated..
		#Line 3: Father of each one....
		#This will be F1A for QC, F1C for QE
		foreach $item (@QAs){
			$item =~ s/^.*\///g;
			$item =~ s/\.bwa.*//g;
#			print $item."\n";
			if ($which_hash{$item} eq "QC"){
				$line3 = "$line3"."F1A\t";
				$line4 = "$line4"."F1B\t";
				$line1 = "$line1"."QC\t";
			}elsif($which_hash{$item} eq "QE"){
				$line3 = "$line3"."F1C\t";
				$line4 = "$line4"."F1D\t";
				$line1 = "$line1"."QE\t";

			}else{
				die "something gone wrong\n";
			}
		}

		$line1 = "CHROM\tPOS\tQC\tQC\tQC\tQC\tQE\tQE\tQE\tQE\t$line1";
		$line1 =~ s/\t$//g;
	
		$line3 = "CHROM\tPOS\t0\t0\t$Grand1\t$Grand1\t0\t0\t$Grand1\t$Grand1\t$line3";
		$line3 =~ s/\t$//g;
 
		$line4 = "CHROM\tPOS\t0\t0\t$Grand2\t$Grand2\t0\t0\t$Grand2\t$Grand2\t$line4";
		$line4 =~ s/\t$//g;

		$tmp1 = "0\t" x $num_F2s;
		$line5 = "CHROM\tPOS\t1\t2\t1\t2\t1\t2\t1\t2\t$tmp1";
		$line5 =~ s/\t$//g;

		$tmp1 = "0\t" x $num_all;
		$tmp1 =~ s/\t$//g;
		$line6 = "CHROM\tPOS\t$tmp1";
		
		print OUT $line1."\n";
		print OUT $line2."\n";
		print OUT $line3."\n";
		print OUT $line4."\n";
		print OUT $line5."\n";
		print OUT $line6."\n";

		}
}



