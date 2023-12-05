#!/bin/bash
#script will annotate the North Pacific aa sequences 
#ensure that the pfam HHMs are downloaded under data/
#URL: https://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.gz 
#initalizing variables 
# script is based on being in Transporter_proj folder
TRANSPORTER_PROJ_DIR=$(realpath . )
DATA_DIR="${TRANSPORTER_PROJ_DIR}/data"
#using test protein file; modify with whatever protein file you would like to annotate 
PROTEINS_DIR="${DATA_DIR}/knownTransporters.fa"
OUTPUT="${DATA_DIR}/pfamsHMMSearchtcDomsResults.tcDoms.domblout.tab"
CONTAINER="${TRANSPORTER_PROJ_DIR}/containers"
#now need to make sure hmmer.sif container is in singularity... maybe make this into it's own directory 
if [ ! -e ${TRANSPORTER_PROJ_DIR}/containers/hmmer.sif ]; 
then
    cd ${CONTAINER}
    singularity build hmmer.sif docker://biocontainers/hmmer:v3.2.1dfsg-1-deb_cv1
    cd ..
fi 

#making sure tcDoms.tar.gz is downloaded correctly 
if [ ! -e "${DATA_DIR}/Pfams/" ]; then 
    echo "please make sure you have Pfams HMM downloaded to the correct file path."  
fi
#Pfam-A.hmm.gz is downloaded correctly 
#now checking if we have it unzipped and untarred
if [ ! -e "${DATA_DIR}/Pfams" ];
then
    #in here if hmm file is not untarred and unzipped
    cd "${DATA_DIR}/Pfams"
    tar -zxvf Pfam-A.hmm.gz
    cd ${TRANSPORTER_PROJ_DIR}
fi 

#tcDoms HMM should be untarred & unzipped at this point 
Pfams_HMMS="${DATA_DIR}/Pfams/Pfam-A.hmm "

#now we should have tcDoms.hmm acessible and a hmmer container 
#want to do hmmpress now so they are in a readable format for hmmsearch 

singularity exec --no-home --bind ${TRANSPORTER_PROJ_DIR}:/Transporter_proj ${TRANSPORTER_PROJ_DIR}/containers/hmmer.sif \
    hmmpress ${Pfams_HMMS}

#performing hmmsearch, outputting results in data dir
singularity exec --no-home --bind ${TRANSPORTER_PROJ_DIR}:/Transporter_proj ${TRANSPORTER_PROJ_DIR}/containers/hmmer.sif \
    hmmsearch --domtblout "${OUTPUT}" \
    "${Pfams_HMMS}" "${PROTEINS_DIR}"

