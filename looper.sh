#!/bin/bash
#SBATCH --mail-user=peter.meister@izb.unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --job-name="ChIP_seq_modENCODE"
#SBATCH --time=2-12:00:00
#SBATCH --cpus-per-task=4
#SBATCH --partition=all
#SBATCH --mem-per-cpu=8G

for i in {2..17}
do
    echo "Line $i"
    bash wrapper.sh SRR_names.csv $i
done

echo "This is really over"


