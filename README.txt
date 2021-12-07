#Some comment
LM\_2\_bwamap.sh - maps QTL files to genome (02/12/21 done QB)
LM\_3\_SNPCalling.sh - calls SNPs on these files (02/12/21 done QB) 
LM\_4.1\_checkSNPs.sh - checks the SNPs for the QTL files at various stages, produces some stats 
LM\_4.2\_CallParentSNPs.sh - calls the SNPs for the parent genome files (done 02/12/21)
LM\_4.3\_FilterParentSNPs.sh - filters the SNPs for parent genome files (done 02/12/21)
LM\_4.5A\_mergeparents.sh - merges SNPs from parents. Filters by biallelic SNPs, then ensures at least one homozygote present. (running QB 02/12/21)
LM\_4.5B\_mergeF2sParents.sh - merges the merged parent SNPs, and the SNPs from the F2s into one file... 
LM\_4\_mergefilter.sh - merges and further filters the SNPs from the genotyped F2s (done QB 02/12/21)
LM\_5\_PreparePedigree.pl - this converts the joint vcf from LM_4.5B into the .ped format used for LepMap3. See https://sourceforge.net/p/lep-map3/wiki/LM3%20Home/ for specification.
LM\_6\_Lepmap3.sh - so this removes segregation distorted markers. It also removes noninformative markers, which might be important. 
LM\_6B\_summarise.pl - summarises the results for each run. Called within the LM-6 script.
LM\_7\_LepMap3\_FindBestOrder.sh - gets a random initial marker order from LM_6C. Then orders markers based off this. Then uses LM_7B to get the best orders out of your (10, say) iterations.
LM\_6C\_order2markers.pl - this gets a random initial marker order. 
LM\_7B\_BestOrderPerChrom.pl - this then gets the best marker order per chromosome.


LM\_8A\_changenames.pl
LM\_8B\_verticaljoin.pl
LM\_8\_QTLprep.sh
LM\_bz2\_list.txt
LM\_Commands.sh
LM\_Parents
