rule cellranger:
    input:
        i1 = "results/kraken2/{sample}.report.txt"
    output:
        o1 = temp(directory("results/cellranger/{sample}/{sample}/")),
        o2 = "results/cellranger/{sample}/possorted_genome_bam.bam"
    priority: 80
    resources:
        mem_mb = 80000,
        runtime = 1200
    threads: 20
    log:
        "results/cellranger/{sample}/{sample}.cellranger.log"
    params:  
        p1 = "../../../data/{sample}/"
    shell:
        """
        cd results/cellranger/{wildcards.sample}/ 
        {config[cellranger]} count --id {wildcards.sample} --fastqs {params.p1} --transcriptome {config[transcriptome]} --localcores {threads}
        mv {wildcards.sample}/outs/filtered_feature_bc_matrix/ .
        mv {wildcards.sample}/outs/raw_feature_bc_matrix/ .
        mv {wildcards.sample}/outs/*.h5 .
        mv {wildcards.sample}/outs/possorted_genome_bam* .
        """