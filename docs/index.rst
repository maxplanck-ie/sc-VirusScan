.. sc-VirusScan documentation master file, created by
   sphinx-quickstart on Thu Jan 11 14:56:35 2024.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to sc-VirusScan's documentation!
========================================

.. toctree::
   :maxdepth: 2
   :caption: Contents:

sc-VirusScan is a method wrapped around Snakemake that enables accurate, sensitive and scalable detection of viral pathogens in single-cell RNA datasets. The method integrates the strengths of two standard approaches, a standard mapping based approach and a Kraken2 k-mer based approach which provides rapid taxonomic classification.The output of the sc-VirusScan pipeline can be integrated easily into existing single cell analysis frameworks (Seurat and Scanpy) which can provide standardized and reliable way to scrutinize virus infections at the single cell level resolution.


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`



==================
Installation and Setup
==================

sc-VirusScan by installed by following the below mentioned steps.

1. Clone the Git Repository using: ``git clone https://github.com/maxplanck-ie/sc-virome-scan.git``
2. Change the directory to sc-virus-scan: ``cd sc-virus-scan``
3. The dependecies of sc-VirusScan can be installed from the provided ``env.yaml`` by using conda/mamba

   ``mamba env create -f env.yaml -n sc-VirusScan``
4. sc-VirusScan requires **CellRanger** as part of dependencies which can installed from `here <https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/installation>`
5. Upon successfull installation of CellRanger, the CellRanger path needs to be updated in the ``config.yaml`` file accordingly
6. Lastly, the ``config.yaml`` needs to be modified as per your system environment variables. More information about config.yaml along with its description can be found in the section below.

Description of ``config.yaml`` file
.. code-block:: yaml

   samplesheet : # Path to samplesheet file. More details about Samplesheet schema can be found below.
   mode : # Pipeline mode to execute. (synapse | sra | local)
   local_data_dir : # If local mode chosen, specify here the directory path for the files.
   kraken_db: # Path to Custom KrakenDB. More details can be found below.
   cellranger: # Path of CellRanger Executable.
   transcriptome : # Path to your human transcriptome required from CellRanger count
   scripts_dir: # Path to scripts directory present in base directory of the workflow

