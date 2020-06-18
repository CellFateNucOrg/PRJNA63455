# PRJNA63455
Modencode epigenetics data set. 
3
Full meta-data table for PRJNA63455 modEncode epigenetics downloaded from www (**_SraRunTable-PRJNA63455.txt_**)

The explored and processed wtih _sortMetadata.R_. This script produces:
1) A tidy table with consistent annotation in **_PRJNA63455_L3tidy.csv_**
2) A simpler file with matched input and ips on single line (separate columns for ips that need to be merged first) in **_PRJNA63455_L3_forpipeline.csv_**

```
"inputs","ips2merge","ips","basename"
"SRR947267","NA","SRR947268","FKH-2_rep1_L3_herm__SRR947267vSRR947268"
"SRR947269","SRR947270;SRR947271","NA","FKH-2_rep2_L3_herm__SRR947269vSRR947270-SRR947271"
"SRR947272","NA","SRR947273","MML-1_rep1_L3_herm__SRR947272vSRR947273"
```

