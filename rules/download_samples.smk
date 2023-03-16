rule download_samples:
    output: 
        o1 = "data/{sample}_S1_L001_R1_001.fastq.gz",
        o2 = "data/{sample}_S1_L001_R2_001.fastq.gz",
        o3 = temp("data/{sample}_test.txt")
    params:
        outdir = "data"
    threads: 16
    priority: 100
    conda:
        "envs/tools.yaml"
    shell:
        """
        parallel-fastq-dump --sra-id {wildcards.sample} --split-files --threads {threads} --outdir {params.outdir}  --gzip
        mv data/{wildcards.sample}_1.fastq.gz data/{wildcards.sample}_S1_L001_R1_001.fastq.gz 
        mv data/{wildcards.sample}_2.fastq.gz data/{wildcards.sample}_S1_L001_R2_001.fastq.gz 
        touch {output.o3}
        """


       