# scVirusScan: A method for swift and accurate detection of viral pathogens in single-cell RNA datasets


[![Snakemake](https://img.shields.io/badge/snakemake-≥6.3.0-brightgreen.svg)](https://snakemake.github.io)

sc-VirusScan is a method that enables accurate, sensitive and scalable detection of viral pathogens in single-cell RNA datasets.

The sc-VirusScan integrates the strengths of two standard approaches, a standard mapping based approach and a **Kraken2** _k_-mer based approach which provides rapid taxonomic classification. The output of the sc-VirusScan pipeline can be integrated easily into existing single cell analysis frameworks (Seurat and Scanpy) which can provide standardized and reliable way to scrutinize virus infections at the single cell level resolution.


<br /> 

## Installation and Setup

sc-VirusScan by installed by following the below mentioned steps.

1. Clone the Git Repository using: git clone https://github.com/maxplanck-ie/sc-VirusScan.git

2. Change the directory to sc-virus-scan: `cd sc-VirusScan`

3. The dependecies of sc-VirusScan can be installed from the provided env.yaml by using conda/mamba

     `mamba env create -f env.yaml -n sc-VirusScan`

5. Additionally, this pipeline needs `CellRanger` tool. To install CellRanger please refer to  https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/installation  


6. Upon successfull installation of CellRanger, the CellRanger path needs to be updated in the `config.yaml` file accordingly

7. Lastly, the `config.yaml` needs to be modified as per your system environment variables. More information about `config.yaml` along with its description can be found in the [Read the docs page](https://sc-virusscan.readthedocs.io/en/latest/index.html).

<br /> 

## Documentation
For detailed documentation on setup and usage, please visit our [Read the docs page](https://sc-virusscan.readthedocs.io/en/latest/index.html).

<br /> 

## Credits
sc-VirusScan was developed by Saim Momin as a Master Thesis project for the Bioinformatics Master program of the [Saarland University](https://zbi-www.bioinf.uni-sb.de/en/), under the supervision of Deboutte W and Manke T. at the [Bioinformatics Unit](http://www.ie-freiburg.mpg.de/bioinformaticsfac) of the [Max Planck Institute for Immunobiology and Epigenetics](http://www.ie-freiburg.mpg.de/) in Freiburg.

![MPI_Logo](docs/mpi_logo.jpg)

<br /> 

## Help and Support
sc-VirusScan pipeline is under active development. Please use issues to the GitHub repository for feature requests or bug reports. 
<br /> 

