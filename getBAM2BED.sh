#!/bin/sh
#SBATCH -c 6
#SBATCH -p short
#SBATCH -t 0-12:00
#SBATCH -e %j.err
#SBATCH -o %j.out
#SBATCH --mem 10G
module load bedtools/2.27.1
bedtools bamtobed -bedpe -i $1 >$2


