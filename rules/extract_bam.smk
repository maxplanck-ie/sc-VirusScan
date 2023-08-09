rule extract_bam:
    input:
        i1 = "results/cellranger/{sample}/possorted_genome_bam.bam"
    output:
        temp("results/cellranger/{sample}/unmapped_reads.sam")
    params:
        "results/cellranger/{sample}/{sample}/outs/possorted_genome_bam.bam"
    shell:
        "samtools view -@ 16 -f 4 {input.i1} > {output}"