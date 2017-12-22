#!/bin/bash
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
echo -e "I ${RED}love${NC} Stack Overflow"
#set -x

#BELOW LINE IS FOR TESTING
cp ../cred_lustre.yaml parameters/cred_lustre.yaml

RG=$1
serverNodes=8
storageDisks=8
computeNodes=8

:'
userName=lustreuser
computeNodeSku=
computeNodeImage
'

#set -xeuo pipefail
STARTTIME=`date +%Y%m%d_%H%M%S`
LOGDIR=LOGDIR_"$STARTTIME"_$RG
mkdir -p $LOGDIR/parameters

echo -e "${GREEN}********************************************************************************${NC}"
echo -e "${WHITE}Creating a File Server:"
echo -e "${YELLOW}$serverNodes ${WHITE}Storage Nodes"
echo -e "with ${YELLOW}$storageDisks, 4TB ${WHITE}disks each"
echo -e "${YELLOW}`expr $serverNodes \* $storageDisks \* 4`TB ${WHITE}total storage"
echo -e "and ${YELLOW}$computeNodes ${NC}compute nodes"
echo -e "${GREEN}********************************************************************************${NC}"
echo

#CREATE MASTER CLUSTER and JUMPBOX USING THE TEMPLATES
echo -e "${GREEN}################ Creating MGSMDT @ ${YELLOW}$STARTTIME${NC}"
az group create -l northcentralus -n $RG -o table
cp parameters/parameters-master.json parameters/.parameters-master.json.orig
ssh-keygen -t rsa -N "" -f id_rsa_lustre > /dev/null
sshkey=`cat id_rsa_lustre.pub`
sed -i "s%_SSHKEY%$sshkey%g" parameters/parameters-master.json

echo -e "${PURPLE}################ Validation${NC}"
az group deployment validate -o table --resource-group $RG --template-file templates/lustre-master.json --parameters @parameters/parameters-master.json
echo -e "${BLUE}################ Deployment${NC}"
az group deployment create --name lustre-master-deployment -o table --resource-group $RG --template-file templates/lustre-master.json --parameters @parameters/parameters-master.json

mv parameters/parameters-master.json $LOGDIR/parameters/parameters-master.json
mv parameters/.parameters-master.json.orig parameters/parameters-master.json

pubip=`az network public-ip list -g $RG --query [0].['ipAddress'][0] -o tsv`    
scp -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i id_rsa_lustre id_rsa_lustre lustreuser@$pubip:/home/lustreuser/.ssh/
mv id_rsa_lustre* $LOGDIR/
touch $LOGDIR/$pubip

#CREATE OSS SERVER
echo -e "${GREEN}################ Creating OSS Cluster @ ${YELLOW}`date +%Y%m%d_%H%M%S`${NC}"
cp parameters/parameters-server.json parameters/.parameters-server.json.orig
CID=`grep user_id: parameters/cred_lustre.yaml | awk '{print $2}'`
CSEC=`grep password_id: parameters/cred_lustre.yaml | awk '{print $2}'`
TENID=`grep tenant_id: parameters/cred_lustre.yaml | awk '{print $2}'`

sed -i "s%_OSSNODES%$serverNodes%g" parameters/parameters-server.json
sed -i "s%_CID%$CID%g" parameters/parameters-server.json
sed -i "s%_CSEC%$CSEC%g" parameters/parameters-server.json
sed -i "s%_TENID%$TENID%g" parameters/parameters-server.json
sed -i "s%_SDS%$storageDisks%g" parameters/parameters-server.json
sed -i "s%_SSHKEY%$sshkey%g" parameters/parameters-server.json

echo -e "${PURPLE}################ Validation${NC}"
az group deployment validate -o table --resource-group $RG --template-file templates/lustre-server.json --parameters @parameters/parameters-server.json
echo -e "${BLUE}################ Deployment${NC}"
az group deployment create --name lustre-server-deployment -o table --resource-group $RG --template-file templates/lustre-server.json --parameters @parameters/parameters-server.json

mv parameters/parameters-server.json $LOGDIR/parameters/parameters-server.json
mv parameters/.parameters-server.json.orig parameters/parameters-server.json

#CREATE CLIENTS
echo -e  "${GREEN}################ Creating Compute Cluster @ ${YELLOW}`date +%Y%m%d_%H%M%S`${NC}" 
cp parameters/parameters-client.json parameters/.parameters-client.json.orig

sed -i "s%_COMPNODES%$computeNodes%g" parameters/parameters-client.json
sed -i "s%_RG%$RG%g" parameters/parameters-client.json
sed -i "s%_SSHKEY%$sshkey%g" parameters/parameters-client.json

echo -e "${PURPLE}################ Validation${NC}"
az group deployment validate -o table --resource-group $RG --template-file templates/lustre-client.json --parameters @parameters/parameters-client.json
echo -e "${BLUE}################ Deployment${NC}"
az group deployment create --name lustre-client-deployment -o table --resource-group $RG --template-file templates/lustre-client.json --parameters @parameters/parameters-client.json

mv parameters/parameters-client.json $LOGDIR/parameters/parameters-client.json
mv parameters/.parameters-client.json.orig parameters/.parameters-client.json
ENDTIME=`date +%Y%m%d_%H%M%S`
echo -e  "${GREEN}################' Deployment started @ ${YELLOW}$STARTTIME${NC}"
echo -e  "${GREEN}################' Deployment completed @ ${YELLOW}$ENDDTIME${NC}"
echo -e  "${WHITE}################' Connection string: ssh -i id_rsa_lustre lustreuser@$pubip${NC}"
