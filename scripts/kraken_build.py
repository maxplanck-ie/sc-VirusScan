import pandas as pd
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input_families_list",
                    metavar="PATH",
                    help="Path to input txt file consisting of Families Names")

parser.add_argument("-names", "--input_names_dmp",
                    metavar="PATH",
                    help="Path to input names.dmp file")

parser.add_argument("-acc", "--input_refseq_acc",
                    metavar="PATH",
                    help="Path to input RefSeq AccesionID file")

parser.add_argument("-ngb", "--input_nucl_gb",
                    metavar="PATH",
                    help="Path to input nucl_gb.accession2taxid file")

parser.add_argument("-nodes", "--input_nodes_dmp",
                    metavar="PATH",
                    help="Path to input nodes.dmp file")

parser.add_argument("-out", "--output_acc_path",
                    metavar="PATH",
                    help="Path to save filtered accession list")

args = parser.parse_args()

# Step 1: Reading the Families text file and extracting corresponding TaxIDs from names.dmp file
with open(args.input_families_list, 'r') as f:
    families = list(f.read().splitlines())

fam2taxid = {}
with open(args.input_names_dmp, "r") as file:
    for line in file:
        data = line.split("|")
        taxid = data[0].strip()
        taxname = data[1].strip()
        if taxname in families:
            fam2taxid[taxname] = int(taxid)
fam_list = [i for i in fam2taxid.values()]

# Step 2: Retreiving the NCBI Accession IDs for each TaxID from nucl_gb.accession2taxid file
virus_accession = pd.read_csv(args.input_refseq_acc, names=['accession.version'])
accession2taxid = pd.read_csv(args.input_nucl_gb, sep="\t")
result = virus_accession.merge(accession2taxid, on='accession.version', how='left')
result = result[['accession.version', 'taxid']]
result2 = result.dropna(subset=['taxid'])
result2.taxid = result2.taxid.astype(int)
taxid_to_trace = sorted(set(result2["taxid"]))

# Function to backtrace until Family TaxID for a given TaxID


def taxatrace(tax_id, df):
    path = [tax_id]
    for i in range(len(df)):
        row = df[df['TaxID'] == tax_id]
        if len(row) == 0:
            break
        parent_id = row['ParentID'].values[0]
        if tax_id != parent_id:
            level = row['Level'].values[0]
            if level == 'family':
                path.append(parent_id)
                break
            else:
                path.append(parent_id)
                tax_id = parent_id
        else:
            break
    return path


# Step 3: Backtracing the TaxIDs(2) until Family Level
nodes = pd.read_csv(args.input_nodes_dmp,
                    sep="|", usecols=[0, 1, 2],
                    names=['TaxID', 'ParentID', 'Level'])
nodes = nodes.replace('\t', '', regex=True)
path_trace = []
for i in taxid_to_trace:
    path = taxatrace(i, nodes)
    path_trace.append(path)

# Step 4: Filtering from Backtracing Step to only keep results of Families of Interest
filtered_list = [x for x in path_trace if any(y in x for y in fam_list)]
filtered_taxid = [element[0] for element in filtered_list]

# Step 5: NCBI Accession List Filtering
filtered_accessions = result2[result2['taxid'].isin(filtered_taxid)]
filtered_accessions.to_csv(args.output_acc_path + "viral_families.tsv",
                           sep='\t', index=False)
