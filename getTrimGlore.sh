#!/bin/sh
#SBATCH -c 1
#SBATCH -p short
#SBATCH -t 0-5:45
#SBATCH -e %j.err
#SBATCH -o %j.out
#SBATCH --mem 10G
module load gcc/6.2.0 python/2.7.12  cutadapt/1.14  fastqc/0.11.9 trimgalore/0.6.6
trim_galore --paired -a AGATCGGAAGAGCG --stringency 6 -e 0.1 -q 20 --length 20 --fastqc -o $3 $1 $2 # $1 and $2 are paired end fastq files. $3 is the output folder
