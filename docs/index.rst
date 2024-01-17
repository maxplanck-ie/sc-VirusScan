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



Installation and Setup
==================

sc-VirusScan by installed by following the below mentioned steps.

1. Clone the Git Repository using: ``git clone https://github.com/maxplanck-ie/sc-virome-scan.git``
2. Change the directory to sc-virus-scan: ``cd sc-virus-scan``
3. The dependecies of sc-VirusScan can be installed from the provided ``env.yaml`` by using conda/mamba

   ``mamba env create -f env.yaml -n sc-VirusScan``
4. sc-VirusScan requires **CellRanger** as part of dependencies which can be installed from `here <https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/installation>`_.

5. Upon successfull installation of CellRanger, the CellRanger path needs to be updated in the ``config.yaml`` file accordingly
6. Lastly, the ``config.yaml`` needs to be modified as per your system environment variables. More information about config.yaml along with its description can be found :ref:`here <contents-of-config-yaml>`.

.. _contents-of-config-yaml:

Contents of ``config.yaml`` file
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   samplesheet : #Path to samplesheet file. More details about Samplesheet schema can be found below.
   mode : #Pipeline mode to execute. (synapse | sra | local)
   local_data_dir : #If local mode chosen, specify the directory path for the input files here.
   kraken_db: #Path to Custom KrakenDB. More details can be found below.
   cellranger: #Path of CellRanger Executable.
   transcriptome : #Path to your human transcriptome required from CellRanger count
   scripts_dir:  #Path to scripts directory present in base directory of the workflow

.. _description-of-config-yaml:

Description of ``config.yaml`` file
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
1. **samplesheet** : The pipeline requires a ``samplesheet.tsv`` file to initiate the analysis. The samplesheet is a tab seperated file (TSV) acts as blueprint schema for analysis. Depending on the mode of pipeline, there are two reprensatative schema of samplesheet file. The provided samplesheet file will be then used to download the files from SRA database or Synapse AD Knowledge Portal and perform subsequent analysis on it.

   a. **SRA mode (SRA)**: For running the pipeline in SRA mode, the user needs to provide a list of SRA Ids as shown in the example below. This file is further used to download the files from SRA database and perform analysis on it.

   .. code-block:: bash

         Samples
         SRR13419001
         SRR13419002
         SRR13419003
         SRR13419004
         SRR13419005



   b. **Synapse mode (synapse)**: To execute the pipeline in ``synapse`` mode, user needs to generate the samplesheet.tsv with the help of ``synapse_fetch.py`` script present in the `scripts <https://github.com/maxplanck-ie/sc-VirusScan/tree/main/scripts>`_  directory of the repository. This scripts takes a Parent SynapseID as input and internally programmatically queries the Synapse Server to retreive all the associated Syanpse Ids for the raw FASTQ files under the provided parent SynapseID and returning a Tab-Sepated file consisting of SampleName, Read1 SynapseID, Read2 SynapseID as representated below. This obtained file is further used to download the files from Synapse AD Knowledge Portal and perform analysis on it.

   .. code-block:: bash

         Samples	R1	R2
         D17-8765_S1L1	 syn18641014	 syn18641249
         D17-8765_S1L2	 syn18641325	 syn18641475
         D17-8765_S1L3	 syn18641515	 syn18641599
         D17-8765_S1L4	 syn18641650	 syn18641733
         D17-8766_S2L1	 syn18641776	 syn18641855



   c. **Local mode (local)**:To execute the pipeline in ``local`` mode (ie. files are pre-downloaded),user needs to specify the Sample names in ``samplesheet.tsv`` file. Along with this, user has to provide the path to the directory where the files are present in the ``config.yaml`` file under ``local_data_dir`` key.

2. **mode** (SRA | synapse): Currently, sc-VirusScan accomodates two distinct modes depending on the source of input data: Sequence Read Archive (SRA) and Synapse AD Portal (synapse) for specifying input files for analysis. Depending on the input data type, the mode can be modified in the ``config.yaml`` file.

3. **kraken_db**: As sc-VirusScan consists of viral screening module internally relying on Kraken2 for rapid taxonomic classification, it requires a KrakenDB in the backend. One can provide pre-built Kraken2 database available `here <https://benlangmead.github.io/aws-indexes/k2>`_ or create a custom Kraken database based on analysis specificity. The path of downloaded Kraken2 database, needs to be assigned to `krakendb` key in `config.yaml` file.

4. **cellranger**: Path of CellRanger executable. This can be located using by the command ``which cellranger``.

5. **transcriptome**: The CellRanger count requires a Human reference transcriptome for scRNA-seq analysis module. This reference
transcriptome can be either be manually built using **Cellranger mkref** as described `here <https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/advanced/references>`_ or can be downloaded pre-built from 10X Genomics avalaible `here <https://www.10xgenomics.com/support/software/cell-ranger/downloads#reference-downloads>`_. Once the transcriptome is downloaded/built,  specify its path in the `config.yaml` file corresponding to `transcriptome` key.

6. **scripts_dir**: This path refers to the scripts directory present in the base directory of the workflow.


Important Note For Synapse Data Analysis mode
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Before you can download a file from Synapse, you must determine whether you have access to it. Further information about Synapse Data Access can be found `here <https://help.synapse.org/docs/Finding-and-Downloading-Data.2003796231.html#FindingandDownloadingData-AccessingData>`_.  

In order to download and analyse data from Synapse Portal, user needs a ``.synpaseConfig`` file located in ``~/.synapseConfig`` directory. This file contains individual Username and Access Token to allow access to Synapse programmatically (Automatically taken care by the pipeline) and download the relevant data based on the user input. More information on setting up the synapseConfig file can be found `here <https://python-docs.synapse.org/build/html/Credentials.html#use-synapseconfig>`_.

Steps to setup ``.synapseConfig`` file
++++++++++++++++++++++++++++++++++++++
1. Check in the home directory if ``.synapseConfig`` file exists.

2. If not, download the config template from `here <https://raw.githubusercontent.com/Sage-Bionetworks/synapsePythonClient/develop/synapseclient/.synapseConfig>`_

3. Once downloaded, the user needs to update the fields of username and authtoken. An example is respresented below:

.. code-block:: bash

    ###########################
    # Login Credentials       #
    ###########################
   
    ## Used for logging in to Synapse
    ## Alternatively, you can use rememberMe=True in synapseclient.login or login subcommand of the commandline client.
    [authentication]
    username = YOUR_SYNAPSE_USERNAME
    authtoken = YOUR_SYNAPSE_AUTHENTICATION_TOKEN

4. Authentication Token can be generated from your Synapse User Account. More information can be found `here <https://help.synapse.org/docs/Managing-Your-Account.2055405596.html#ManagingYourAccount-PersonalAccessTokens>`_.

5. After the changes mentioned above, the ``.synapseConfig`` file is ready to be used and can be utilized by sc-VirusScan automatically.

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

