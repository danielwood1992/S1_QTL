use POSIX;
use strict;

#Runtime? Instant
#Memory requirements: head node fine.
#
#WARNNNNNNNNNIIIIIIIIINNNNNNNNNGGGGGGGGGGGGGGGGGGGGGGG #EXPLOSIONS#
#
#THIS ASSUMES THE GRANDPARENTS ARE THE TWO LAST ENTRIES IN THE VCF
#NOT THE SAME AS LAST TIME, NOT GURANTEED TO BE THE SAME NEXT TIME AS I DON'T KNOW WHY THEY'VE CHANGED
#SO I AM RE-WRITING IT NOW BUT NEED TO BE V. CAEFUL...
#
#This converts a joint vcf file (grandparents + F2s) 
#produced from LM_4.5B 
#into a .ped file suitable for LepMap3
#defined from https://sourceforge.net/p/lep-map3/wiki/LM3%20Home/

#So for a single family my understanding of how it should look is the following...
#For a family of GP1, GP2, [P1, P2], F2_1, F2_2, F2_3, F2_4 #[P1 and P2 not sequenced...
#
#CHR POS QB QB QB QB QB QB QB QB
#CHR POS GP1 GP2 P1 P2 F2_1 F2_2 F2_3 F2_4
#CHR POS 0 0 GP1 GP1 P1 P1 P1 P1
#CHR POS 0 0 GP2 GP2 P2 P2 P2 P2
#CHR POS 0 0 0 0 0 0 0 0 
#CHR POS 0 0 0 0 0 0 0 0 
#
#Beginning to suspect this isn't what we're actually getting here...
#
#Ok well no wonder this isn't bloody right eh.
#I'm not sure how we sort this out for future versions...
#
#my $file = "/scratch/b.bssc1d/Linkage_Mapping/QA_Parents_Offspring.vcf";
#S1 - parents filtered...
#Copy this to the alt thing...
my $file = "/scratch/b.bssc1d/Linkage_Mapping/LM_4.2_ParentCalls/QB_Parents_F2s.vcf";
my $cross_name = "QB";
open(IN, "<$file");
open(OUT, ">$file.ped");
my ($line, @temp, $Grand1, $Grand2, @QAs, $out, $num_all, $num_F2s, $tmp1, $num_to_go_to);
while(!eof(IN)){
	$line = readline *IN;
	chomp $line;
	if ($line =~ m/^#CHROM/){
		@temp = split/\t/, $line;
		#So now we will need to....make the fancy new file, eh?
		$Grand1 = $temp[-1];
 		$Grand2 = $temp[-2];
		$num_to_go_to = scalar(@temp)-2;
		@QAs = @temp[ 9 .. $num_to_go_to ];
		#So, then...
		$num_F2s = scalar(@QAs);
		$num_all = $num_F2s+4;	
		#Line 1: Cross name for each individual...	
		$out = "$cross_name\t" x $num_all;
		$out =~ s/\t$//g;
		print $out."\n";
		print OUT "CHROM\tPOS\t$out\n";
		#Line 2 : Individual name...Grandparents, then F1 dummies, then F2s.
		$out = join( "\t", @QAs);
		$out = "CHROM\tPOS\t$Grand1\t$Grand2\tF1A\tF1B\t".$out."\n";
		print OUT $out;
		#Line 3: Father of each one....
		$tmp1 = "F1A\t" x $num_F2s;
		$tmp1 =~ s/\t$//g;
		$out = "CHROM\tPOS\t0\t0\t$Grand1\t$Grand1\t$tmp1\n";
		print OUT $out;
		#Line 4: Mother of each one....
		$tmp1 = "F1B\t" x $num_F2s;
		$tmp1 =~ s/\t$//g;
		$out = "CHROM\tPOS\t0\t0\t$Grand2\t$Grand2\t$tmp1\n";
		print OUT $out;
		#Line 5: Sexes...	
		$tmp1 = "0\t" x $num_F2s;
		$tmp1 =~ s/\t$//g;	
		$out = "CHROM\tPOS\t1\t2\t1\t2\t$tmp1\n";
		print OUT $out;
		#Line 6: Blanks...
		$tmp1 = "0\t" x $num_all;
		$tmp1 =~ s/\t$//g;
		$out = "CHROM\tPOS\t$tmp1\n";
		print OUT $out;
		}
}



