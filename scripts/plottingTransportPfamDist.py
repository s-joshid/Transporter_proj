#!/usr/bin/env python
import pandas as pd
import numpy as np
import seaborn as sns
import argparse
import os
#handle_arguments is for taking user input for where to output file
def handle_arguments():
  #helps user see what they need to input
  description = '''This script parses the pfams domtblout file,
        and plots the domain distribution across transporter classes using 
        the pfams to TcDoms mapping file 
        Example usage: 
        ./best_tcDoms.py -f domtblout.tab annotations.csv pfam2TC.csv
        '''
  #outputs decription
  parser = argparse.ArgumentParser(description = description)
  #add input and output requirements; help gives user more info abt what to put
  #input is filepath
  #output is annotates proteinsin a csv
  parser.add_argument('pfams_result' , type=str, help = 'Input domtblout file' )
  parser.add_argument('mapping_file', type = str, help = 'pfams to tcDoms mapping file')
  return parser

def main():
  parser = handle_arguments()
  #parses arguments into
  args = parser.parse_args()
  print('parsing Domblout files')
  pfams_df = pd.read_csv(args.pfams_result,
                 engine = 'python',
                 skiprows = [0],
                 names = ['Target_name', 'query_name', 'pfam_ID', 'E-value', 'Score'],
    )

  pfams_df['pfam_ID'] = pfams_df['pfam_ID'].astype(str).str.replace(r'\.\d+', '', regex=True )
  tc2p_df = pd.read_csv(args.mapping_file,
                 engine = 'python',
                 skiprows = [0],
                 usecols= [0,1],
                 names = ['pfam_ID', 'TC'])
  tc2p_df = pd.DataFrame(tc2p_df.groupby('pfam_ID')['TC'].agg(list).reset_index())
  merged = pd.merge(pfams_df, tc2p_df, how = 'left', on = 'pfam_ID')
  print (merged.head())
  # splitting the first TC_id in the list of TC IDs
  merged_new = merged.join(merged['TC'].str[0].str.split('.', expand = True))
  merged_new = merged_new.rename(columns = ({0:'Transporter_class', 1:'Transporter_subclass'})
  print (merged_new.head())
  merged_new = merged_new.dropna(subset = ['Transporter_class'])
  merged_new['Transporter_class'] = merged_new['Transporter_class'].astype(int).map({
    1: 'Channels/pores', 2: 'Electrochemical Potential-driven', 3: 'Primary Active Transporter', 4: 'Group Translocators', 5: 'Transmembrane electron carriers', 6: 'N/a', 7: 'N.a', 8: 'Accessory Factors', 9: 'Incompletely Characterized'
    })
  plot_df = merged_new.sort_values('Transporter_class')
  plot = sns.histplot(data=plot_df, x= 'Transporter_class')
  plot.set_xticklabels(plot.get_xticklabels(), rotation = 90)
  plot.set_title('Domains Categorized by Transporter Class for Transport pfams')
  plot.show()
  print('Finished')
if __name__ == "__main__":
  main()


