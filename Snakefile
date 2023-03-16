import glob 
import os
import pandas as pd

#configfile = "/data/manke/processing/momin/virome-scan/workflow/config.yaml",
data_dir = "/data/manke/processing/momin/virome-scan/sc-virome-scan/data"


accession_list = pd.read_table("SRA.tsv")
samples = list(accession_list.Samples.unique())

"""
samples, = glob_wildcards("/data/manke/processing/momin/virome-scan/sc-virome-scan/data/{sample}_L001_R1.fastq.gz")
print(samples)
"""

#ruleorder: download_samples > cellranger > kraken2_mapping

if config["files"] == "local":
    include: "rules/kraken2_mapping_local.smk"

else:
    include: "rules/download_samples.smk" 
    include: "rules/kraken2_mapping.smk"

def input_files():
    if config["files"] == "local":
        l1 = [
            expand("results/kraken2/{sample}/{sample}.kraken",sample=samples),
            expand("results/kraken2/{sample}/{sample}.report.txt",sample=samples)]
        return(l1)
    else:
        l1 = [
            expand("data/{sample}_S1_L001_R1_001.fastq.gz", sample=samples),
            expand("data/{sample}_S1_L001_R2_001.fastq.gz", sample=samples),
            expand("data/{sample}_test.txt",sample=samples),
            expand("results/kraken2/{sample}/{sample}.kraken",sample=samples),
            expand("results/kraken2/{sample}/{sample}.report.txt",sample=samples)
        ]
        return(l1)

include: "rules/cellranger.smk"
include: "rules/extract_bam.smk"
include: "rules/extract_tags.smk"    
    

rule all:
    input:
        input_files(),
        expand("results/cellranger/{sample}/{sample}/outs/possorted_genome_bam.bam",sample=samples),
        expand("results/cellranger/{sample}/unmapped_reads.sam", sample=samples),
        expand("results/count_matrix/{sample}/count_matrix.tsv", sample=samples)















onsuccess:
    print("Snakemake finished successfully!")

onerror:
    print("Snakemake has failed!")    
      
