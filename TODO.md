# Organization

`archive/scVirusscan.sh` contains the scripts from Jiang. 

The set of study IDs that are to be downloaded from Synapse include: 

* ROSMAP (3962)
* snRNAseqPFC_BA10 (588)
* HBI_scRNAseq (174)
* UCI_3xTg-AD (164)
* snRNAseqAD_TREM2 (161)
* ROSMAP_nucleus_hashing (121)
* scRNAseq_microglia_wild_ADmice (99)
* Plxnb1_KO (61)
* APOEPSC (37)
* SEA-AD (29)
* MCMPS (22)
* VMC (1)

We need to subset these to include first only those sequenced with 10X Genomics
scRNA-seq (not ATAC-seq yet., maybe in the future).

# Gold standard datasets

## hCMV single cell:
1. [GSM5029520: CRISPRn_perturb_virus_host](https://www.ncbi.nlm.nih.gov/sra/SRX9913205%5baccn%5d)
2. [GSM4237845: Monocytes 5dpi ruxo at 3dpi](https://www.ncbi.nlm.nih.gov/sra/SRX7473758%5baccn%5d)
3. [scRNA-seq HSV-1 brain organoid](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=SRP299538&o=acc_s%3Aa)
4. [GSE165291 Functional single-cell genomics of human cytomegalovirus infection](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE165291)
5. [Single-cell anergic hCMV](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE138838)

## Single-cell coronavirus dataset: 

1. [COVID-19 repository summary](https://github.com/urmi-21/COVID-19-RNA-Seq-datasets)
2. [GSM4658507 - single-cell COVID-19 data](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM4658507) (NB: just noticed this is 5\´ data, do we still want to go forward with this?)

# Ideas

We want to include all functionality from Jiang's script as one "branch" of the 
DAG, and on another, use kraken to assign the reads. The user should then
be able to choose which branch to run through a configuration option. 

See also [this article](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9725748/)
on best practices for metagenomics. 

We can use umi_tools to mark and deduplicate UMIs from BAM files but can only
annotate, but not deduplicate, UMIs from FASTQs. Instead, we need to implement
deduplication ourselves. First pass: annotate UMI in FASTQ header -> 
map to kraken -> cluster UMIs using umi_tools UMIClusterer class ->
if read in same UMI cluster *and* mapping to same kraken phylogeny then
deduplicate reads. 

c.f. [github issue](https://github.com/CGATOxford/UMI-tools/issues/436)
also https://pubmed.ncbi.nlm.nih.gov/30351359/

## Ward's Ideas

* First run kraken on all datasets to filter which ones should be carried forward
* Then use aligment approach on second pass
* Q: should we use R1 & R2 of scRNA-seq to feed to Kraken? Or just R2 and match? 

NB: Florian has some compute resource from de.NBI -> check on this with Jiang. 

# Todo

- [] Saim -> create account on Synapse, get Thomas to add you to DUC
- [] Implement mapping/kraken assignment of read 2 of the 10X CellRanger data
- [] if necessary, rerun 10X CellRanger to generate matrix
- [] Get specs of de.NBI compute architecture from Jiang
- [] mark *most* intermediate files as temp() so as not to blow up the pipeline.
- [] if possible, write the pipeline in a way such that only one or two are processed in parallel, so as to decrease the disk footprint. This can probably be implemented by priorities. 
- [] Mark everything as temp()! 
- [] Create separate table of kraken assignments x cell barcodes (similar to a DESeq DGE object) 
- [] Automate ingestion of 10X data into Seurat/SingleCellExperiment
- [] add additional metadata layer for the Kraken assignments from kraken table
- [] Ask Jiang about scviromescan.R
- [] Maybe we create private branch of this while it is under development
- [] Check gold standards for correct virus annotation
