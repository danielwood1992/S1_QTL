use POSIX;
use strict;

my $ID_Names = $ARGV[0]; #So this will be QA_Names.txt
my $genotypes_file = $ARGV[1]; #THis will be the output of LM_8_*sh
my $stem = "\/scratch\/b.bssc1d\/Linkage_Mapping\/";
#This will output the genotypes file but with the nice names (one hopes?);
open(OUT, ">$genotypes_file.goodnames");
my ($line, @temp, %hash, $i, $j);
open(IN, "<$ID_Names");
while(!eof(IN)){
	$line = readline *IN;
	chomp $line;
	@temp = split/\t/, $line;
	$hash{$temp[0]} = $temp[1];
}

open(IN, "<$genotypes_file");
$i = 0;
while(!eof(IN)){
	$i++;
	$line = readline *IN;
	chomp $line;
	if ($i == 2){
		@temp = split/\t/, $line;
		$j = 0;
		while ($j < scalar(@temp)){
			if ($temp[$j] =~ m/$stem/){
				$temp[$j] =~ s/$stem//g;
				$temp[$j] =~ s/_R.*//g;
				print $temp[$j]."\t";
				if (exists $hash{$temp[$j]}){
					$temp[$j] = $hash{$temp[$j]};
				}	
				print $temp[$j]."\n";
				}
			$j++;
		
		}
		$line = join "\t", @temp;
		print OUT $line."\n";	
	}else{
		print OUT $line."\n";
	}
}	

