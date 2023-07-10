"""

This script logs into Synapse portal and walks through a parent folder
to get a list of all entities present in it. It then preprocesses the
list into a Pandas DataFrame along with directory information.

Usage:
    ./synapse_fetch.py -i <input_synapse_id>

Requirement: Synapse Account and Configuration file (.synapseConfig)
        
This script requires the following modules to be imported:
    - pandas
    - synapseutils
    - synapseclient

Output:
    - synapse_ids.tsv
        A tab seperated file consisting of following columns
            - Directory: Directory name for file stored in Synapse portal
            - ParentID: ParentID of the Directory
            - Filename: Name of the file
            - EntityID: SynapseID for the entities under the parent

Returns:
    None. The script saves all the files to a output directory.

Author:
    Saim Momin <momin@ie-freiburg.mpg.de>

Last Updated:
    07-07-2023

"""
import os
import sys
import pandas as pd
import synapseutils
import synapseclient
import argparse
import warnings

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input_synapse_id",
                    metavar="ID",
                    help="Synapse ID for Query")
parser.add_argument("-o", "--output_file_dir",
                    metavar="PATH",
                    help="Path to output the Fetched Data")
args = parser.parse_args()


if not os.path.exists(os.path.expanduser("~/.synapseConfig")):
    raise FileNotFoundError("The Synapse Configuration file not found. Exiting!")
    sys.exit(0)

with open(os.path.expanduser("~/.synapseConfig")) as f:
    file = f.read().strip().split("\n")
    for i in file:
        if i.startswith("username"):
            user = i[11::] 
        elif i.startswith("authtoken"):
            token = str(i[12::])

syn = synapseclient.Synapse()
try:
    syn.login(email=user, authToken=token)
    print("Connection Established Successfully!")
except Exception as e:
    print("\nConnection failed:", str(e))
    warnings.simplefilter("ignore", UserWarning)
    print('\nPlease Check your Login Credentials. Exiting!!')

# Walking throw the Parent-ID and getting all the entities present in them
print("Retrieving the Requested Data...")
file_list = []
test2 = synapseutils.walk(syn, args.input_synapse_id)
for dirpath,dirname, filename in test2:
    for f in filename:
        file_info = {'dir': dirpath, 'file': f}
        file_list.append(file_info)

# Preprocessing for the fetched directory and file list from Parent ID
df = pd.DataFrame(file_list)
df1 = df.applymap(lambda x: str(x).replace("'", "").replace("(", "").replace(")", ""))
df1[['Directory', 'ParentID']] = df1['dir'].str.split(',', expand=True)
df1[['Samplename', 'SynapseID']] = df1['file'].str.split(',', expand=True)
df1.drop(['dir', 'file'], axis=1, inplace=True)
df1.to_csv(args.output_file_dir + "synapse_ids_all.tsv", sep="\t", index=False)

# Writing Sample and corresponding Synapse IDs
filtered_df = df1[df1['Samplename'].str.contains('R1|R2')]
filtered_df = filtered_df[['Samplename', 'SynapseID']]
filtered_df.to_csv(args.output_file_dir + "synapse_fastqs_ids.tsv",
                   sep="\t", index=False)

print("\nRetrieving Data Successfull...")
