# purpose of script is to download tcdom HHMS into the appropiate directory 
# URL for this download: https://tcdb.org/public/tcDoms.tar.gz
#command line: wget  https://tcdb.org/public/tcDoms.tar.gz

#initialize variables 
TRANSPORTER_PROJ_DIR = $ ( realpath ../ )
DATA_DIR="${TRANSPORTER_PROJ_DIR}/data"

#we can check if tcDom directory is made
#not not made then we make it
if [ -d "${DATA_DIR}/tcDoms"]; then 
        echo "tcDoms directory already made in appropiate place"
    else 
        echo "making tcDoms directory"
        mkdir "${DATA_DIR}/tcDoms"
    fi
#this script will then apprend onto it (../data/tcDoms/TcDoms_HHM)
#where TcDoms_HHM will be tcDoms/Tcdoms.tar/gz
cd tcDoms/
wget https://tcdb.org/public/tcDoms.tar.gz
#initialize TCDOMS_HHM 
TCDOMS_HHM = "tcDoms/tcDoms.tar.gz"
#if needed, we need to gzip ${tcDoms_HHS}
if [ ! -e "${DATA_DIR}/${TCDOMS_HMMS}" ]; then
    if [ -e "${DATA_DIR}/${TCDOMS_HMMS}.gz" ]; then
        gunzip "${DATA_DIR}/${TCDOMS_HMMS}.gz"
    else
        echo "Could not find input file ${DATA_DIR}/${TCDOMS_HMMS}.gz"
    fi
fi

echo "tcDoms HHM succesdully downloaded into appropiate directory"
