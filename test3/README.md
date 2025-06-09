[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/Vs0k_bZI)
| Organization              | Course                         | Exercise         | Semester    | Professor                                               | T.A.                                                                     |
| ------------------------- | ------------------------------ | ---------------- | ----------- | ------------------------------------------------------- | ------------------------------------------------------------------------ |
| Seoul National University | Introduction to Bioinformatics | RNA-seq analysis | Spring 2025 | Asst. Prof. M. Steinegger (martin.steinegger@snu.ac.kr) | Victor Mihaila (steineggerlab.ta.2025@gmail.com) <br /> Sooyoung Cha (steineggerlab.ta.2025@gmail.com) |

# Exercise06: RNA-seq analysis pipeline

## About the exercise

In this exercise, you will practice RNA-seq analysis using human chromosome X data from two populations:  English from Great Britain and Yoruba from Ibadan, Nigeria. 
The pipeline will follow mapping RNA-seq reads to the reference genome, assembling transcripts and then quantifying gene expression. In addition, you will learn how to identify differentially expressed gene and visualize the results.

This assignment requires around 3GB of storage space so please free as much of the space on your Google Cloudshell as possible. You can always recover your solutions to the previous assignments from Github. 

## Tools for the exercise

### HISAT2 : [link for manual](http://daehwankimlab.github.io/hisat2/manual/)
HISAT2 is an alignment program for mapping NGS reads (whole-genome, transcriptome, and exome sequencing data) against the general human population (as well as against a single reference genome).
- Input
   - hisat2 index for the reference genome
   - Sequencing read files (usually paired-end; _1.fastq, _2.fastq)
- Output
   - Alignment in SAM format

### SAMtools: [link for manual](http://www.htslib.org/doc/samtools.html)
Samtools is a set of utilities that manipulate alignments in the SAM (Sequence Alignment/Map), BAM, and CRAM formats. It converts between the formats, does sorting, merging and indexing, and can retrieve reads in any regions swiftly.

### StringTie: [link for manual](https://ccb.jhu.edu/software/stringtie/index.shtml?t=manual)
StringTie is a fast and efficient assembler of RNA-Seq alignments into potential transcripts.
- Input: BAM file with RNA-Seq read mappings (must be sorted)
- Output
   - GTF files containing the assembled transcripts
   - GTF files containing requantified transcript expression with merged assemblies from multiple samples

### pyDEseq2: [link for manual](https://pydeseq2.readthedocs.io/en/latest/)
The pyDESeq2 package is python version of the R package DEseq2. It is designed for normalization, visualization, and differential analysis of high dimensional count data. It makes use of empirical Bayes techniques to estimate priors for log fold change and dispersion, and to calculate posterior estimates for these quantities.

---
## command01.sh
1. Download all of the required data for this assignment from this [link](https://hulk.mmseqs.com/introbioinfo/chrX_data.tar.gz), then uncompress the archive inside your *data* directory. 

The directory *chrX_data* will contain several subdirectories and files. Here is a short explaination on all of them:

-   *genes* contains **chrX.gtf** which is the gtf file of the human X chromosome
-   *genome* contains **chrX.faa** which has the sequence of the human X chromosome
-   *indexes* contains the HISAT2 indexes of the human X chromosome
-   *samples* contains the reads that you will be working with in this assignment
-   **geuvadis_phenodata.csv** has information about the four different samples you will be working with and is neccesary to run pyDEseq2
-   **mergelist.txt** is an auxiliary file for one of the later questions

2. Map the paired-end reads of four samples to the human X chromosome with **HISAT2**.
   Save the alignment result as `ERR188044_chrX.sam`, `ERR188257_chrX.sam`, `ERR188273_chrX.sam`, and `ERR188428_chrX.sam` in **data** directory. You shouldn't push these files to GitHub but you will use them in later questions.
   - Input
      - `./data/data/chrX_data/samples/ERR188044_chrX_1.fastq.gz`, `./data/chrX_data/samples/ERR188044_chrX_2.fastq.gz`
      - `./data/chrX_data/samples/ERR188257_chrX_1.fastq.gz`, `./data/chrX_data/samples/ERR188257_chrX_2.fastq.gz`
      - `./data/chrX_data/samples/ERR188273_chrX_1.fastq.gz`, `./data/chrX_data/samples/ERR188273_chrX_2.fastq.gz`
      - `./data/chrX_data/samples/ERR188428_chrX_1.fastq.gz`, `./data/chrX_data/samples/ERR188428_chrX_2.fastq.gz`
   - Output
      - `./data/ERR188044_chrX.sam`
      - `./data/ERR188257_chrX.sam`
      - `./data/ERR188273_chrX.sam`
      - `./data/ERR188428_chrX.sam`

## command02.sh

Sort the SAM files generated in the previous step and compress them to the BAM format using exactly 8 threads. This can be done in one step using `samtools sort`. Once again, no result file is expected but you will be using these files in further questions. 

   - Input
      - `./data/ERR188044_chrX.sam`
      - `./data/ERR188257_chrX.sam`
      - `./data/ERR188273_chrX.sam`
      - `./data/ERR188428_chrX.sam`
   - Output
      - `./data/ERR188044_chrX.bam`
      - `./data/ERR188257_chrX.bam`
      - `./data/ERR188273_chrX.bam`
      - `./data/ERR188428_chrX.bam`

## command03.sh

Assemble transcripts for `./data/ERR188044_chrX.bam`, `./data/ERR188257_chrX.bam`, `./data/ERR188273_chrX.bam`, and `./data/ERR188428_chrX.bam` with **StringTie**. Save the output files(**ERR188044_chrX.gtf**, **ERR188257_chrX.gtf**, **ERR188273_chrX.gtf**, **ERR188428_chrX.gtf**) to the `result` directory.
   - Input
      - BAM files
        - `./data/ERR188044_chrX.bam`
        - `./data/ERR188257_chrX.bam`
        - `./data/ERR188273_chrX.bam`
        - `./data/ERR188428_chrX.bam`
      - Guide GTF file: `./data/chrX_data/genes/chrX.gtf`
   - Output
         - `./result/ERR188044_chrX.gtf`, `./result/ERR188257_chrX.gtf`, `./result/ERR188273_chrX.gtf`, `./result/ERR188428_chrX.gtf`
   > Use the `-G` option to provide the guide GTF file.

## command04.sh

To requantify transcript expression, we will merge the reconstructed transcriptomes from four samples and then quantify the merged transcriptome.

1. Merge the GTF files from previous step with **StringTie**. Save the merged GTF file as `./result/stringtie_merged.gtf`. You can use **./data/chrX_data/mergelist.txt** as an argument for `stringtie merge`. 

2. Requantify transcript expression with **StringTie**. Save gtf files in the `./data/ballgown/` directory.
   
   - Input
      - BAM files
        - `./data/ERR188044_chrX.bam`
        - `./data/ERR188257_chrX.bam`
        - `./data/ERR188273_chrX.bam`
        - `./data/ERR188428_chrX.bam`
      - Merged gtf: `./result/stringtie_merged.txt`
    - Output
        - `./data/ballgown/ERR188044/ERR188044_chrX.gtf`
        - `./data/ballgown/ERR188257/ERR188257_chrX.gtf`
        - `./data/ballgown/ERR188273/ERR188273_chrX.gtf`
        - `./data/ballgown/ERR188428/ERR188428_chrX.gtf`

3. Get top 5 highly expressed **transcripts** (based on TPM) from the requantified gtf files.
   Save gene_id, gene_name and TPM of top 5 transcripts to `./result/ERR188044_chrX.top5.tsv` and `./result/ERR188257_chrX.top5.tsv`, `./result/ERR188273_chrX.top5.tsv`, `./result/ERR188428_chrX.top5.tsv`.

   > - Only consider genes with gene names (Ignore transcripts without gene names)
   > - Results should be sorted by TPM in descending order.
   ```e.g.
   MSTRG.1  ABCD  12345.5000
   MSTRG.2  BCDE  12344.4000
   MSTRG.3  CDEF  12343.3000
   MSTRG.4  DEFG  12342.2000
   MSTRG.5  EFGH  12341.1000
   ```
   
   - Input: 
        - `./data/ballgown/ERR188044/ERR188044_chrX.gtf`
        - `./data/ballgown/ERR188257/ERR188257_chrX.gtf`
        - `./data/ballgown/ERR188273/ERR188273_chrX.gtf`
        - `./data/ballgown/ERR188428/ERR188428_chrX.gtf`

   - Output: 
        - `./result/ERR188044_chrX.top5.tsv`
        - `./result/ERR188257_chrX.top5.tsv`
        - `./result/ERR188273_chrX.top5.tsv`
        - `./result/ERR188428_chrX.top5.tsv`


## command05.sh
In this stage, you will learn how to analyze Differential Expression (DE) with pyDESeq2. After the analysis, you will visualize the expression result with volcano plot. Since the analysis and visualization require knowledge of R or Python, we will provide the sourcecodes(run_pydeseq.py, make_volcano.py). Instead of writing the code, you should provide arguments to run the sourcecodes.

Using the data of previous step, we will compare the gene expressions between the two sexes. 

1. To prepare differential expression analysis, you should convert the Stringtie output into a format that can be used by DESeq2. Stringtie provides code to generate input files for DESeq2. Use `prepDE.py` to convert the stringtie output into a format that can be used by DESeq2. Save the result files into `./result` directory.
   - Input: `./source/prep_deseq.txt`
   - Output: `./result/gene_count_matrix.csv`, `./result/transcript_count_matrix.csv`
  
   > **copy and paste** following command to command file
      ```sh
      prepDE.py -i source/prep_deseq.txt
      ```
   > move output files to the result directory or use `-g` and `-t` options of prepDE.py to specify output directory

2. With the output file of previous step, run pyDEseq2 using code `./source/run_pydeseq.py`. To run the tool properly, you should specify options. Save the result file as **deseq2_results.csv**. Since we want to look at differential expression between males and females, specify `sex` as the factor. 

   - Input: `./result/gene_count_matrix.csv`
   - Output: `./result/deseq2_results.csv`
   - command usage:
      ```sh
      python source/run_pydeseq.py -i <inputfile> -o <output_file> -f <factor>
      ```
      - `-i`, `-o`, and `-f` are required.
      - `-f`: You should specify **factor to compare**. You can find appropriate factor among column names of `data/chrX_data/geuvadis_phenodata.csv`. This is case sensitive.
      - `-s`: is optional. You can enhance False Positve Rate and visualization with this option.
      - `-h`: For details of options and usage, use `-h` option.
  
3. From the result of pyDEseq2 (`./result/deseq2_results.csv`), save the **number** of overexpressed genes.
   Save the result file as **overexpressed_genes.txt**. (Result file: **overexpressed_genes.txt**)
  > - No threshold for overexpression. Just extract all the gene ids of overexpressed genes.

4. Using the result file of pyDEseq2, make a volcano plot. Save the plot as **volcano.png**. (Result file: **volcano.png**)
   - Input: `./result/deseq2_results.csv`
   - Output: `./result/volcano.png`
   - command usage:
      ```sh
      python source/make_volcano.py -i <inputfile> -o <output_file> -x <x_axis> -y <y_axis>
      ```
      - `-i`, `-o`, `-x`, and `-y` are mandatory.
      - `-x`: You should specify **x-axis** of plot. You can find appropriate factor among column names of the input file. This is case sensitive and please use exactly same name as input file.
      - `-y`: You should specify **y-axis** of plot. You can find appropriate factor among column names of the input file. This is case sensitive and please use exactly same name as input file.
      - `-c`: is optional. You can color significant genes(based on adjusted p-value) in red with this option.
      - `-t`: is optional. You can modify threshold to color significant genes based on adjusted p-value. Default is 0.05.
      - `-h`: For details of options and usage, use `-h` option.

   > Refer to the plot on lecture slide. (19 RNA-seq differential gene expression - page 27)

5. Sort `./result/deseq2_results.csv` in increasing order of the adjusted p-values and extract the genes whose adjusted p-value is lower than 0.05. Print the identifier and the padj values separated by a tab in `./result/significan_genes.tsv`. 

> - Genes should be sorted in increasing order of their padj
```e.g.
MSTRG.1  1e-100
MSTRG.2  2e-100
MSTRG.3  3e-100
MSTRG.4  1e-10
MSTRG.5  2e-10
```


You will notice that some of them correspond to known genes. Find the function of these genes and write it in `./result/conclusion.txt`. In the same file also write your conclusion about this analisys. Do these results make sense? Are there any isues with the methodology we used to reach these results?

   - Input: `./result/deseq2_resuls.csv`
   - Output: `./result/significant_genes.tsv`, `./result/conclusion.txt`


---

*Reference*
   - Pertea, M., Kim, D., Pertea, G. et al. Transcript-level expression analysis of RNA-seq experiments with HISAT, StringTie and Ballgown. Nat Protoc 11, 1650–1667 (2016). https://doi.org/10.1038/nprot.2016.095
