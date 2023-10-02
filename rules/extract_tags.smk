rule extract_tags:
    input:
        i1 = "results/cellranger/{sample}/unmapped_reads.sam",
        i2 = "results/kraken_reads/{sample}_kraken_reads.sam"
    output:
        o1 = "results/count_matrix/{sample}/count_matrix.tsv",
        o2 = "results/count_matrix/{sample}/kraken_reads_count_matrix.tsv",
    threads: 16
    resources:
        mem_mb = 40000
    params:
        p1 = "results/count_matrix/{sample}/",
        p2 = "results/cellranger/{sample}/filtered_feature_bc_matrix/barcodes.tsv.gz",
        p3 = "results/kraken2/{sample}.kraken"
    log:
        "results/logs/count_matrix/{sample}_bam_extract.log"
    shell:
        """
        python3 {config[scripts_dir]}/bam_extract.py -i {input.i1} -k {params.p3} -b {params.p2} -o {output.o1}
        python3 {config[scripts_dir]}/bam_extract.py -i {input.i2} -k {params.p3} -b {params.p2} -o {output.o2}
        """