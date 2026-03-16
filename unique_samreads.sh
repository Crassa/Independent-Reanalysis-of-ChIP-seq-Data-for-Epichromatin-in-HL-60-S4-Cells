#!/bin/sh
#SBATCH -c 6
#SBATCH -p short
#SBATCH -t 0-12:00
#SBATCH -e %j.err
#SBATCH -o %j.out
#SBATCH --mem 10G
module load samtools/1.3.1
samtools view -q 20 -F 1024 -o $2 -b -h  $1

