rule kraken2_processing:
    input:
        i1 = "results/cellranger/{sample}/possorted_genome_bam.bam",
        i2 = "results/kraken2/{sample}.kraken"
    output:
        o1 = "results/kraken_reads/{sample}_kraken_reads.sam",
    priority: 90
    resources:
        mem_mb = 20000
    threads: 16
    params:
        p1 = "results/kraken_reads/{sample}_ReadIds.txt",
        p2 = "results/kraken_reads/{sample}_krakenReads.bam"
    log:
        "results/logs/kraken2_processing/{sample}.log"
    shell:
        """
        mkdir -p results/kraken_reads
        awk -F'\t' '$3 != "unclassified (taxid 0)" && $3 != "Homo sapiens (taxid 9606)" {{print $2}}' {input.i2} > {params.p1}
        samtools view -N {params.p1} -o {params.p2} {input.i1}
        samtools index {params.p2}
        samtools view -h {params.p2} > {output.o1}
        """