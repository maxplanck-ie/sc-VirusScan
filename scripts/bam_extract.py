import pandas as pd
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input_file", metavar="PATH", help="Path to your SAM file")
parser.add_argument("-k", "--kraken_input_file", metavar="FILE", help="Path of your .kraken file from Kraken output")
parser.add_argument("-b", "--barcode_file", metavar="FILE", help="Filtered Barcodes tsv file generated from Cell Ranger")
parser.add_argument("-o", "--output-file", metavar="PATH", help="Path to your output file")

args = parser.parse_args()
file = args.input_file
tags_dict = {}  

#TODO: Check if the Kraken file is empty 

#Parsing SAM file and storing ReadName along with its TAGS in dictionary
with open(file) as f:
    for line in f:
        if line.startswith("@"):   #Skipping header
            continue
        fields = line.strip().split("\t")  
        read_name = fields[0]  
        entries = fields[11:]  
        
        for tag in entries:
            tag_fields = tag.split(":")
            tag_name = tag_fields[0]
            tag_value = tag_fields[2]
            if tag_name in ["CR", "CB", "UR", "UB"]:  
                if read_name in tags_dict:
                    tags_dict[read_name][tag_name] = tag_value   #Adding tag to existing existing dictionary for the read name
                else:
                    tags_dict[read_name] = {tag_name: tag_value}  #Else creating new dictionary and adding rag to it                
#Converting them to Pandas Dataframe
df = pd.DataFrame.from_dict(tags_dict, orient='index')  
df.index.name = "Read Name"  
df.reset_index(inplace=True)
df1 = df.drop_duplicates(subset=['CR','UR'],keep = 'last').reset_index(drop = True)
print(df1.head())


#Reading Kraken Output and merging with the previous Dataframe
columns_name = ['status', 'Read Name', 'Tax_ID', 'length', 'LCA_mapping']
df2 = pd.read_csv(args.kraken_input_file,sep='\t',names=columns_name, index_col=None)
merged = pd.merge(df1,df2,on='Read Name', how='inner')
merged_subset = merged.loc[:, ['Read Name', 'Tax_ID', 'CR', 'CB','UR', 'UB']]
print(merged_subset.head())

#Filtering dataframe based on barcodes reported by CellRanger
barcodes = pd.read_csv(args.barcode_file, compression='gzip',sep='\t', names=['CR'])
barcodes.CR = [x.strip().replace('-1', '') for x in barcodes.CR]
merged_barcodes = pd.merge(merged_subset,barcodes,on='CR', how='inner')
print(merged_barcodes.head())


#Creating a count matrix and writing it to a file
result = merged_barcodes.pivot_table(index='Tax_ID', columns='CR', values='Read Name', aggfunc='count').fillna(0.).astype(int)
result.to_csv(args.output_file + "count_matrix.tsv", sep='\t')
