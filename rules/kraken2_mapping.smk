rule kraken2_mapping:
    input:
        i1 = "data/{sample}_S1_L001_R2_001.fastq.gz"
    output:
        o1 = "results/kraken2/{sample}/{sample}.kraken",
        o2 = "results/kraken2/{sample}/{sample}.report.txt"
    conda:
        "envs/kraken2.yaml"
    params:
        p1 = "/data/repository/kraken2_contaminome/virus_db"
    log:
        "results/logs/kraken2/{sample}_kraken.log"
    shell:
        "kraken2 --use-names --threads 4 --db {params.p1} --report {output.o2} {input.i1} > {output.o1} &> {log}"