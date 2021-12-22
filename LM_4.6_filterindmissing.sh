module load bcftools;
my_vcf=$1;
thresh=$2;

#if the stats file doesn't exist, create it.
if [ ! -f $my_vcf.stats ]; then
	bcftools stats -s - $my_vcf > $my_vcf.stats;
fi

#get total number of snps
snp_num=$(grep "SN.*number of SNPs" $my_vcf.stats | cut -f4);
echo $snp_num;
to_keep=$(perl /home/b.bssc1d/scripts/S1_QTL/sub_LM_4.6_permissing.pl $my_vcf.stats $snp_num $thresh);
bcftools view -s $to_keep $my_vcf -Ov -o $my_vcf.$thresh && bcftools stats -s - $my_vcf.$thresh > $my_vcf.$thresh.stats;

