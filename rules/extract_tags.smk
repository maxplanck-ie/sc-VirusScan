rule extract_tags:
    input:
        "results/cellranger/{sample}/unmapped_reads.sam"
    output:
        "results/count_matrix/{sample}/count_matrix.tsv"
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
        "python3 {config[scripts_dir]}/bam_extract.py -i {input} -k {params.p3} -b {params.p2} -o {params.p1}"