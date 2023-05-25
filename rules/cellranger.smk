rule cellranger:
    input:
        i1 = expand("data/{sample}_test.txt", sample=samples)
    output:
        o1 = temp("results/cellranger/{sample}/{sample}_finished.txt")
    priority: 90
    resources:
        mem_mb = 26000
    threads: 30
    log:
        "results/cellranger/{sample}/{sample}.cellranger.log"
    params: 
        p1 = config["chemistry"], 
        p2 = config["transcriptome"],
        p3 = "/data/manke/processing/momin/virome-scan/sc-virome-scan/data/{sample}/"
    shell:
        """
        module load cellranger
        touch {output.o1}
        cd results/cellranger/{wildcards.sample}/ 
        cellranger count --id {wildcards.sample} --fastqs {params.p3} --transcriptome {config[transcriptome]} --localcores {threads}
        """
