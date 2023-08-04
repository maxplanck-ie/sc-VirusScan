rule download_samples_or_copy:
    output: 
        o1 = "data/{sample}/{sample}_S1_L001_R1_001.fastq.gz",
        o2 = "data/{sample}/{sample}_S1_L001_R2_001.fastq.gz"
    params:
        outdir = "data/{sample}/",
        filetype = config["files"]
    threads: 16
    resources:
        mem_mb = 20000
    log:
        "results/logs/download_samples_or_copy/{sample}.log"
    priority: 100
    shell:
        """
        filetype="{params.filetype}"
        if [ $filetype == "local" ]; then
            for file in {wildcards.sample}*; do
                ln -s {config[local_files_dir]}/$file  data/$file
            done
        
        elif [ $filetype == "synapse" ]; then
            result=$(grep "{wildcards.sample}" "metadata.tsv")
            R1=$(echo "$result" | awk '{{print $2}}')
            R2=$(echo "$result" | awk '{{print $3}}')
            synapse get $R1 --multiThreaded --downloadLocation {params.outdir} 
            synapse get $R2 --multiThreaded --downloadLocation {params.outdir}
            mv data/{wildcards.sample}/*_R1_* data/{wildcards.sample}/{wildcards.sample}_S1_L001_R1_001.fastq.gz
            mv data/{wildcards.sample}/*_R2_* data/{wildcards.sample}/{wildcards.sample}_S1_L001_R2_001.fastq.gz
        
        else
            parallel-fastq-dump --sra-id {wildcards.sample} --split-files --threads {threads} --outdir {params.outdir}  --gzip --tmpdir /data/manke/processing/momin/virome-scan/sc-virome-scan/tmp
            mv data/{wildcards.sample}/{wildcards.sample}_2.fastq.gz data/{wildcards.sample}/{wildcards.sample}_S1_L001_R1_001.fastq.gz 
            mv data/{wildcards.sample}/{wildcards.sample}_3.fastq.gz data/{wildcards.sample}/{wildcards.sample}_S1_L001_R2_001.fastq.gz 
        fi     
        """
