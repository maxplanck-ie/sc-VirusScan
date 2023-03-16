rule extract_bam:
    input:
        "results/cellranger/{sample}/{sample}/outs/possorted_genome_bam.bam"
    output:
        "results/cellranger/{sample}/unmapped_reads.sam"
    conda:
        "envs/samtools.yaml"
    shell:
        "samtools view -f 4 {input} > {output}"