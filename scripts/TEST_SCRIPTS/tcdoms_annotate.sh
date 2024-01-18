#!/bin/bash
#script will annotate the North Pacific aa sequences 
#ensure that the tcDomsHHMs are downloaded under data/tcDoms 
#initalizing variables 
# script is based on being in Transporter_proj folder
TRANSPORTER_PROJ_DIR=$(realpath . )
DATA_DIR="${TRANSPORTER_PROJ_DIR}/data"
#using test protein file; modify with whatever protein file you would like to annotate 
PROTEINS_DIR="${DATA_DIR}/knownTransporters.fa"
OUTPUT="${DATA_DIR}/HMMSearchtcDomsResults.tcDoms.domblout.tab"
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

#tcDoms HMM should be untarred & unzipped at this point 
TCDOMS_HMMS="${DATA_DIR}/tcDoms/tcDomsGlobal/tcDoms.hmm"

#now we should have tcDoms.hmm acessible and a hmmer container 
#want to do hmmpress now so they are in a readable format for hmmsearch 

singularity exec --no-home --bind ${TRANSPORTER_PROJ_DIR}:/Transporter_proj ${TRANSPORTER_PROJ_DIR}/containers/hmmer.sif \
    hmmpress ${TCDOMS_HMMS}

#performing hmmsearch, outputting results in data dir
singularity exec --no-home --bind ${TRANSPORTER_PROJ_DIR}:/Transporter_proj ${TRANSPORTER_PROJ_DIR}/containers/hmmer.sif \
    hmmsearch --domtblout "${OUTPUT}" \
    "${TCDOMS_HMMS}" "${PROTEINS_DIR}"

#------------------------------------------------------------------------
#now we work in the best annotation pyscript
#need the py.sif container installed...

#if container is not installed, install it 
#if [ ! -e "${TRANSPORTER_PROJ_DIR}/containers/py.sif" ]; then 
#    singularity build --fakeroot marferret-py.sif Singularity
#fi 

#python enviornment should now be set up 
#now we run the annotations 
#singularity exec --no-home --bind ${TRANSPORTER_PROJ_DIR}:/Transporter_proj \
#    ${TRANSPORTER_PROJ_DIR}/containers/py.sif \
#    "Transporter_proj/scripts/best_tcdoms.py" \
#    "${OUTPUT}" "${ANNOTATED}"
