"""
Summarizes Kraken2 reports and plots Clustermap for
the total reads counts assigned to each family/species by Kraken2.

This script processes all the Kraken2.report.txt files Kraken2 tool and
organizes the number of reads(fragments) mapped to each family and species
level. The output of the scripts are two tab-separated files consisting of
reads mapped to Family level and Species level respectively. Depending on
the TSV files, a clustermap is plotted to analyze the distribution of taxons
in the all report files of the samples. The Clustermap are saved to PNG file
in the directory specified by the user.

Usage:
    ./kraken_plot.py -i <input_file_directory> -o <output_file_directory>

Outputs:
    - Familywise_tax_readcounts.tsv
    - Specieswise_tax_readcounts.tsv
    - Clustermap_Familywise_log10.png
    - Clustermap_Specieswise_log10.png

Returns:
    None. The script saves all the files to a output directory.

Author:
    Saim Momin <momin@ie-freiburg.mpg.de>

Last Updated:
    07-07-2023

"""

import pandas as pd
import seaborn as sns
import numpy as np
import matplotlib.pyplot as plt
import os
import argparse


parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input_file_directory",
                    metavar="PATH",
                    help="Path to master directory Kraken2 report files")

parser.add_argument("-o", "--output_file_directory",
                    metavar="PATH",
                    help="Path to directory for output files")

args = parser.parse_args()


path = args.input_file_directory
family_data = pd.DataFrame(columns=['Taxon'])
species_data = pd.DataFrame(columns=['Taxon'])
kraken_files = []

for root, dirs, files in os.walk(path):
    for file in files:
        if file.endswith(".report.txt"):
            file_path = os.path.join(root, file)
            kraken_files.append(file_path)

print("\n --- Kraken2 Reports Summarization Script ---\n")
print("\n Specified Input directory: ", args.input_file_directory)
print("\n Specified Output directory: ", args.output_file_directory)
print("\n Total Kraken2 Reports Detected: ", len(kraken_files))

for file in kraken_files:
    df = pd.read_csv(file, sep='\t',
                     names=["Perc", "Reads_covered", "Reads_Assigned", "Order",
                            "Tax_ID", "Taxon"])
    # Fetching Families and Species rows
    df1 = df.loc[df['Order'] == 'F'].sort_values("Reads_covered",
                                                 ascending=False)
    df2 = df.loc[df['Order'] == 'S'].sort_values("Reads_covered",
                                                 ascending=False)

    df1 = df1[['Taxon', 'Reads_covered']]
    df2 = df2[['Taxon', 'Reads_covered']]

    # Removing whitespaces
    df1['Taxon'] = df1['Taxon'].str.replace('\s+', '', regex=True)
    df2['Taxon'] = df2['Taxon'].str.replace('\s+', '', regex=True)

    # Changing column name to filename
    filename = os.path.basename(file).split(".")[0]
    df1 = df1.rename(columns={'Reads_covered': filename})
    df2 = df2.rename(columns={'Reads_covered': filename})

    # Merging out all columns
    family_data = pd.merge(family_data, df1, on='Taxon', how='outer')
    species_data = pd.merge(species_data, df2, on='Taxon', how='outer')

# Sorting the columns
cols = [family_data.columns[0]] + sorted(family_data.columns[1:])
cols2 = [species_data.columns[0]] + sorted(species_data.columns[1:])

family_data = family_data[cols]
species_data = species_data[cols2]
family_data.to_csv(args.output_file_directory +
                   "Familywise_tax_readcounts.tsv", sep='\t',
                   index=False)
species_data.to_csv(args.output_file_directory +
                    "Specieswise_tax_readcounts.tsv", sep='\t',
                    index=False)

print("\n Processing Completed! Now Plotting Clustermaps")

# --- Plotting Clustermap for Taxon ---
family_map = family_data.set_index("Taxon")
family_map_log10 = family_map.apply(lambda x: np.log10(x) if np.issubdtype(x.dtype, np.number) else x)
family_map_cleaned = family_map_log10.fillna(0)
sns.set(rc={"figure.figsize": (80, 60)})
sns.set(font_scale=0.6)
g = sns.clustermap(family_map_cleaned,
                   cmap="coolwarm",
                   xticklabels=True,
                   yticklabels=True)
g.ax_heatmap.yaxis.set_tick_params(labelsize=4)
plt.title("Family-Wise Clustermap")
plt.suptitle("Family-Wise Clustermap",
             ha="center", va="center", fontsize=14, y=1.0)
plt.ylabel("Read Counts (log10)")
g.savefig(args.output_file_directory +
          "Clustermap_Familywise_log10.png", dpi=1200)
plt.show()


# --- Plotting Clustermap for Top-10 Species ---
species_data['maximum'] = species_data.max(axis=1, numeric_only=True)
sorted_species_data = species_data.sort_values(by='maximum', ascending=False)
top_10_species = sorted_species_data.head(10)
species_map = top_10_species.set_index("Taxon")
species_map_log10 = species_map.apply(lambda x: np.log10(x) if np.issubdtype(x.dtype, np.number) else x)
species_map_cleaned = species_map_log10.fillna(0)
species_map_data = species_map_cleaned.loc[:, species_map_cleaned.columns != "maximum"]
sns.set(rc={"figure.figsize": (80, 60)})
sns.set(font_scale=0.6)
g = sns.clustermap(species_map_data, cmap="coolwarm",
                   xticklabels=True, yticklabels=True)
g.ax_heatmap.yaxis.set_tick_params(labelsize=4)
plt.title("Species-Wise Clustermap")
plt.suptitle("Species-Wise Clustermap (Top 10 Species)",
             ha="center", va="center", fontsize=14, y=1.0)
plt.ylabel("Read Counts (log10)")
g.savefig(args.output_file_directory +
          "Clustermap_Specieswise_log10.png", dpi=1200)
plt.show()

print("\n--- Script Completed Successfully! ---\n")
