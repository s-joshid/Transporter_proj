#!/usr/bin/env python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import argparse
import os
#handle_arguments is for taking user input for where to output file
def handle_arguments():
  #helps user see what they need to input
  description = '''This script takes the tcdoms input, and pfams input
        to return the number of unique proteins per HMM
        as well as other vital information. 
        Script assumes you have already ran custom mapping script.
        Example usage:
        ./HMM_comparison.py -f tcDoms_annotations.csv pfams_annotations.csv pfam2TC.csv
        '''
  #outputs decription
  parser = argparse.ArgumentParser(description = description)
  #add input and output requirements; help gives user more info abt what to put
  #input is filepath
  parser.add_argument('tc_result' , type=str, help = 'Input tcDoms annotated csv file' )
  parser.add_argument('pfams_result' , type=str, help = 'Input pfams annotated file' )
  parser.add_argument('output', type = str, help = 'output path for resulting csv file')
  return parser
def main():
  parser = handle_arguments()
  #parses arguments into
  args = parser.parse_args()
  print('parsing files')
  #checks if output file already exists
  output_path = args.output
  if os.path.isfile(output_path):
      raise FileExistsError('A file by the name of {} already exists.'.format(output_path))
  mapping_df = pd.read_csv('./data/custom_mapping.csv',
                         engine = 'python',
                         skiprows = [0],
                         usecols= [0, 1, 2, 3, 4, 5],
                         names = ['hmm_ID', 'class_', 'subclass', 'family', 'subfamily', 'substrate']
  )
  tcdoms_df = pd.read_csv(args.tc_result,
    engine='python',
    skiprows=[0],
    #usecols returns subset of cols
    usecols=[0,1,3,4],
    #names what col names you want to use
    #have to switch target and query name to match pfams method
    names=['hmm_ID' , 'target_name', 'E_value', 'Score']
    )
  pd.set_option('display.max_columns', None)
  print('TCDOMS_DF')
  print(tcdoms_df)
  pfams_df = pd.read_csv(args.pfams_result,
                 engine = 'python',
                 skiprows = [0],
                 names = ['target_name', 'query_name', 'hmm_ID', 'E_value', 'Score']
    )
  #format the pfam_id properly 
  pfams_df['hmm_ID'] = pfams_df['hmm_ID'].str.replace(r'\.\d+', '', regex=True )
  print('PFAMS_DF')
  print(pfams_df.head())
  #combining the pfams & tc dfs + renaming 
  df_hmm = pd.concat([pfams_df, tcdoms_df])
  df_hmm = df_hmm.reset_index(drop = 2)
  df_hmm['E_value'] = df_hmm['E_value'].astype(float)
  print("DF_HMM")
  print(df_hmm.head())
  #finding best annoatation b/n pfam + tc 
  df_final = df_hmm.iloc[df_hmm.groupby(['target_name']).E_value.idxmin()]
  df_final = df_final.reset_index(drop = 2)
  print('DF_FINAL')
  print(df_final.head())
  prot_counts = pd.DataFrame(df_final.value_counts('hmm_ID'))
  prot_counts = prot_counts.reset_index()
  prot_counts = prot_counts.rename(columns = {0:'counts'})
  prot_counts = prot_counts.merge(mapping_df, on = 'hmm_ID')
  print("prot_counts_DF")
  print(prot_counts.head())
  prot_counts.to_csv(args.output, index = False)
if __name__ == "__main__":
  main()
