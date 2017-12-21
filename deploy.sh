#!/bin/bash

set -x

#BELOW LINE IS FOR TESTING
cp ../cred_lustre.yaml parameters/cred_lustre.yaml

RG=$1
storageDisks=8
computeNodes=8
#set -xeuo pipefail
LOGDIR=LOGDIR_`date +%F%T`_$RG
mkdir -p $LOGDIR/parameters

#CREATE MASTER CLUSTER and JUMPBOX USING THE TEMPLATES
az group create -l northcentralus -n $RG
echo ------------------------- `date +%F" "%T` Creating Compute Cluster
cp parameters/parameters-master.json parameters/.parameters-master.json.orig
ssh-keygen -t rsa -N "" -f id_rsa_lustre
sshkey=`cat id_rsa_lustre.pub`
sed -i "s%_SSHKEY%$sshkey%g" parameters/parameters-master.json

az group deployment validate -o table --resource-group $RG --template-file templates/lustre-master.json --parameters @parameters/parameters-master.json
az group deployment create --name lustre-master-deployment -o table --resource-group $RG --template-file templates/lustre-master.json --parameters @parameters/parameters-master.json

mv parameters/parameters-master.json $LOGDIR/parameters/parameters-master.json
mv parameters/.parameters-master.json.orig parameters/parameters-master.json

pubip=`az network public-ip list -g $RG --query [0].['ipAddress'][0] -o tsv`    
scp -i id_rsa_lustre id_rsa_lustre lustreuser@$pubip:/home/lustreuser/.ssh/
mv id_rsa_lustre* $LOGDIR/
touch $LOGDIR/$pubip

#CREATE OSS SERVER
echo ------------------------- `date +%F" "%T` Creating OSS Cluster
cp parameters/parameters-server.json parameters/.parameters-server.json.orig
CID=`grep user_id: parameters/cred_lustre.yaml | awk '{print $2}'`
CSEC=`grep password_id: parameters/cred_lustre.yaml | awk '{print $2}'`
TENID=`grep tenant_id: parameters/cred_lustre.yaml | awk '{print $2}'`

sed -i "s%_CID%$CID%g" parameters/parameters-server.json
sed -i "s%_CSEC%$CSEC%g" parameters/parameters-server.json
sed -i "s%_TENID%$TENID%g" parameters/parameters-server.json
sed -i "s%_SDS%$storageDisks%g" parameters/parameters-server.json
sed -i "s%_SSHKEY%$sshkey%g" parameters/parameters-server.json

az group deployment validate -o table --resource-group $RG --template-file templates/lustre-server.json --parameters @parameters/parameters-server.json
az group deployment create --name lustre-server-deployment -o table --resource-group $RG --template-file templates/lustre-server.json --parameters @parameters/parameters-server.json

mv parameters/parameters-server.json $LOGDIR/parameters/parameters-server.json
mv parameters/.parameters-server.json.orig parameters/parameters-server.json

#CREATE CLIENTS
echo ------------------------- `date +%F" "%T` Creating Client Cluster
cp parameters/parameters-client.json parameters/.parameters-client.json.orig

sed -i "s%_COMPNODES%$computeNodes%g" parameters/parameters-client.json
sed -i "s%_RG%$RG%g" parameters/parameters-client.json
sed -i "s%_SSHKEY%$sshkey%g" parameters/parameters-client.json

az group deployment validate -o table --resource-group $RG --template-file templates/lustre-client.json --parameters @parameters/parameters-client.json
az group deployment create --name lustre-client-deployment -o table --resource-group $RG --template-file templates/lustre-client.json --parameters @parameters/parameters-client.json

mv parameters/parameters-client.json $LOGDIR/parameters/parameters-client.json
mv parameters/.parameters-client.json.orig parameters/.parameters-client.json
echo ------------------------- `date +%F" "%T` Finished