import os

directory_path = '/data/manke/processing/momin/virome-scan/DGE/EBV/count_matrix' 

tsv_files = []
for root, dirs, files in os.walk(directory_path):
    for file in files:
        if file.endswith('.tsv'):
            tsv_files.append(os.path.join(root, file))

taxon_df = pd.DataFrame(columns=['Tax_ID'])
for file in tsv_files:
    df = pd.read_csv(file, sep='\t')
    taxon = df['Tax_ID']
    taxon_df = pd.merge(taxon_df,taxon,on='Tax_ID', how='outer')


for file in tsv_files:
    df2 = pd.read_csv(file, sep='\t')
    samplename = str(file.split('/')[-2])
    summed_data = df2.groupby('Tax_ID').sum().iloc[:, :].sum(axis=1).to_frame(samplename)
    taxon_df = pd.merge(taxon_df, summed_data, on='Tax_ID', how='left')

taxon_df = taxon_df.fillna(0)
taxon_df['Tax_ID'] = taxon_df['Tax_ID'].str.split('(').str[0].str.strip()
taxon_df.iloc[:, 1:] = taxon_df.iloc[:, 1:].astype(int)
taxon_df = taxon_df.rename(columns={'Tax_ID': 'Taxon'})
taxon_df.to_csv("/home/momin/count_matrix_summarized.tsv", sep='\t', index=False)
taxon_df