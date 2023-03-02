#! /bin/bash

set -e

if [ $# -eq 0 ]
then
    echo -e "\n$0 -1 <input_paired1> -2 [input_paired2] -d [DATABASE] -p [threads] -m [VIROMESCAN_PATH] -o <OUTPUT_DIR>
    
    -1/--input1: .fastq file containing the sequences (paired end 1)  (MANDATORY)
    -2/--input2: .fastq file containing the sequences (paired end 2) (if available)
    -t/--datatype: single cell data type, among: scRNAseq, scATACseq (MANDATORY)
    -p/--threads: number of threads to launch (default: 1)
    -d/--database: viral database, choose in the viromescan folder your database, among: human_ALL (RNA/DNA), human_DNA (DNA only), virus_ALL (vertebrates, invertebrates, plants and protozoa virus. NO bacteriophages), virus_DNA (vertebrates, invertebrates, plants and protozoa DNA virus. NO bacteriophages) (MANDATORY)
    -m/--viromescan_path: pathway to viromescan folder (default: working directory)
    -o/--output: output directory (MANDATORY)
    "
    exit 1
fi


# -----------------------
input_paired1=''; input_paired2=''; DATABASE='';datatype=''; threads=10; VIROMESCAN_PATH=''; OUTPUT_DIR='';
 

OPTS=$(getopt -o 1:2:d:t:p:m:o: -l input1:,input2:,database:,datatype:,threads:,viromescan_path:,output:, -- "$@")
eval set -- "$OPTS"

while [ $# -gt 0 ] ; do
    case "$1"
    in
        -1|--input1) input_paired1=$2; shift;;
        -2|--input2) input_paired2=$2; shift;;
        -t|--datatype) datatype=$2; shift;;
        -p|--threads) threads=$2; shift;;
        -d|--database) DATABASE=$2; shift;;
        -m|--viromescan_path) VIROMESCAN_PATH=$2; shift;;
        -o|--output) OUTPUT_DIR=$2; shift;;
        (--) shift; break;;
    esac
    shift
done



###############
##Set up the env
###############
VIROMESCAN_PATH=/path/to/anaconda/miniconda3/envs/scviromescan
DATABASE=/path/to/anaconda/miniconda3/envs/viromescan/viromescan/database/
conda activate bmtagger
conda activate STAR/2.7.9a
conda activate bowtie2/2.3.3.1 
conda activate samtools/1.12
conda activate umi_tools/1.0.1
conda activate subread/2.0.0
conda activate sambamba/0.7.1
conda activate R/4.0.3
conda activate bbmap/38.94


if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir $OUTPUT_DIR
fi

###############
##Mapping
###############

if [ "$datatype" == "scRNAseq" ]
then
# STAR --runThreadN 30 --outFileNamePrefix $OUTPUT_DIR/${OUTPUT_DIR}- --genomeDir /path/to/anaconda/miniconda3/envs/viromescan/viromescan/database/star_Nmasked_2.7.9a --sjdbGTFfile /path/to/anaconda/miniconda3/envs/viromescan/viromescan/database/refseq/human.all.gtf --outFilterMultimapNmax 10000 --outFilterMatchNminOverLread 0 --outFilterScoreMinOverLread 0 --seedSearchStartLmax = 10 --readFilesIn  $input_paired1 $input_paired2 --readFilesCommand gunzip -c --limitSjdbInsertNsj 2000000 --outFilterMultimapScoreRange 0 --limitBAMsortRAM 10000000000 --alignEndsType EndToEnd --outSAMattributes NH HI AS nM CB UB NM MD --outSAMtype BAM SortedByCoordinate --outBAMsortingBinsN 20 --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 --outFilterMismatchNmax 999 --alignIntronMin 0 --alignIntronMax 1 --alignMatesGapMax 1000 --outSAMunmapped Within --soloType CB_UMI_Simple --soloFeatures Gene Velocyto --soloCBwhitelist /path/to/Genome/10Xtechnique/3M-february-2018.txt --soloCBstart 1 --soloCBlen 16 --soloUMIstart 17 --soloUMIlen 12 --soloBarcodeReadLength 0 --soloUMIfiltering MultiGeneUMI --soloCBmatchWLtype 1MM_multi_pseudocounts --soloUMIdedup Exact --soloStrand Forward --soloOutFileNames genes.tsv barcodes.tsv matrix.mtx #--soloCellFilter CellRanger2.2 3000 0.99 10
umi_tools extract --bc-pattern=CCCCCCCCCCCCCCCCNNNNNNNNNN --stdin ${input_paired1} --stdout $OUTPUT_DIR/${OUTPUT_DIR}_R1_extracted.fastq.gz  --read2-in ${input_paired2} --read2-out=$OUTPUT_DIR/${OUTPUT_DIR}_R2_extracted.fastq.gz --whitelist=/path/to/10Xtechnique/3M-february-2018.txt ##16 barcode and 10 UMIs
# umi_tools extract --bc-pattern=CCCCCCCCCCCCNNNNNNNN --stdin ${input_paired1} --stdout $OUTPUT_DIR/${OUTPUT_DIR}_R1_extracted.fastq.gz  --read2-in ${input_paired2} --read2-out=$OUTPUT_DIR/${OUTPUT_DIR}_R2_extracted.fastq.gz ##12 barcode and 8 UMIs

bowtie2 -x $DATABASE/new_bowtie2/human_ALL -1 $OUTPUT_DIR/${OUTPUT_DIR}_R1_extracted.fastq.gz -2 $OUTPUT_DIR/${OUTPUT_DIR}_R2_extracted.fastq.gz --very-fast-local --no-unal -S $OUTPUT_DIR/${OUTPUT_DIR}.sam -p $threads

bowtie2 -x $VIROMESCAN_PATH/viromescan/databasehuman/bowtie2/$DATABASE -q $OUTPUT_DIR/${OUTPUT_DIR}-filter--quality-bacteria.trimmed.2.fastq --very-sensitive-local --no-unal -S $OUTPUT_DIR/${OUTPUT_DIR}-final.sam -p 30
fi

###############
##Filtering
###############

###remove reads without cell barcode
##sambamba view -F "not unmapped and [CB] != '-'" -t 30 -f bam $OUTPUT_DIR/${OUTPUT_DIR}-Aligned.sortedByCoord.out.bam > $OUTPUT_DIR/${OUTPUT_DIR}-Aligned.sortedByCoord.cellbarcode.bam
##sambamba index -t 30 $OUTPUT_DIR/${OUTPUT_DIR}-Aligned.sortedByCoord.cellbarcode.bam
samtools view $OUTPUT_DIR/${OUTPUT_DIR}.sam |cut -f1 |sed -n '/.*_.*_.*/p' > $OUTPUT_DIR/${OUTPUT_DIR}.sam.name
samtools view -@ 30 -N $OUTPUT_DIR/${OUTPUT_DIR}.sam.name -o $OUTPUT_DIR/${OUTPUT_DIR}-Aligned.sortedByCoord.cellbarcode.bam $OUTPUT_DIR/${OUTPUT_DIR}.sam

samtools view $OUTPUT_DIR/${OUTPUT_DIR}-Aligned.sortedByCoord.cellbarcode.bam |grep -v ^@| awk '{print"@"$1"\n"$10"\n+\n"$11}' > $OUTPUT_DIR/${OUTPUT_DIR}-virusnofiltr.fastq

###remove reads mapping to human and bacteria genome
mkdir -p $OUTPUT_DIR/tmp/

bash $VIROMESCAN_PATH/viromescan/tools/bmtagger.sh -b $VIROMESCAN_PATH/viromescan/database/hg38/reference.bitmask -x $VIROMESCAN_PATH/viromescan/database/hg38/reference -T $OUTPUT_DIR/tmp/ -q1 -1 $OUTPUT_DIR/${OUTPUT_DIR}-virusnofiltr.fastq -X -o $OUTPUT_DIR/${OUTPUT_DIR}-nonhuman

bash $VIROMESCAN_PATH/viromescan/tools/bmtagger.sh -b $VIROMESCAN_PATH/viromescan/database/Bacteria_custom/bacteria_custom.bitmask -x $VIROMESCAN_PATH/viromescan/database/Bacteria_custom/bacteria_custom.srprism -T $OUTPUT_DIR/tmp -q1 -1 $OUTPUT_DIR/${OUTPUT_DIR}-nonhuman.fastq -X -o $OUTPUT_DIR/${OUTPUT_DIR}-filter-human-bacteria

bbduk.sh in=$OUTPUT_DIR/$OUTPUT_DIR-filter-human-bacteria.fastq out=$OUTPUT_DIR/$OUTPUT_DIR-filter-human-bacteria-polyA.fastq literal=AAAAAAAAAA k=4 ktrim=r  # trimpolya=20 trimpolyg=20

bowtie2 -x $DATABASE/new_bowtie2/human_ALL -q $OUTPUT_DIR/${OUTPUT_DIR}-filter-human-bacteria-polyA.fastq --very-sensitive-local --no-unal -S $OUTPUT_DIR/${OUTPUT_DIR}.filtered.sam -p $threads

awk 'substr ($0,1,1) == "@" || /XM:i:0[\t$]/ || /XM:i:1[\t$]/ || /XM:i:2[\t$]/ || /XM:i:3[\t$]/ || /XM:i:4[\t$]/ || /XM:i:5[\t$]/ {print}' $OUTPUT_DIR/$OUTPUT_DIR.filtered.sam |sed 's/XS:i:[0-9]*\t//g'> $OUTPUT_DIR/$OUTPUT_DIR.filtered.nomismatch.sam

samtools view -@ 30 -bS -q 10 -o $OUTPUT_DIR/$OUTPUT_DIR.filtered.nomismatch.bam $OUTPUT_DIR/$OUTPUT_DIR.filtered.nomismatch.sam

samtools sort -@ 30 -o $OUTPUT_DIR/${OUTPUT_DIR}.filtered.bam  $OUTPUT_DIR/${OUTPUT_DIR}.filtered.nomismatch.bam #.filtered.sam

samtools index $OUTPUT_DIR/${OUTPUT_DIR}.filtered.bam

###deduplication
umi_tools dedup -I $OUTPUT_DIR/${OUTPUT_DIR}.filtered.bam --output-stats=deduplicated -S $OUTPUT_DIR/${OUTPUT_DIR}.dedup.bam #--paired

###############
##Counting
###############
mkdir $OUTPUT_DIR/results

###counting per gene per sample and generate the final bam
featureCounts -T 30 -s 0 -M -a $VIROMESCAN_PATH/viromescan/database/refseq/human.all.gtf1 -t exon -g gene_id -o $OUTPUT_DIR/results/Gene_PerSample_level_results-Counts.txt -R BAM $OUTPUT_DIR/${OUTPUT_DIR}.dedup.bam

mv $OUTPUT_DIR/results/${OUTPUT_DIR}.dedup.bam.featureCounts.bam $OUTPUT_DIR/

samtools sort -@ 30 $OUTPUT_DIR/${OUTPUT_DIR}.dedup.bam.featureCounts.bam -o $OUTPUT_DIR/${OUTPUT_DIR}.final.bam

samtools index -@ 30 $OUTPUT_DIR/${OUTPUT_DIR}.final.bam

###counting per gene per cell
umi_tools count --per-gene --gene-tag=XT --assigned-status-tag=XS --per-cell -I $OUTPUT_DIR/${OUTPUT_DIR}.final.bam -S $OUTPUT_DIR/results/Gene_PerCell_level_results-Counts.txt.gz -L $OUTPUT_DIR/${OUTPUT_DIR}.umitools.gene.log.out -E $OUTPUT_DIR/${OUTPUT_DIR}.umitools.gene.log.err   #--paired 
#--extract-umi-method=tag --umi-tag=UB --cell-tag=CB --method cluster 
###counting per virus per cell
umi_tools count --per-contig --assigned-status-tag=XS --per-cell --method cluster -I $OUTPUT_DIR/${OUTPUT_DIR}.final.bam -S $OUTPUT_DIR/results/Species_PerCell_level_results-Counts.txt.gz -L $OUTPUT_DIR/${OUTPUT_DIR}.umitools.species.log.out -E $OUTPUT_DIR/${OUTPUT_DIR}.umitools.species.log.err
##--per-gene 
###counting per virus per sample
samtools idxstats $OUTPUT_DIR/${OUTPUT_DIR}.final.bam > $OUTPUT_DIR/final.genes.txt

cp $VIROMESCAN_PATH/viromescan/var/scviromescan.R $DATABASE/refseq/human.all.txt $OUTPUT_DIR

cp $VIROMESCAN_PATH/viromescan/var/HumanDNAcomplete.txt $OUTPUT_DIR 

cp $VIROMESCAN_PATH/viromescan/var/HumanALLcomplete.txt $OUTPUT_DIR 

cp $VIROMESCAN_PATH/viromescan/var/VirusALLcomplete.txt $OUTPUT_DIR 

cp $VIROMESCAN_PATH/viromescan/var/VirusDNAcomplete.txt $OUTPUT_DIR

cp $VIROMESCAN_PATH/viromescan/var/HumanALL+covid19complete.txt $OUTPUT_DIR

rm $OUTPUT_DIR/${OUTPUT_DIR}_R1_extracted.fastq.gz

rm $OUTPUT_DIR/${OUTPUT_DIR}_R2_extracted.fastq.gz

cd $OUTPUT_DIR/results

Rscript ../scviromescan.R

cd ../..

echo "Done."

