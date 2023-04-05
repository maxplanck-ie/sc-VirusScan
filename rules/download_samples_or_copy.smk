rule download_samples_or_copy:
    output: 
        o1 = temp("data/{sample}_S1_L001_R1_001.fastq.gz"),
        o2 = temp("data/{sample}_S1_L001_R2_001.fastq.gz")
    params:
        outdir = "data",
        data_directory = config["dir"]
    threads: 16
    priority: 100
    conda:
        "envs/tools.yaml"
    shell:
        """
        if [ {config[files]} == 'local' ]; then
            cp {config[dir]}/*.fastq.gz  data/

        else
            parallel-fastq-dump --sra-id {wildcards.sample} --split-files --threads {threads} --outdir {params.outdir}  --gzip --tmpdir /data/manke/processing/momin/virome-scan/sc-virome-scan/tmp
            mv data/{wildcards.sample}_1.fastq.gz data/{wildcards.sample}_S1_L001_R1_001.fastq.gz 
            mv data/{wildcards.sample}_2.fastq.gz data/{wildcards.sample}_S1_L001_R2_001.fastq.gz 
        fi
        """