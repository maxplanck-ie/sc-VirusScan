rule kraken_reports:
    input:
        i1 = expand("results/count_matrix/{sample}/count_matrix.tsv",sample=samples)
    output:
        o1 = "results/kraken_plots/Familywise_tax_readcounts.tsv",
        o2 = "results/kraken_plots/Specieswise_tax_readcounts.tsv",
        o3 = "results/kraken_plots/Clustermap_Familywise_log10.png",
        o4 = "results/kraken_plots/Clustermap_Specieswise_log10.png"
    priority: 10
    resources:
        mem_mb = 1000
    params:
        p1 = "results/kraken_plots/",
        p2 = "results/kraken2/"
    log:
        "results/logs/plots/kraken_plots.log"
    shell:
        """
        python3 scripts/kraken_plot.py -i {params.p2} -o {params.p1}
        """
