use POSIX;
use strict;

my $stats_file = $ARGV[0];
my $snp_num = $ARGV[1];
my $thresh = $ARGV[2];

#assumptions:
#stats file: PSC section , last number is number missing, third field is sample name
my ($line, @temp, @to_keep);

open(IN, "<$stats_file");
while(!eof(IN)){
	$line = readline *IN;
	chomp $line;
	if ($line =~ m/^PSC/){
		@temp = split/\t/, $line;
		if ($temp[-1]/$snp_num > $thresh){
		}else{
			push @to_keep, $temp[2];
		}
	}else{
	}
}
my $string = join(",", @to_keep);
print $string."\n";
#my $length = scalar(@to_keep);
#print $length."\n";
