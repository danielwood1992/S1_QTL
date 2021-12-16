use POSIX;
use strict;
use List::Util qw(shuffle);

#So this script will take the output of 
#B) java -cp ~/LepMap3/bin SeparateChromosomes2 > SepChrom.txt
# the output of 
#B) java -cp ~/LepMap3/bin Filtering2 > Filtered.txt
#
#Note - as far as I can tell, marker order is SepChrom.txt corresponds to that in Filtered.txt (once the headers are removed). 
#
#
#For markers in the linkage group you want this script will find the corresponding scaffolds and positions in your Filtered.txt file.
#These should in order within each scaffold.
#It will then
#i) Randomly orient the scafffold as either "forward" or "backward" (but keeping marker order along the scaffold intact)
#ii) Randomly shuffle the order of all the scaffolds.
#
#It will then return
#A) the SepChrom.txt.LD.$LD file - the SepChrom file, only with the markers in your LD in the order generated above. This is the input for initial ordering in OrderMarkers2
#(at least from what I can gather from https://sourceforge.net/p/lep-map3/discussion/general/thread/41a195a199/)
#B) the Fltered.txt.LD.$LD file - the Filtered2 output file, but only for the LD of interest, in the same order as A). So you can see what's going on.

#Formats that will probably break this script:
#Your CHROM/scaffolds starting with "CHROM"
#Markers within the Filtered2 file are not in the correct order.
#
#DW note - corresponds to script LM_6C
#
#Bon chance.

my $SepChrom = $ARGV[0];
my $Filtered = $ARGV[1];
my $LG = $ARGV[2]; #LG of interest (e.g. 2)
my $suff = $ARGV[3]; #Suffix for each run of this script, as they will differ each time (set in a higher script if you're doing lots of repeats).

my ($i, $line, %LG2POS, %LG_ChromPos, @temp, $item, $item2, %ChromPos2Marker, @scaff_array);

#1) Get thigs in LG = 2 (or whichever one you want) from the SepChrom file.
#Creates %LG2POS which allows you to separate out the LGs you want in the Filtered.txt file

$i = 0;
open(IN, "<$SepChrom");
while(!eof(IN)){
	$line = readline *IN;
	chomp $line;
	if ($line =~ m/^#/){
	}else{
		$i++;
		$LG2POS{$line}{$i} = "whatever";
	}
}

#2) For the linkage group we want, retrieve the relevant CHROM\tPOS data from the Filtered file.
#Data structures created here:
#%ChromPos2Marker{ChromPos} ->  $MarkerPos; can use the CHROM\tPOS data to find the equivalent marker number. Only for LG of interest.
#%LG_CHromPos{Chrom} -> @Pos ; Creates a hash with keys corresponding to each scaffold in your LG of interest; the value is an array of all the CHROM\tPOS values
#These should be in order within each CHROM (scaffold). Only for LG of interest (markers on the same CHROM/scaffold not in the LG should be excluded).

open(IN, "<$Filtered");
$i = 0;
while(!eof(IN)){
	$line = readline *IN;
	chomp $line;
	if ($line =~ m/^#/){
	}elsif($line =~ m/^CHROM/){
	}else{
		$i++;
		if (exists($LG2POS{$LG}{$i})){
			@temp = split/\t/, $line;
			#So then all we'll need to do is...i) record the name 

			$ChromPos2Marker{$temp[0]."sepstring".$temp[1]} = $i;
			#This will then spit out markers in apprpriate order...
			push (@{$LG_ChromPos{$temp[0]}}, $temp[0]."sepstring".$temp[1]);
			#These arrays should be in the correct order already
			
		}
	}
}

open(OUT, ">$SepChrom.LG.$LG.$suff");
open(OUT2, ">$Filtered.LG.$LG.$suff");

#$item here will be the scaffold.
print OUT2 "#LG $LG\n";
print OUT2 "CHROM\tPOS\n";

#This will randomise the order of the CHROM/scaffolds for being printed out
foreach $item (shuffle(keys %LG_ChromPos)){
#	print $item."\n";
#	This will randomly reverse the orientation of each scaffold.
	@scaff_array = @{$LG_ChromPos{$item}};
	if (rand() > 0.5){
		@scaff_array = reverse(@scaff_array);
	}
	foreach $item2 (@scaff_array){
		#Within each (possibly reversed) scaffold, the marker position is printed to $SepChrom.LG.$LG.$suff
		print OUT $ChromPos2Marker{$item2}."\n";
		@temp = split/sepstring/, $item2;
		#The Chrom\tPos info is printed to $Filtered.LG.$LG.$suff
		print OUT2 "$temp[0]\t$temp[1]\n";
	}
}
#This process is then repeated across every scaffold in the linkage group. Each time the initial starting order should be different.
#Can then use this repeatedly to initialise multiple runs of OrderMarkers2, informed by your genome order.
