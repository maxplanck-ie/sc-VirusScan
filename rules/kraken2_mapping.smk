rule kraken2_mapping:
    input:
        i1 = "data/{sample}/{sample}_S1_L001_R2_001.fastq.gz"
    output:
        o1 = "results/kraken2/{sample}/{sample}.kraken",
        o2 = "results/kraken2/{sample}/{sample}.report.txt",
        #o3 = "results/kraken2/{sample}/{sample}_classified_out.fastq",
        o4 = temp("data/{sample}_test.txt")
    priority: 95
    resources:
        mem_mb = 20000
    threads: 16
    params:
        p1 = config["kraken_db"]
    log:
        "results/logs/kraken2/{sample}.kraken.log"
    shell:
        """
        kraken2 --use-names --threads {threads} --db {params.p1} --report {output.o2} --output {output.o1} {input.i1} 2> {log}
        touch {output.o4}
        """