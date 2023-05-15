rule extract_tags:
    input:
        i1 = "results/cellranger/{sample}/unmapped_reads.sam",
        i2 = "results/kraken2/{sample}/{sample}.kraken"
    output:
        "results/count_matrix/{sample}/count_matrix.tsv"
    threads: 16
    resources:
        mem_mb = 40000
    params:
        p1 = "results/count_matrix/{sample}/",
        p2 = "results/cellranger/{sample}/{sample}/outs/filtered_feature_bc_matrix/barcodes.tsv.gz"
    log:
        "results/count_matrix/{sample}_bam_extract.log"
    shell:
        "python3 scripts/bam_extract.py -i {input.i1} -k {input.i2} -b {params.p2} -o {params.p1}"