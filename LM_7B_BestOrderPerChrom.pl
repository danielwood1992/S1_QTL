use POSIX;
use strict;

my $infile = $ARGV[0];
open(IN, "<$infile");
open(OUT, ">$infile.sum");

my ($line, @temp, %hash, @sorted_keys, $item);

while(!eof(IN)){
	$line = readline *IN;
	chomp $line;
	@temp = split/\t/, $line;
	if (exists($hash{$temp[0]}[0])){
	}else{
		$hash{$temp[0]}[0] = $temp[2];
		$hash{$temp[0]}[1] = $temp[1];
	}
	if ($temp[2] > $hash{$temp[0]}[0]){
		print "woof\n";
		$hash{$temp[0]}[0] = $temp[2];
		$hash{$temp[0]}[1] = $temp[1];
	}
}
@sorted_keys = sort {$a <=> $b} (keys %hash);
foreach $item (@sorted_keys){
	print OUT "$item\t$hash{$item}[1]\t$hash{$item}[0]\n";
}
