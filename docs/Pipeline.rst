.. _pipeline_execution:

Pipeline Execution
==================
Once all the configuration dependencies are met and paramaters are set in the ``config.yaml``, sc-VirusScan can be initiated as described below:

1. Activate the conda environment: ``conda activate sc-virus-scan``

2. Once conda environment is activated, trigger the pipeline using following command:

.. code-block:: bash

   snakemake --cores 16 --configfile config.yaml --latency-wait 60 --profile <Slurm_Profile_Name>

--cores: Cores to be specified for the pipeline (Minimum: 16)  

--configfile: Path to the config.yaml file  

--profile: If slurm profile available, specify the slurm profile name  

Pipeline Outputs
^^^^^^^^^^^^^^^^^^

On successfully completion of sc-VirusScan, following output file are generated in the respective directories as representated below.

.. code-block:: bash

   ├── results
   │    ├── kraken2                                   #Kraken Classification Reports
   │    │    ├── Sample1.kraken  
   │    │    └── Sample1.report.txt 
   │    │
   │    ├── cellranger                                #CellRanger scRNAseq Analysis Intermediate Files
   │    │  └── Sample1
   │    │     ├── filtered_feature_bc_matrix
   │    │     ├── raw_feature_bc_matrix 
   │    │     ├── possorted_genome_bam
   │    │     ├── possorted_genome_bam.bai
   │    │     ├── filtered_feature_bc_matrix.h5
   │    │     └── raw_feature_bc_matrix.h5
   │    │
   │    ├── count_matrix                               #Final Count matrix result
   │    │  └── Sample1/
   │    │     └── count_matrix.tsv
   │    │
   │    └── kraken_reports                             #QC Reports and Plots based on Kraken2 Reports
   │       ├── Familywise_tax_readcounts.tsv
   │       ├── Specieswise_tax_readcounts.tsv
   │       ├── Clustermap_Familywise_log10.png
   │       └── Clustermap_Specieswise_log10.png
   └── logs
   
The users can use the ``count_matrix.tsv`` file from the results directory along with the Cellranger barcodes in the sample wise directories under cellranger directory for further downstream single cell analysis using Seurat and ScanPy.
