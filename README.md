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

"inputs" column contains multiple input files taht must always be merged.
"ips2merge" column contains multiple ips from same sample that must be merged
"ips" contains 1 or more ips taht must each be mapped separately to the inputs. If "NA" that is because merged ips should be mapped. 
"basename" is a descriptive name for output files (SRR numbers ensure that badly numbered replicates are not overwritten). 
