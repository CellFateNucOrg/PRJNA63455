#!/bin/bash
module add UHTS/Analysis/sratoolkit/2.10.7;

#$1 is the full filename (with directory location) of the csv file with the ChIP set SRR info
#$2 is the SRR numbers of the IP dataset to map
#$3 is the SRR numbers of the input datasets to map
SRR_exp=$1
SRR_IP=$2
SRR_input=$3
echo $1
echo $2
echo $3
#create folder for SRR download if it does not exists
[ ! -d $SRR_exp/SRR_download ] && mkdir $SRR_exp/SRR_download
[ ! -d $SRR_exp/SRR_download/IP ] && mkdir $SRR_exp/SRR_download/IP
[ ! -d $SRR_exp/SRR_download/input ] && mkdir $SRR_exp/SRR_download/input
echo "Downloading IP: $SRR_IP"
prefetch -O $SRR_exp/SRR_download/IP/ -o $SRR_IP.srr $SRR_IP
fasterq-dump -O $SRR_exp/SRR_download/IP -t ./tmp/ $SRR_IP.srr
#fastq-dump -gzip -O $SRR_exp/SRR_download/IP $SRR_IP
echo "Downloading input: $SRR_input"
prefetch -O $SRR_exp/SRR_download/input -o $SRR_input.srr $SRR_input
fasterq-dump -O $SRR_exp/SRR_download/input -t ./tmp/ $SRR_input.srr
#fastq-dump -gzip -O $SRR_exp/SRR_download/input $SRR_input
echo "This is over"

module rm UHTS/Analysis/sratoolkit/2.10.7;
