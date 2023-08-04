# sc-Virome-Scan: A Snakemake pipeline for detection of viruses in single-cell datasets.

[![Snakemake](https://img.shields.io/badge/snakemake-≥6.3.0-brightgreen.svg)](https://snakemake.github.io)



A method wrapped around Snakemake for swift, precise, and accurate detection of viral pathogens in single-cell
RNA (scRNA) datasets to investigate the possible correlation between viral pathogens and neurodegenerative diseases. 

<br /> 

# Installation

`git clone -b dev https://github.com/maxplanck-ie/sc-virome-scan.git`

`cd sc-virome-scan`

`mamba create -f env.yaml -n sc-virome-scan`

## Usage

> ***snakemake --cores 16 --configfile config.yaml --latency-wait 60 --profile mpislurm***

## Handling Multiple Input modes to pipeline
Currently, the pipeline supports Sequence Read Archive (SRA) and Synapse AD Portal input files for analysis. 

<br /> 

## Important Note For Synapse Data Analysis
In order to download and analyse data from Synapse Portal, make sure you have the `synpaseConfig` file located in `~/.synapseConfig` directory. This file has individual Username and Access Token in order to login in to Synapse programmatically (Automatically taken care by the pipeline) and download the data based on the user input. 

Additionally, the user needs to provide a ***metadata.tsv*** file (present in the base directory of the repository) which consists of Sample names along with its Read 1 and Read 2 Synapse IDs. The pipeline will use this metadata.tsv file for downloading and analysis steps downstream.

# DAG for the pipeline
![Graphviz Diagram](dag.png)



<br /> 

### Note
This is a developmental and alpha phase of the pipeline, upon completion a Python Wrapper will take care of every runtime parameter handling automatically.

<br /> 

## Contributing
The usage of this workflow is described in the [Snakemake Workflow Catalog](https://snakemake.github.io/snakemake-workflow-catalog/?usage=maxplanck-ie%2Fsc-virome-scan).

If you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this (original) repository and its DOI (see above).

