use POSIX;
use strict;

#Summarises the results of a SeparateChromosomes2 run...

my ($line, %hash, $item);
my $file = $ARGV[0];
open(IN, "<$file");
while(!eof(IN)){
	$line = readline *IN;
	chomp $line;
	if ($line =~ m/^#/){
	}else{
		$hash{$line}++;
	}
}
my @sorted_keys = sort { $a <=> $b } (keys %hash);
foreach $item (@sorted_keys){
	print "$item: $hash{$item}\t";
}
print "\n";
