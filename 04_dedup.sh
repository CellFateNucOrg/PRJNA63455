#!/bin/bash
module add UHTS/Analysis/picard-tools/2.21.8;
module add UHTS/Analysis/samtools/1.8;
SRR_exp=$1
[ ! -d ./$SRR_exp/dedup ] &&  mkdir ./$SRR_exp/dedup

FILES=$(find ./$SRR_exp/bam/ -type f -name "*_sorted.bam")
for f in $FILES
  do
  target_name=${f##*/}
  target_name=${target_name%.bam}
  echo $target_name
  if [ ! -f ./$SRR_exp/dedup/${target_name}_dedup.bam ]; then
  echo "Removing duplicates from $f..."
  picard-tools MarkDuplicates I=$f O=./$SRR_exp/dedup/${target_name}_dedup.bam M=./$SRR_exp/dedup/${target_name}_dedup.txt REMOVE_DUPLICATES=true REMOVE_SEQUENCING_DUPLICATES=true TMP_DIR=./ VALIDATION_STRINGENCY=LENIENT
  echo "Sorting deduplicated $f"
  samtools sort ./$SRR_exp/dedup/${target_name}_dedup.bam > ./$SRR_exp/dedup/${target_name}_dedup_sorted.bam
  echo "Indexing deduplicated $f"
  samtools index ./$SRR_exp/dedup/${target_name}_dedup_sorted.bam
  rm ./$SRR_exp/dedup/${target_name}_dedup.bam
  fi
done

module rm UHTS/Analysis/picard-tools/2.21.8;
module rm UHTS/Analysis/samtools/1.8;
