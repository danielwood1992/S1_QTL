use POSIX;
use strict;

#Give it your marker file (SeparateChromosomes2/JoinSingles2All output) and the relevant linkage group (mostly 0, I'd imagine). Will then produce a vcf with these markers...

my $map=$ARGV[0];
my $LG=$ARGV[1];
my $parentcall="/scratch/b.bssc1d/Linkage_Mapping/LM_6_LepMap3/QB/QB_Parents_F2s.vcf.ped.parentcall";
my $vcf="/scratch/b.bssc1d/Linkage_Mapping/LM_4.2_ParentCalls/QB_Parents_F2s.vcf";

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
open(IN, "<$map");
$i = 0;
my (%hash2);
while(!eof(IN)){
	$line = readline *IN;
	chomp $line;

	if ($line =~ m/^#/){
	}else{
		$i++;
		@temp = split/\t/, $line;
		if ($temp[0] eq $LG){
			$hash2{$hash{$i}} = "";	 #HASH:CHROM\tPOS	
		}
	}		
}

#So this then should give you a hash of the chromosomes;
my $woof = (keys %hash2)[0];
print $woof."\n";

open(IN, "<$vcf");
open(OUT, ">$vcf.LG$LG.vcf");
my ($chrompos);
while(!eof(IN)){
	$line = readline *IN;
	chomp $line;
	if ($line =~ m/^#/){
		print OUT $line."\n";
	}else{
		@temp = split/\t/, $line;
		$chrompos = $temp[0]."\t".$temp[1];
		if (exists ($hash2{$chrompos})){
			print OUT $line."\n";
		}
	}
}
