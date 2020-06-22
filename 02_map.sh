#!/bin/bash
module add UHTS/Analysis/samtools/1.8;
module add UHTS/Aligner/bwa/0.7.17;

SRR_exp=$1
FILES=$(find ./$SRR_exp/trimmed_fq/ -type f -name "*.fq.gz")
[ ! -d ./$SRR_exp/bam ] && mkdir ./$SRR_exp/bam
echo $FILES

for f in $FILES
do
  target_name=${f##*/}
  target_name=${target_name%.fq.gz}
#  echo $target_name
  if [ ! -f "./$SRR_exp/bam/${target_name}_sorted.bam" ]; then 
     echo "Mapping $f to ce11 using bwa aln..."
#     bowtie2 -p 2 --no-unal -q -x /home/pmeister/genome_masker/original_ce11/ce11 -U $f -S ./$SRR_exp/bam/${target_name}.sam > ./$SRR_exp/bam/${target_name}_alignment_report_bw2.txt
     bwa aln -t 8 /data/projects/p025/Peter/ChIP_seq/genome/ce11bwaidx $f > ./$SRR_exp/bam/${target_name}.sai
     bwa samse /data/projects/p025/Peter/ChIP_seq/genome/ce11.fa ./$SRR_exp/bam/${target_name}.sai $f > ./$SRR_exp/bam/${target_name}.sam
     echo "Converting $f SAM to BAM..."
     samtools view -S -b -q 20 ./$SRR_exp/bam/${target_name}.sam > ./$SRR_exp/bam/${target_name}.bam
     rm ./$SRR_exp/bam/${target_name}.sam
     rm ./$SRR_exp/bam/${target_name}.sai
    else
    echo "$f already mapped to ce11..."
##  rm ${f%.fq.gz}.sai
  fi
done
module rm UHTS/Analysis/samtools/1.8;
module rm UHTS/Aligner/bwa/0.7.17;
