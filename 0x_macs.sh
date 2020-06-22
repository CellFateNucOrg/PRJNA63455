#!/bin/bash
source /home/pmeister/MACS_env/bin/activate

if [ ! -d "macs" ]; then 
   mkdir macs
fi
FILES=./dedup/*_dedup_sorted.bam
for f in $FILES
  do
  echo $f
  target_name=${f##*/}
  target_name=${target_name%.bam}
  echo $target_name
  if [ ! -f ./macs/${target_name}.bedGraph ]; then
  echo "Piling up $f..."
  macs2 pileup -i $f -o ./macs/${target_name}.bedGraph -f BAM
  else 
  echo "Pileup for $f already present" 
fi
done

deactivate
