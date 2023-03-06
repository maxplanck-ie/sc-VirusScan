import glob 
import os
import pandas as pd

#configfile = "/data/manke/processing/momin/virome-scan/workflow/config.yaml",
data_dir = "/data/manke/processing/momin/virome-scan/workflow"

accession_list = pd.read_table("SRA.tsv")
samples = list(accession_list.Samples.unique())


rule all:
    input:
        expand("data/{sample}_1.fastq.gz", sample=samples),
        expand("data/{sample}_2.fastq.gz", sample=samples),
        expand("results/whitelist/{sample}_whitelist.txt", sample=samples),
        expand("results/umi/{sample}_R1_extracted.fastq.gz",sample=samples),
        expand("results/umi/{sample}_R2_extracted.fastq.gz",sample=samples)


rule download_sample:
    output: 
        "data/{sample}_1.fastq.gz",
        "data/{sample}_2.fastq.gz"
    params:
        outdir = "data",
        threads = 8
    conda:
        "envs/tools.yaml"
    shell:
        "parallel-fastq-dump --sra-id {wildcards.sample} --split-files --threads {params.threads} --outdir {params.outdir}  --gzip"


rule whitelist_generation:
    input:
        i1 = "data/{sample}_1.fastq.gz",
    output:
        "results/whitelist/{sample}_whitelist.txt"
    conda:
        "envs/tools.yaml"
    log:
        "results/log/whitelist/{sample}_umi_extract.log"
    shell:
        "umi_tools whitelist --stdin {input.i1} --bc-pattern={config[bc_pattern]} --set-cell-number={config[cell_no]} --log2stderr > {output} 2> {log}"


rule umi_extract:
    input:
        i1 = "data/{sample}_1.fastq.gz",
        i2 = "data/{sample}_2.fastq.gz"
    output:
        o1 = "results/umi/{sample}_R1_extracted.fastq.gz",
        o2 = "results/umi/{sample}_R2_extracted.fastq.gz"
    params:
        p1 = "results/whitelist/{sample}_whitelist.txt"
    conda:
        "envs/tools.yaml"
    log:
        "results/log/umi/{sample}_umi_extract.log"
    shell:
        "umi_tools extract --stdin {input.i1} --bc-pattern=CCCCCCCCCCCCCCCCNNNNNNNNNN --stdout {output.o1} --read2-in {input.i2} --read2-out={output.o2} --whitelist={params.p1}"


rule alignment:
    input:
        i1 = "results/umi/{sample}_R1_extracted.fastq.gz",
        i2 = "results/umi/{sample}_R2_extracted.fastq.gz"
    output:
        o1 = "results/alignment/{sample}.sam"
    params:
        p1 = #TODO Path to Database #Config to the external Bowtie2 index ideally needs to be given by runtime config.
    conda:
        "envs/tools.yaml"
    threads: 16
    log:
        "results/log/alignment/{sample}_aln.log"
    shell:
        "bowtie2 -x {params.p1} -1 {input.i1} -2 {input.i2} --very-fast-local --no-unal -S {output.o1} -p {threads}"


onsuccess:
    print("Snakemake finished successfully!")

onerror:
    print("Snakemake has failed!")    
      
