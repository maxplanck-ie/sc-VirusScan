rule extract_bam:
    input:
        i1 = "results/cellranger/{sample}/possorted_genome_bam.bam"
    output:
        temp("results/cellranger/{sample}/unmapped_reads.sam")
    resources:
        mem_mb = 4000,
        runtime = 120
    threads: 16
    params:
        "results/cellranger/{sample}/{sample}/outs/possorted_genome_bam.bam"
    shell:
        "samtools view -@ {threads} -f 4 {input.i1} > {output}"