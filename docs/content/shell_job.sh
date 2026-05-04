#!/bin/bash
#SBATCH --time=00:05:00
#SBATCH --mem-per-cpu=1G
#SBATCH --cpus-per-task=1
#SBATCH --job-name="marias_lm"
module load r/4.5.0
Rscript shell_script.R

