import glob 
import os
import pandas as pd

configfile: "config.yaml"

accession_list = pd.read_table("SRA.tsv")
samples = list(accession_list.Samples.unique())


include: "rules/download_samples_or_copy.smk"
include: "rules/kraken2_mapping.smk"
include: "rules/cellranger.smk"
include: "rules/extract_bam.smk"
include: "rules/extract_tags.smk"

rule all:
    input:
            expand("data/{sample}/{sample}_S1_L001_R1_001.fastq.gz", sample=samples),
            expand("data/{sample}/{sample}_S1_L001_R2_001.fastq.gz", sample=samples),
            expand("data/{sample}_test.txt",sample=samples),
            expand("results/kraken2/{sample}/{sample}.kraken",sample=samples),
            expand("results/kraken2/{sample}/{sample}.report.txt",sample=samples),
            expand("results/kraken2/{sample}/{sample}_classified_out.fastq",sample=samples),
            expand("results/cellranger/{sample}/{sample}_finished.txt",sample=samples),
            expand("results/cellranger/{sample}/unmapped_reads.sam", sample=samples),
            expand("results/count_matrix/{sample}/count_matrix.tsv", sample=samples)

onsuccess:
    print("Snakemake finished successfully!")

onerror:
    print("Snakemake has failed!")    
      
