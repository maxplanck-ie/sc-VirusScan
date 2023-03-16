rule cellranger:
    input:
        i1 = expand("data/{sample}_test.txt", sample=samples)
    output:
        o1 = "results/cellranger/{sample}/{sample}/outs/possorted_genome_bam.bam"
    priority: 90
    log:
        "results/cellranger/{sample}/{sample}_cellranger.log"
    params: 
        p1 = config["chemistry"], 
        p2 = config["transcriptome"],
        p3 = "/data/manke/processing/momin/virome-scan/sc-virome-scan/data/",
        p4 = "/data/manke/processing/momin/virome-scan/kraken2/negative_ctrl/data/"
    shell:
        """
        cd results/cellranger/{wildcards.sample}/ 
        cellranger count --id {wildcards.sample} --fastqs {params.p4} --transcriptome {config[transcriptome]} --chemistry SC3Pv2
        """
