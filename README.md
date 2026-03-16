# Independent-Reanalysis-of-ChIP-seq-Data-for-Epichromatin-in-HL-60-S4-Cells
Computational pipeline for reanalysis of epichromatin ChIP-seq data from HL-60/S4 cells originally published by Olins et al., 2014 (PMID: 24824428)
This dataset represents an independent computational reanalysis of publicly available ChIP-seq data for epichromatin in HL-60/S4 cells. The raw sequencing reads were originally generated and published by Olins et al., 2014 (PMID: 24824428) and are available from the BioProject PRJEB5782 or through ArrayExpress Experiments Archive at www.ebi.ac.uk with accession numbers E-MTAB-2360. The individual SRA accession numbers are: ERR453857, ERR453851, ERR453853, ERR453859, ERR453847, ERR453855, ERR453858, ERR453844.
The ChIP-seq samples were analyzed using matched control samples for each experiment as follows: ERR453856 served as the control for ERR453847, ERR453850 served as the control for ERR453858, ERR453846 served as the control for ERR453851, ERR453854 served as the control for ERR453857, ERR453852 served as the control for ERR453859, ERR453845 served as the control for ERR453853, ERR453848 served as the control for ERR453844, and ERR453849 served as the control for ERR453855.
1. Read Trimming
Raw paired-end sequencing reads were trimmed to remove adaptor sequences using TrimGalore (version 0.6.6) with the following command:
trim_galore --paired -a AGATCGGAAGAGCG --stringency 6 -e 0.1 -q 20 --length 20 --fastqc -o <output_folder> <input_read1.fastq> <input_read2.fastq>
•	<input_read1.fastq> and <input_read2.fastq> represent the paired-end raw FASTQ files.
•	<output_folder> is the directory for trimmed output files.
Trimming criteria:
•	Minimum overlap of 6 bp between the adaptor and read (--stringency 6).
•	Maximum 10% mismatch in adaptor alignment (-e 0.1).
•	Bases with Phred quality <20 at read ends were removed (-q 20).
•	Reads shorter than 20 bp were discarded (--length 20).
The --fastqc option generated a post-trimming quality report.
2. Alignment to Reference Genome
Trimmed reads were aligned to the human genome (hg19) using Bowtie2 (version 2.3.4.3) with the following command:
bowtie2 -p 8 -I 80 -X 500 --no-mixed -3 1 -x <bowtie2_index_prefix> -1 <trimmed_read1.fastq> -2 <trimmed_read2.fastq> -S <output.sam>
•	<bowtie2_index_prefix> is the path to the indexed hg19 genome.
•	<trimmed_read1.fastq> and <trimmed_read2.fastq> are the trimmed paired-end reads.
•	<output.sam> is the aligned SAM file output.
Parameters:
•	-p 8: use 8 threads.
•	-I 80 -X 500: select fragments with minimum 80 bp and maximum 500 bp insert size.
•	--no-mixed: retain only pairs where both reads align.
•	-3 1: trim 1 bp from the 3’ end of both reads before alignment.
3. Filtering Unique Alignments
Aligned SAM files were filtered to retain high-quality, unique alignments using Samtools (version 1.3.1):
samtools view -q 20 -F 1024 -o <output.bam> -b -h <input.sam>
•	<input.sam> is the Bowtie2-aligned SAM file.
•	<output.bam> is the filtered BAM file.
Options:
•	-q 20: retain reads with mapping quality ≥ 20 (approximately 1% chance of incorrect alignment).
•	-F 1024: remove PCR duplicates.
•	-b: output in BAM format.
•	-h: include header in BAM output.
4. Converting BAM to BEDPE
Filtered BAM files were converted to BEDPE format using Bedtools (version 2.27.1):
bedtools bamtobed -bedpe -i <input.bam> > <output.bed>
•	<input.bam>: filtered BAM file.
•	<output.bed>: BEDPE file containing paired-end coordinates.
5. Selecting Plus-Strand Reads
From the BEDPE file, columns 1, 2, 3, 7, 8, and 9 were selected to generate a BED file specific to plus-strand reads. These plus-strand BED files were used for peak calling.
6. Peak Calling with SICER
Peak calling was performed using SICER with the following command:
sicer -t <treatment_plus_strand.bed> -c <control_plus_strand.bed> -s hg19 -w 200 -egf 0.85 -fdr 0.01
•	<treatment_plus_strand.bed>: plus-strand BED file of the treatment sample.
•	<control_plus_strand.bed>: plus-strand BED file of the control sample.
Parameters:
•	-s hg19: use hg19 reference genome.
•	-w 200: sliding window size of 200 bp for scanning enriched regions.
•	-egf 0.85: effective genome fraction; 85% of the genome is mappable.
•	-fdr 0.01: peaks are called only if the false discovery rate (FDR) <1%.
SICER identifies clusters of reads enriched in treatment versus control and filters out background noise.

