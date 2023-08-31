#!/usr/bin/env python
import pandas as pd
import argparse
import os
def handle_arguments():
    description = '''This script parses the tcDoms domtblout file,
        selects the top scoring annotation for each protein listed in the
        file, and then outputs a csv of the parsed and down-selected data.

        Example usage: ./best_tcDoms.py -f domtblout.tab annotations.csv
        '''
    parser = argparse.ArgumentParser(description = description)
    parser.add_Argument('input' , type=str, help = 'Input domtblout file' )
    parser.add_Argument('output', type = str, help = 'Output file')
    return parser
def main():
    parser = handle_arguments()
    args = parser.parse_args()
    output_path = args.output
    if os.path.isfile(output_path):
        raise FileExistsError('A file by the name of {} already exists.'.format(output_path))
    print("Parsing Domblout file", flush = True)
    df =pd.read_csv(
        args.input,
        engine = 'python',
        sep ='\s+',
        skiprows = [0,1,2],
        skipfooter = 10,
        usecols = [0,3,6,7],
        names = ['Target_name', 'query_name', 'E-value', 'Score']
        ) 
    print("Selecting the best annotation for each protein", flush = True)
    df['score'] = df['score'].astype(float)
    best_annot_df = df.iloc[df.groupby(['query_name']).score.idxmax()]
    best_annot_df.reset_index(drop = True, inplace = True)


    best_annot_df.to_csv(args.output, index = False)
    print('Finished')
if __name__ == "__main__":
    main()
