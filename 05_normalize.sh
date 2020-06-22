#!/bin/bash
module add R/3.6.1;
SRR_exp=$1
[ ! -d ./$SRR_exp/norm ] && mkdir ./$SRR_exp/norm
[ ! -d ./$SRR_exp/enrichment ] && mkdir ./$SRR_exp/enrichment

Rscript 05_normalize.R $SRR_exp
