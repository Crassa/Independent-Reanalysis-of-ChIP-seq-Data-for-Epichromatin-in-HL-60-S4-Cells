#!/bin/sh
#SBATCH -c 8
#SBATCH -p short
#SBATCH -t 0-06:00
#SBATCH -e %j.err
#SBATCH -o %j.out
#SBATCH --mem 70G
module load gcc/6.2.0 bowtie2/2.3.4.3
bowtie2 -p 8 -I 80 -X 500 --no-mixed -3 1  -x /path_to/bowtie2_indexes/hg19  -1 $1 -2 $2 -S $3
