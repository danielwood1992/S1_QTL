use POSIX;
use strict;

my $list = $ARGV[0];
open(IN, "<$list");
my ($line, $chr_name, $line2, $first);

open(OUT, ">$list.vconcat");

$first = "T";
while(!eof(IN)){
	$line = readline *IN;
	chomp $line;
	$chr_name = $line;
	$chr_name =~ s/.*LG\.//g;
	$chr_name =~ s/\..*//g;
	open(IN2, "<$line.genotypes2.goodnames");
	while(!eof(IN2)){
		$line2 = readline *IN2;
		chomp $line2;
		if ($line2 =~ m/^CHROM/){
			if ($first eq "T"){
				print OUT "CHROM\t$line2\n";
			}
		}else{
			$first = "F";
			$line2 =~ s/NA/-/g;
			print OUT "$chr_name\t$line2\n";	
		}
	}
	print "$chr_name\n";	
}
