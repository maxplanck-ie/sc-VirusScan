"""
Summarizes and performs plotting of Clustermap for the total reads counts assigned for each family and species by Kraken2.

This script processes all the Kraken2.report.txt files Kraken2 tool and organizes the number of reads(fragments)
mapped to each family and species level. The output of the scripts are two tab-separated files consisting of reads 
mapped to Family level and Species level respectively. Depending on the TSV files, a clustermap is plotted to analyze 
the distribution of taxons in the all report files of the samples. The Clustermap are saved to PNG file in the directory
specified by the user. 

Usage: 
    ./kraken_plot.py -i <input_file_directory> -o <output_file_directory> 

Outputs:
    - familywise_taxonomic_readcounts.tsv
    - specieswise_taxonomic_readcounts.tsv
    - clustermap_familywise_log10.png
    - clustermap_specieswise_log10.png

Returns:
    None. The script saves all the files to a output directory.

Author:
    Saim Momin <momin@ie-freiburg.mpg.de>

Last Updated:  
    06-04-2023

"""

import pandas as pd
import seaborn as sns
import numpy as np
import matplotlib.pyplot as plt
import scipy
import glob
import os
import argparse


parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input_file_directory", metavar="PATH", help="Path to master directory Kraken2 report files")
parser.add_argument("-o", "--output_file_directory", metavar="PATH", help="Path to directory for output files")
args = parser.parse_args()

path = args.input_file_directory
dirs = [os.path.join(path, d) for d in os.listdir(path) if os.path.isdir(os.path.join(path, d))]

kraken_files = []
family_data = pd.DataFrame(columns=['Taxon'])
species_data = pd.DataFrame(columns=['Taxon'])

for directory in dirs:
    kraken_files.extend(glob.glob(os.path.join(directory, '*.txt')))
   
for file in kraken_files:
    df = pd.read_csv(file, sep='\t', names=["Perc", "Reads_covered", "Reads_Assigned", "Order", "Tax_ID", "Taxon"])
    df1 = df.loc[df['Order'] == 'F'].sort_values("Reads_covered", ascending=False)          #Fetching Families rows
    df2 = df.loc[df['Order'] == 'S'].sort_values("Reads_covered", ascending=False)          #Fetching Species rows
    
    df1 = df1[['Taxon', 'Reads_covered']]
    df2 = df2[['Taxon', 'Reads_covered']]
    
    df1['Taxon'] = df1['Taxon'].str.replace('\s+', '', regex=True)                  #Removing whitespaces 
    df2['Taxon'] = df2['Taxon'].str.replace('\s+', '', regex=True)
    
    filename = os.path.basename(file).split(".")[0]
    df1 = df1.rename(columns={'Reads_covered': filename})                           #Changing column name to filename
    df2 = df2.rename(columns={'Reads_covered': filename})
    
    family_data = pd.merge(family_data, df1, on='Taxon', how='outer')               #Merging out all columns
    species_data = pd.merge(species_data, df2, on='Taxon', how='outer')
    
cols = [family_data.columns[0]] + sorted(family_data.columns[1:])                   #Sorting the columns 
cols2 = [species_data.columns[0]] + sorted(species_data.columns[1:])

family_data = family_data[cols]
species_data = species_data[cols2]

family_data.to_csv(args.output_file_directory + "familywise_taxonomic_readcounts.tsv", sep='\t', index=False)
species_data.to_csv(args.output_file_directory + "specieswise_taxonomic_readcounts.tsv", sep='\t', index=False)    
    
# --- Plotting Clustermap for Taxon ---
family_map = family_data.set_index("Taxon")
family_map_log10 = family_map.apply(lambda x: np.log10(x) if np.issubdtype(x.dtype, np.number) else x)                   #Log10 transformation
family_map_cleaned = family_map_log10.fillna(0)                                                                          #Filling missing values 
sns.set(rc={"figure.figsize": (80,60)})
sns.set(font_scale=0.6)
g = sns.clustermap(family_map_cleaned, cmap="coolwarm", xticklabels=True, yticklabels=True)
g.ax_heatmap.yaxis.set_tick_params(labelsize=4)
plt.title("Family-Wise Clustermap")
plt.suptitle("Family-Wise Clustermap", ha="center", va="center", fontsize=14, y=1.0)
plt.ylabel("Read Counts (log10)")
g.savefig(args.output_file_directory + "clustermap_familywise_log10.png", dpi=1200)
plt.show()


# --- Plotting Clustermap for Top-10 Species ---
species_data['maximum'] = species_data.max(axis=1,numeric_only=True)                                   #Getting maximum reads
sorted_species_data = species_data.sort_values(by = 'maximum', ascending = False)
top_10_species = sorted_species_data.head(10)
species_map = top_10_species.set_index("Taxon")
species_map_log10 = species_map.apply(lambda x: np.log10(x) if np.issubdtype(x.dtype, np.number) else x)                   #Log10 transformation
species_map_cleaned = species_map_log10.fillna(0)                                                                          #Filling missing values 
species_map_data = species_map_cleaned.loc[:, species_map_cleaned.columns != "maximum"]
sns.set(rc={"figure.figsize": (80,60)})
sns.set(font_scale=0.6)
g = sns.clustermap(species_map_data, cmap="coolwarm", xticklabels=True, yticklabels=True)
g.ax_heatmap.yaxis.set_tick_params(labelsize=4)
plt.title("Species-Wise Clustermap")
plt.suptitle("Species-Wise Clustermap (Top 10 Species)", ha="center", va="center", fontsize=14, y=1.0)
plt.ylabel("Read Counts (log10)")
g.savefig(args.output_file_directory + "clustermap_specieswise_log10.png", dpi=1200)
plt.show()

print("--- Script Completed Successfully ---")