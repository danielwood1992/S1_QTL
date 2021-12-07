#Some comment
LM_2_bwamap.sh - maps QTL files to genome (02/12/21 done QB)
LM_3_SNPCalling.sh - calls SNPs on these files (02/12/21 done QB) 
LM_4.1_checkSNPs.sh - checks the SNPs for the QTL files at various stages, produces some stats 
LM_4.2_CallParentSNPs.sh - calls the SNPs for the parent genome files (done 02/12/21)
LM_4.3_FilterParentSNPs.sh - filters the SNPs for parent genome files (done 02/12/21)
LM_4.5A_mergeparents.sh - merges SNPs from parents. Filters by biallelic SNPs, then ensures at least one homozygote present. (running QB 02/12/21)
LM_4.5B_mergeF2sParents.sh - merges the merged parent SNPs, and the SNPs from the F2s into one file... 
LM_4_mergefilter.sh - merges and further filters the SNPs from the genotyped F2s (done QB 02/12/21)
LM_5_PreparePedigree.pl - this converts the joint vcf from LM_4.5B into the .ped format used for LepMap3. See https://sourceforge.net/p/lep-map3/wiki/LM3%20Home/ for specification.
LM_6_Lepmap3.sh - so this removes segregation distorted markers. It also removes noninformative markers, which might be important. 
LM_6B_summarise.pl - summarises the results for each run. Called within the LM-6 script.
LM_7_LepMap3_FindBestOrder.sh - gets a random initial marker order from LM_6C. Then orders markers based off this. Then uses LM_7B to get the best orders out of your (10, say) iterations.
LM_6C_order2markers.pl - this gets a random initial marker order. 
LM_7B_BestOrderPerChrom.pl - this then gets the best marker order per chromosome.


LM_8A_changenames.pl
LM_8B_verticaljoin.pl
LM_8_QTLprep.sh
LM_bz2_list.txt
LM_Commands.sh
LM_Parents
