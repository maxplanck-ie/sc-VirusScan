"""

This script logs into Synapse portal and walks through a parent folder to get a list of all entities present in it. 
It then preprocesses the list into a Pandas DataFrame along with directory information. 

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
            - Directory: Directory name for a file stored in Synapse portal for a ParentID
            - ParentID: ParentID of the Directory
            - Filename: Name of the file 
            - EntityID: SynapseID for the entities under the parent

Returns:
    None. The script saves all the files to a output directory.

Author:
    Saim Momin <momin@ie-freiburg.mpg.de>

Last Updated:  
    12-04-2023
    
"""

import pandas as pd
import synapseutils
import synapseclient
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input_synapse_id", metavar="ID", help="Synapse ID for Query")
args = parser.parse_args()


with open("/home/momin/.synapseConfig") as f:
    file = f.read().strip().split("\n")
    for i in file:
        if i.startswith("username"):
            user = i[11::] 
        elif i.startswith("authtoken"):
            token = str(i[12::])

syn = synapseclient.Synapse()
syn.login(email=user, authToken=token)

#Walking throw the Parent-ID and getting all the entities present in them
file_list = []
test2 = synapseutils.walk(syn, args.input_synapse_id)
for dirpath,dirname, filename in test2:
    for f in filename:
        file_info = {'dir': dirpath, 'file': f}
        file_list.append(file_info)

#Preprocessing for the fetched directory and file list from Parent ID
df = pd.DataFrame(file_list)
df1 = df.applymap(lambda x: str(x).replace("'", "").replace("(", "").replace(")", ""))
df1[['Directory', 'ParentID']] =  df1['dir'].str.split(',', expand=True)
df1[['Filename', 'EntityID']] = df1['file'].str.split(',', expand=True)
df1.drop(['dir', 'file'],axis=1, inplace=True)
df1.to_csv("synapse_ids.tsv", sep="\t", index=False)

#TODO: Get the list of Synapse ids only with .fastq.gz command




#TODO: Work on the downloading part and storing it in the directory. Possibly by multithreading approach (Discuss?)






