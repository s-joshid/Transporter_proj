#!/bin/bash
#Tcdoms download URL: https://tcdb.org/public/tcDoms.tar.gz 
#Pfams download URL: https://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.gz 
#script with use tcDoms and pfams hmms to annotate protein sequences 

#initalizing variables
TRANSPORTER_PROJ_DIR=$(realpath . )
DATA_DIR="${TRANSPORTER_PROJ_DIR}/data"
#modify with whatever fasta protein file you would like to annotate 
PROTEINS_DIR="${DATA_DIR}/small_Npac.fasta"
OUTPUT="${DATA_DIR}/HMMSearch_Tc_Pfam_Results.tcDoms.domblout.tab"
ANNOTATED="${DATA_DIR}/best_annotations.csv"
if [ ! -e ${TRANSPORTER_PROJ_DIR}/containers ]; then
    mkdir ${TRANSPORTER_PROJ_DIR}/containers
fi
#make sure hmmer.sif container is in singularity
if [ ! -e ${TRANSPORTER_PROJ_DIR}/containers/hmmer.sif ]; 
then
    cd ${TRANSPORTER_PROJ_DIR}/containers 
    singularity build hmmer.sif docker://biocontainers/hmmer:v3.2.1dfsg-1-deb_cv1
    cd .
fi 
#making sure tcDoms.tar.gz is downloaded correctly 
if [ ! -e "${DATA_DIR}/tcDoms/" ]; then 
    echo "please make sure you have tcDoms HMM downloaded to the correct file path."  
fi
#tcDoms.hmm.tar.gz is downloaded correctly 
#now checking if we have it unzipped and untarred
if [ ! -e "${DATA_DIR}/tcDoms/tcDomsGlobal" ];
then
    #in here if hmm file is not untarred and unzipped
    cd "${DATA_DIR}/tcDoms"
    tar -zxvf tcDoms.tar.gz
    cd ..
    cd ..
fi 
#making sure pfams are downloaded correctly 
if [ ! -e "${DATA_DIR}/Pfams/" ]; then 
    echo "please make sure you have Pfams HMM downloaded to the correct file path."  
fi

#tcDoms HMM should be untarred & unzipped at this point 
TCDOMS_HMMS="${DATA_DIR}/tcDoms/tcDoms/tcDomsGlobal/tcDoms.hmm "

#Pfam-A.hmm.gz is downloaded correctly 
#now checking if we have it unzipped and untarred
if [ ! -e "${DATA_DIR}/Pfams" ];
then
    #in here if hmm file is not untarred and unzipped
    cd "${DATA_DIR}/Pfams"
    tar -zxvf Pfam-A.hmm.gz
    cd ${TRANSPORTER_PROJ_DIR}
fi 
#pfams HMM should be untarred & unzipped at this point 
Pfams_HMMS="${DATA_DIR}/Pfams/Pfam-A.hmm "

cat '${TCDOMS_HMMS}' '${Pfams_HMMS}' > '${DATA_DIR}/pfam_tcdoms_hmms'

HMMS="${DATA_DIR}/pfam_tcdoms_hmms"

singularity exec --no-home --bind ${TRANSPORTER_PROJ_DIR}:/Transporter_proj ${TRANSPORTER_PROJ_DIR}/containers/hmmer.sif \
    hmmpress ${HMMS}

#performing hmmsearch, outputting results in data dir
singularity exec --no-home --bind ${TRANSPORTER_PROJ_DIR}:/Transporter_proj ${TRANSPORTER_PROJ_DIR}/containers/hmmer.sif \
    hmmsearch --domtblout "${OUTPUT}" \
    "${HMMS}" "${PROTEINS_DIR}"
