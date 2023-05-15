rule extract_bam:
    input:
        i1 = "results/cellranger/{sample}/{sample}_finished.txt"
    output:
        temp("results/cellranger/{sample}/unmapped_reads.sam")
    log:
        "results/samtools/{sample}.log"
    params:
        "results/cellranger/{sample}/{sample}/outs/possorted_genome_bam.bam"
    shell:
        "samtools view -@ 16 -f 4 {params} > {output}"