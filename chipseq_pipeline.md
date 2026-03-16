First, change the working directory to the location where the raw FASTQ files are stored. All analysis scripts should also be placed in the same directory.

To extract the base names of the paired-end FASTQ files, run the following command:

for fq in ERR*_1.fastq;do echo $fq;fq1=${fq%_1.fastq};base+=($fq1);done

This command removes the _1.fastq extension from the first read of each paired-end file and stores the base filename in an array named base.

To verify that the array was generated correctly, run:

for fq in ${base[*]};do echo $fq;done

The output will list all filenames without extensions, for example:

ERR453844
ERR453845
ERR453846
ERR453847
ERR453848
ERR453849
ERR453850
ERR453851
ERR453852
ERR453853
ERR453854
ERR453855
ERR453856
ERR453857
ERR453858
ERR453859

Next, perform adapter trimming using the trimming script:

for fq in ${base[*]};do echo $fq;sbatch getTrimGlore.run "$fq"_1.fastq "$fq"_2.fastq trimmed;done

This command submits trimming jobs for each paired-end dataset.

After trimming, align the reads to the reference genome using Bowtie2 by running:

for fq in ${base[*]};do echo $fq;sbatch getbowtie2_paired.run "$fq"_1_val_1.fq "$fq"_2_val_2.fq "$fq".sam;done

The output of this step will be alignment files in SAM format.

Next, select uniquely aligned reads from the SAM files by using the following command:

for fq in ${base[*]};do echo $fq;sbatch unique_samreads.run "$fq".sam "$fq"_uniq.sam;done

Next, convert the SAM files into BED format using the following command:

for fq in ${base[*]};do echo $fq;sbatch getBAM2BED.run "$fq"_uniq.sam "$fq".bed;done

After generating the BED files, extract the required columns using the following awk command:

awk 'BEGIN {OFS="\t"} {print $1,$2,$3,$7,$8,$9}' bedfile >output_plus.bed

This command selects columns 1–3 and 7–9 from the BED file and writes the output to output_plus.bed.

Finally, peak calling is performed using SICER to identify significantly enriched regions in the treatment sample compared to the control sample.

sicer -t treated.bed -c input.bed -s hg19 -w 200  -egf 0.85 -fdr 0.01

Here, hg19 refers to the human genome reference version used for the analysis.

SICER Output

The SICER program generates several output statistics summarizing the peak calling process. An example output is shown below:

Normalizing graphs by total island filtered reads per million and generating summary WIG file...

Finding candidate islands exhibiting clustering...

Species: hg19
Window_size: 200
Gap size: 600
E value is: 1000
Total read count: 4688489
Genome Length: 3095693983
Effective genome Length: 2631339885
Window average: 0.3563575368371692
Window pvalue: 0.2
Minimum num of tags in a qualified window: 2

Determining the score threshold from random background...
The score threshold is: 15.566

Generating the enriched probscore summary graph and filtering the summary graph to eliminate ineligible windows...

Total number of islands: 120685

Next, the significance of candidate islands is calculated using the control library:

Calculating significance of candidate islands using the control library...

ChIP library read count: 4688493
Control library read count: 6448192
Total number of chip reads on islands is: 1732680
Total number of control reads on islands is: 780276

Identify significant islands using FDR criterion

Given significance 0.01 , there are 107924 significant islands
Out of the 4688493 reads in ERR453847_plus.bed , 1545052 reads are in significant islands

Finally, the SICER program completes the analysis and removes temporary files:

End of SICER
Removing temporary directory and all files in it.
Program Finished Running