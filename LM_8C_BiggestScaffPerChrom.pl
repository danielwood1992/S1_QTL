my $goodnames = $ARGV[0];
my $parentcall = $ARGV[1];

my ($line, @temp, %pos_chrom, %chrom_scaff, %marker_scaff, $chrom, $marker, $scaff);

open(IN, "<$goodnames");
while(!eof(IN)){
	$line = readline *IN;
	chomp $line;
	if ($line =~ m/^CHROM/){
	}else{
		@temp = split/\t/, $line;
		$pos_chrom{$temp[1]} = $temp[0];
		$chrom_scaff{$temp[0]} = "";
	}
}


open(IN, "<$parentcall");
$i = 0;
while(!eof(IN)){
	$line = readline *IN;
	chomp $line;
	if ($line =~ m/^java/){
	}if ($line =~ m/^CHROM/){
	}else{
		$i++;
		@temp = split/\t/, $line;
		$marker_scaff{$i} = $temp[0];	
	}
}

#For each chromosome...
foreach $chrom (keys %chrom_scaff){
	print $chrom."\n";
	my %which_max; #Make an array
	#Go through all the markers...
	foreach $marker (keys %pos_chrom){
		#If they are on that chromosome...
		if ($pos_chrom{$marker} eq $chrom){
			#Use marker info to get scaffold. Make hash of scaffolds, adding one to the value for every marer on that scaffold.
			$which_max{$marker_scaff{$marker}}++;
		}
	}
	my $most_freq = "NA";
	my $record = "0";
	foreach $scaff (keys %which_max){
		if ($which_max{$scaff} > $record){
			$record = $which_max{$scaff};
			$most_freq = $scaff;
		}
	}
	$chrom_mostfreq{$chrom} = $most_freq;
	print "chrom $chrom mostfreq $most_freq\n";	
}

open(IN, "<$goodnames");
open(OUT, ">$goodnames.mostscaff");
while(!eof(IN)){
	$line = readline *IN;
	chomp $line;
	if ($line =~ m/^CHROM/){
		print OUT $line."\n";
	}else{
		@temp = split/\t/, $line;
#		print $chrom_mostfreq{$temp[0]}."\n";
		$temp[0] = $chrom_mostfreq{$temp[0]};
		$line = join("\t", @temp);
		print OUT $line."\n";
	}
}
