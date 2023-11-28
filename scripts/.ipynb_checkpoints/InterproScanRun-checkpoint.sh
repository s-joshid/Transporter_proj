date 
./my_interproscan/interproscan-5.63-95.0/interproscan.sh --cpu 16 -i ./RandomizedReformatted.fasta -f tsv -goterms -b ./Transporter_proj/data/InterproRandomizedRun 2>&1 | tee log.txt
date

#to see progress:
# cat subsetTest.tsv | cut -d $'\t'  -f 1 | sort -u | wc -l