# NOTE- these HMMS were obtained by searching 'Transporter' into Interpro and pulling out those related Pfams (that is what the keyfiles txt file is)
# purpose of script is to download additional pfam HHMS into the appropiate directory 
# URLs for this download should be in txt file: AdditionalHMMS.txt
# command line: wget -i AdditionalHMMS.txt

#initialize variables 
TRANSPORTER_PROJ_DIR=$(realpath . )
DATA_DIR="${TRANSPORTER_PROJ_DIR}/data"

#we can check if AdditionalHMMS directory is made
#not not made then we make it
if [ -d "${DATA_DIR}/Pfams"]
    then
        echo "Pfams directory already made in appropiate place"
    else 
        echo "making Pfams directory in proper place"
        mkdir "${DATA_DIR}/Pfams"
    fi
#this script will then apprend onto it (../data/tcDoms/TcDoms_HHM)
#where TcDoms_HHM will be tcDoms/Tcdoms.tar/gz
cd "${DATA_DIR}/Pfams"

wget https://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.full.gz
md5csum ./Pfams-A.full.gz
#should match ead0eef504036f61635421be05234458 as off 8/2023 
#check https://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/md5_checksums
gunzip Pfams-A.full.gz

#should have a keyfiles_pfams.txt file for this next step

cd ..
cd ..
for id in `cat keyfile`; do grep $id Pfam-A.hmm | tr -s " " | cut -d " " -f 2; done > pfam_Ids

singularity exec --no-home --bind .:/Transporter_proj ./containers/hmmer.sif hmmfetch -f Transporter_proj/data/Pfams/Pfam-A.hmm Transporter_proj/data/Pfams/pfam_Ids > transporterPfams.hmm
singularity exec --no-home --bind .:/Transporter_proj ./containers/hmmer.sif hmmpress Transporter_proj/data/Pfams/transporterPfams.hmm
singularity exec --no-home --bind .:/Transporter_proj ./containers/hmmer.sif hmmsearch --cpu 16 --domtblout Transporter_proj/data/HMMsearchResults.TransporterPfams.domblout.tab Transporter_proj/data/Pfams/transporterPfams.hmm Transporter_proj/data/NPac.pan-assembly.bf100.id99.aa.fasta