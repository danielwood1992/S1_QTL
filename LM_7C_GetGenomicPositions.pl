my $summary="/scratch/b.bssc1d/Linkage_Mapping/LM_6_LepMap3/QB/OrderSummary.Y%m_14.txt.sum";
my $parentcall="/scratch/b.bssc1d/Linkage_Mapping/LM_6_LepMap3/QB/QB_Parents_F2s.vcf.ped.parentcall";

open(IN, "<$parentcall");
my $i = 0;
my ($line, %hash, @temp);
while(!eof(IN)){
	$line = readline *IN;
	chomp $line;
	@temp = split/\t/, $line;
	if ($line =~ m/^#CHROM/){
	}else{
		$i++;
		$hash{$i} = "$temp[0]\t$temp[1]";
	}
}
print "1\n";
open(IN, "<$summary");
my ($line2);
while(!eof(IN)){
	$line = readline *IN;
	chomp $line;
	@temp = split/\t/, $line;
	open(IN2, "<$temp[1]");	
	open(OUT2, ">$temp[1].gp");
	print "$temp[1].gp\n";
	my $LG = $temp[1];
	$LG =~ s{^.*/}{};
	print $LG."\n";
	$i = 0;
	while(!eof(IN2)){
		$line2 = readline *IN2;
		chomp $line2;
	
		if ($line2 =~ m/^#/){
			if ($line2 =~ m/^#marker_number/){
				$line2 =~ s/^#marker_number/#LG\tchrom\tpos\tmarker_number/g;
				print OUT2 $line2."\n";	
			}else{
				print OUT2 $line2."\n";
			}
		}else{
			@temp2 = split/\t/, $line2;
			print OUT2 "$LG\t$hash{$temp2[0]}\t$line2\n";	
		}		
	}
}
