import glob 
import os
import pandas as pd

configfile: "config.yaml"

list_of_samples = pd.read_table(config["samplesheet"])
samples = list(list_of_samples.Samples.unique())


include: "rules/download_samples_or_copy.smk"
include: "rules/kraken2_mapping.smk"
include: "rules/cellranger.smk"
include: "rules/kraken_processing.smk"
include: "rules/extract_bam.smk"
include: "rules/extract_tags.smk"
include: "rules/report.smk"

rule all:
    input:
            expand("data/{sample}/{sample}_S1_L001_R1_001.fastq.gz", sample=samples),
            expand("data/{sample}/{sample}_S1_L001_R2_001.fastq.gz", sample=samples),
            expand("results/kraken2/{sample}.kraken",sample=samples),
            expand("results/kraken2/{sample}.report.txt",sample=samples),
            expand("results/cellranger/{sample}/{sample}/",sample=samples),
            expand("results/kraken_reads/{sample}_kraken_reads.sam", sample=samples),
            expand("results/cellranger/{sample}/possorted_genome_bam.bam", sample=samples),
            expand("results/cellranger/{sample}/unmapped_reads.sam", sample=samples),
            expand("results/count_matrix/{sample}/count_matrix.tsv", sample=samples),
            expand("results/count_matrix/{sample}/kraken_reads_count_matrix.tsv",sample=samples),
            "results/kraken_plots/Familywise_tax_readcounts.tsv",
            "results/kraken_plots/Specieswise_tax_readcounts.tsv",
            "results/kraken_plots/Clustermap_Familywise_log10.png",
            "results/kraken_plots/Clustermap_Specieswise_log10.png"

onsuccess:
    print("sc-VirusScan Pipeline finished successfully!")

onerror:
    print("sc-VirusScan Pipeline has failed!")
