rule download_samples_or_copy:
    output: 
        o1 = "data/{sample}/{sample}_S1_L001_R1_001.fastq.gz",
        o2 = "data/{sample}/{sample}_S1_L001_R2_001.fastq.gz",
    params:
        outdir = "data/{sample}/"
    threads: 16
    log:
        "results/logs/download_samples_or_copy/{sample}.log"
    priority: 100
    shell:
        """
        if [ {config[files]} == 'local' ]; then
            for file in {wildcards.sample}*; do
                ln -s {config[local_files_dir]}/$file  data/$file
            done
        else
            parallel-fastq-dump --sra-id {wildcards.sample} --split-files --threads {threads} --outdir {params.outdir}  --gzip --tmpdir /data/manke/processing/momin/virome-scan/sc-virome-scan/tmp
            mv data/{wildcards.sample}/{wildcards.sample}_1.fastq.gz data/{wildcards.sample}/{wildcards.sample}_S1_L001_R1_001.fastq.gz 
            mv data/{wildcards.sample}/{wildcards.sample}_2.fastq.gz data/{wildcards.sample}/{wildcards.sample}_S1_L001_R2_001.fastq.gz 
        fi
        """
