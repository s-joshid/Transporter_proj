#script will annotate the North Pacific aa sequences
#ensure that the tcDomsHHMs are downloaded under data/tcDoms
#initalizing variables
#start in users Transporter_proj_dir
TRANSPORTER_PROJ_DIR=$(realpath . )
DATA_DIR="${TRANSPORTER_PROJ_DIR}/data"
#uaing test protein file on my local comp for test
PROTEINS_DIR="${DATA_DIR}/knownTransporters.fa"
if [ ! -e ${TRANSPORTER_PROJ_DIR}/containers ]; then
    mkdir ${TRANSPORTER_PROJ_DIR}/containers
fi
#now need to make sure hmmer.sif container is in singularity
if [ ! -e ${TRANSPORTER_PROJ_DIR}/containers/hmmer.sif ];
then
    cd ${TRANSPORTER_PROJ_DIR}/containers
    singularity build hmmer.sif docker://biocontainers/hmmer:v3.2.1dfsg-1-deb_c
v1
    cd ..
fi

#making sure tcDoms.tar.gz is downloaded correctly
if [ ! -e "${DATA_DIR}/tcDoms/" ]; then
    echo "please make sure you have tcDoms HMM downloaded to the correct file p
ath."
fi
#tcDoms.hmm.tar.gz is downloaded correctly
#now checking if we have it unzipped and untarred

if [ ! -e "${DATA_DIR}/tcDoms/tcDoms/tcDomsGlobal" ];
then
    #in here if hmm file is not untarred and unzipped
    cd "${DATA_DIR}/tcDoms"
    tar -zxvf tcDoms.tar.gz
    cd ~
fi


#tcDoms HMM should be untarred & unzipped if here
TCDOMS_HMMS="${DATA_DIR}/tcDoms/tcDoms/tcDomsGlobal/tcDoms.hmm"

#now we should have tcDoms.hmm acessible and a hmmer container
#want to do hmmpress now so they are in a readable format for hmmsearch

singularity exec --no-home --bind ${TRANSPORTER_PROJ_DIR}:/Transporter_proj \
    ${TRANSPORTER_PROJ_DIR}/containers/hmmer.sif hmmpress ${TCDOMS_HMMS}

singularity exec --no-home --bind ${TRANSPORTER_PROJ_DIR}:/Transporter_proj \
    ${TRANSPORTER_PROJ_DIR}/containers/hmmer.sif hmmsearch --domtblout \
    "/Transporter_proj/data/HMMSearchtcDomsResults.tcDoms.domblout.tab" ${TCDOMS_HMMS} ${PROTEINS_DIR}
