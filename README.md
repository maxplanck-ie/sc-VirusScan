# scVirusScan: A method for swift and accurate detection of viral pathogens in single-cell RNA datasets.


[![Snakemake](https://img.shields.io/badge/snakemake-≥6.3.0-brightgreen.svg)](https://snakemake.github.io)


A method wrapped around Snakemake enabling accurate, sensitive and scalable detection of viral pathogens in single-cell
RNA datasets. The pipeline integrates the strengths of two standard approaches, a standard mapping based approach and a **Kraken2** k-mer based approach which provides rapid taxonomic classification.The output of the scVirusScan pipeline can be
integrated easily into existing single cell analysis frameworks (Seurat and Scanpy) which can provide
standardized and reliable way to scrutinize virus infections at the single cell level resolution. 



<br /> 

# Installation and Setup
1. Clone the Git Repository using: `git clone https://github.com/maxplanck-ie/sc-virome-scan.git`

2. Once cloned, change the directory to sc-virus-scan: `cd sc-virus-scan`

3. To install the dependencies of the pipeline a `env.yaml` file has been provided. The environment and dependencies can be installed using conda/mamba.  

     `mamba env create -f env.yaml -n sc-virome-scan`

4. Additionally, this pipeline needs `CellRanger` tool. To install CellRanger please refer to  https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/installation  


5. After installation of CellRanger, the path to CellRanger executable needs to be specified in `config.yaml` file.

6. Finally, the `config.yaml` needs to be modified as per your system environment variables. More information about `config.yaml` along with its description can be found in the section below.

<br /> 

### **A. Contents of `config.yaml` file**
```
samplesheet : # Path to your samplesheet file. More details about Samplesheet schema can be found below

mode : # Pipeline mode to execute. (synapse | sra | local)

local_data_dir : # If you choose local as pipeline mode, specify here the directory path of the files.

kraken_db: # Path to Custom KrakenDB. More details can be found below

cellranger: # Path of CellRanger Executable.

transcriptome : # Path to your human transcriptome required from CellRanger count

scripts_dir: # Path to scripts directory present in base directory of the workflow
```
<br /> 

### **B. Description about `config.yaml` file**
1. `samplesheet`: The pipeline requires a `samplesheet.tsv` file to carry out the analysis. The samplesheet is a Tab seperated file (TSV) that provides a blueprint for analysis. As the pipeline supports two modes for analysis, there are two different formats for samplesheet discussed below. This file is further used to download the files from SRA database and perform analysis on it. 
   
    **i. SRA mode:**
    For running the pipeline in SRA mode, the user needs to provide a list of SRA Ids as shown in the example below. This file is further used to download the files from SRA database and perform analysis on it.  
    ```
    Samples
    SRR13419001
    SRR13419002
    SRR13419003
    SRR13419004
    SRR13419005
    ```
    <br /> 

    **ii. Synapse mode:**
    For running the pipeline in synapse mode, user needs to generate the samplesheet with the help of `synapse_fetch.py` script present in the `scripts` directory of the pipeline. This scripts takes a Parent SynapseID as input and programmatically queries in the Synapse Server to retreive all the associate FASTQ files under the provided SynapseID and finally returns a Tab-Sepated file consisting of SampleName, Read1 SynapseID, Read2 SynapseID as shown below. This file is further used to download the files from Synapse and perform analysis on it. 
    ```
    Samples	R1	R2
    D17-8765_S1L1	 syn18641014	 syn18641249
    D17-8765_S1L2	 syn18641325	 syn18641475
    D17-8765_S1L3	 syn18641515	 syn18641599
    D17-8765_S1L4	 syn18641650	 syn18641733
    D17-8766_S2L1	 syn18641776	 syn18641855
    ```

    **iii. Local mode:**
    For running the pipeline in local mode (ie.Files are already downloaded prior to analysis), the user needs to specify the Sample names in `samplesheet.tsv` file. Along with this, the user has to provide the path to the directory where the files are present in the `config.yaml` file under `local_data_dir` key.

    <br /> 
2. `mode` **(SRA | synapse):** 
    At present, the pipeline caters to two distinct modes depending on the input data type: Sequence Read Archive (`SRA`) and Synapse AD Portal (`synapse`) input files for analysis. Depending on the input data type, the mode can be modified in the `config.yaml` file.
    
    <br /> 

3. `kraken_db:` As this pipeline relies on Kraken2 for  rapid taxonomic classification and requires a KrakenDB in backend, we have pre-built KrakenDB with curated list of Virus families. The custom VirusDB can be found in the link below. Once downloaded, please specify the path to KrakenDB in `config.yaml` file.
    
    <br /> 
4. `cellranger:` Specify the path of CellRanger executable. 
    
    <br /> 

5. `transcriptome:` The CellRanger count requires a Human reference transcriptome for scRNA-seq analysis. This reference        
   transcriptome can be either be built using `Cellranger count` or can be downloaded pre-built from our Zenodo data repository. Link can be found below. To build the CellRanger reference transcriptome manually, please refer to https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/advanced/references

    Once the transcriptome is downloaded/built, please specify its path in the `config.yaml` file corresponding to `transcriptome` key.
    
    <br /> 

6. `scripts_dir:` This path refers to the scripts directory present in the base directory of the workflow. 


    <br /> 

## **Important Note For Synapse Data Analysis mode**
In order to download and analyse data from Synapse Portal, user needs a `synpaseConfig` file located in `~/.synapseConfig` directory. This file has individual Username and Access Token in order to login in to Synapse programmatically (Automatically taken care by the pipeline) and download the relevant data based on the user input. More information on setting up the `synapseConfig` file can be found here https://python-docs.synapse.org/build/html/Credentials.html#use-synapseconfig

Step to setup `synapseConfig` file  
1. Check in the home directory if `.synapseConfig` exists.
2. If not, you can download the template from https://raw.githubusercontent.com/Sage-Bionetworks/synapsePythonClient/develop/synapseclient/.synapseConfig
3. Once downloaded, the user needs to update the fields of username and authtoken. An example is given below:
   
   ```
   ###########################
    # Login Credentials       #
    ###########################

    ## Used for logging in to Synapse
    ## Alternatively, you can use rememberMe=True in synapseclient.login or login subcommand of the commandline client.
    [authentication]
    username = YOUR_SYNAPSE_USERNAME
    authtoken = YOUR_SYNAPSE_AUTHENTICATION_TOKEN
   ```

4. Authentication Token can be generated from your Synapse User Account
5. After the changes mentioned above, the `.synapseConfig` file is ready to be used. 

<br />

# Pipeline Execution

Once all the configuration dependencies are met and paramaters are set in the `config.yaml`, follow the instructions below to execute the pipeline

1. Activate the conda environment: `conda activate sc-virus-scan`

2. Once conda environment is activated, trigger the pipeline using following command:

    > ***snakemake --cores 16 --configfile config.yaml --latency-wait 60--profile <Slurm_Profile_Name>***

    --cores: Cores to be specified for the pipeline (Min: 16)  
    --configfile: Path to the `config.yaml` file  
    --profile: If slurm profile available, specify the slurm profile name    


<br /> 



# DAG for the pipeline
![Graphviz Diagram](dag.png)



<br /> 

# Pipeline Output
```
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

```
<br /> 

# Results
The user can use the `count_matrix` file from the results directory to integrate the downstream analysis using Seurat and ScanPy
Intermediate, Cellranger barcodes can also be found in the sample wise directories under cellranger directory. 
<br />

# Note
sc-VirusScan pipeline is under active development. Please use issues to the GitHub repository for feature requests or bug reports. 
<br /> 

# Credits
sc-VirusScan was developed at Max Planck Institute of Immunobiology and Epigenetics, Freiburg. 