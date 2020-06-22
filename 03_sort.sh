#!/bin/bash

module add UHTS/Analysis/samtools/1.8;
SRR_exp=$1
FILES=$(find ./$SRR_exp/bam/ -type f -name "*.bam")
echo $FILES
for f in $FILES
do
  echo "Sorting $f..."
  target_name=${f##*/}
  target_name=${target_name%.bam}
#  echo $target_name
  samtools sort $f > ./$SRR_exp/bam/${target_name}_sorted.bam
  echo "Indexing $f..."
  samtools index ./$SRR_exp/bam/${target_name}_sorted.bam
  rm $f
done
module rm UHTS/Analysis/samtools/1.8;
