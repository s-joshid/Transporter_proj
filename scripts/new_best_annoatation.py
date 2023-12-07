#!/usr/bin/env python
import pandas as pd
import argparse
import os
def handle_arguments():
    description = '''This script parses the tcDoms and pfams domtblout file,
        selects the top scoring annotation for each protein listed in the
        files, and then outputs a csv of the parsed and down-selected data. 
        each protein is also mapped to it's TCdoms ID if applicable. This 
        mapping file is obtained from running the custom_mapping.py script.

        Example usage: ./best_tcDoms.py -f tc.domtblout.tab pfams.domtblout.tab annotations.csv
        '''
    parser = argparse.ArgumentParser(description = description)
    parser.add_argument('hmm_results' , type=str, help = 'Input combined hmmsearch domtblout file' )
    parser.add_argument('mapping', type=str, help = 'Input path to custom mapping file')
    parser.add_argument('output', type=str, help = 'Output file')
    return parser
def main():
    parser = handle_arguments()
    args = parser.parse_args()
    output_path = args.output
    if os.path.isfile(output_path):
        raise FileExistsError('A file by the name of {} already exists.'.format(output_path))
    mapping_df = pd.read_csv(args.mapping,
        engine = 'python',
        skiprows = [0],
        usecols= [0, 1, 2, 3, 4, 5],
        names = ['hmm_ID', 'class_', 'subclass', 'family', 'subfamily', 'substrate']
        )
    print("Parsing Domblout file", flush = True)
     #load in pfam annotations
    hmms_df = pd.read_csv(args.hmm_results,
                 engine = 'python',
                 skiprows = [0, 1, 2],
                 usecols = [0, 3, 4, 6, 7], 
                 names = ['target_name', 'desc', 'hmm_ID', 'E_value', 'Score']
    )
    #format the pfam_id properly
    #index: row label
    #row: row content 

    for r in hmm_df.iterrows():
        if 'PF' in row[hmm_ID]:
            hmm_df.loc[index, 'hmm_ID'] = row['hmm_ID'].replace(r'\.\d+', '', regex=True)




    #combining the pfams & tc dfs + renaming
    df_hmm = df_hmm.reset_index(drop = 2)
    df_hmm['E_value'] = df_hmm['E_value'].astype(float)
    df_hmm
    #finding best annoatation b/n pfam + tc
    print("Selecting the best annotation for each protein", flush = True)
    df_final = df_hmm.iloc[df_hmm.groupby(['target_name']).E_value.idxmin()]
    df_final = df_final.reset_index(drop = 2)
    #incorporating mapping to TC ID
    df_final = df_final.merge(mapping_df, on = 'hmm_ID')
    df_final.to_csv(args.output, index = False)
    print('Finished')
if __name__ == "__main__":
    main()
