#!/bin/bash
#SBATCH --mail-user=peter.meister@izb.unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --array=3-99%10
#SBATCH --job-name="ChIP_seq_modENCODE"
#SBATCH --time=2-12:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=8G

echo "Line $SLURM_ARRAY_TASK_ID"
sh wrapper.sh SRR_names.csv $SLURM_ARRAY_TASK_ID


