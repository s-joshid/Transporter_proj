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
  #gets parser obj from handle_arguments
  parser = handle_arguments()
  #parses arguments into
  args = parser.parse_args()
  #make sure output path is valid
  output_path = args.output
  #checks weather given path is an existing file or not
  if os.path.isfile(output_path):
     raise FileExistsError('A file by the name of {} already exists.'.format(output_path))

  #parse tcDoms Domtblout file
  #outputs get placed into a dataframe
  print("Parsing Domblout file", flush = True)
  df =pd.read_csv(
      args.input,
      engine = 'python',
      sep ='\s+',
      skiprows = [0,1,2],
      skipfooter = 10,
      usecols = [0,3,5,6],
      names = ['Target_name', 'query_name', 'E-value', 'Score']
  )
  #taking the best result for each query
  print("Selecting the best annotation for each protein", flush = True)
  df['score'] = df['score'].astype(float)
  best_annot_df = df.iloc[df.groupby(['query_name']).score.idxmax()]
  best_annot_df.reset_index(drop = True, inplace = True)

  #save results to csv
  best_annot_df.to_csv(args.output, index = False)
  print('Finished')
  if __name__ == "__main__":
    main()


