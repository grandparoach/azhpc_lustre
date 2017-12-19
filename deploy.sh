#!/bin/bash

set -x
RG=$1
storageDisks=8
computeNodes=8
#set -xeuo pipefail
LOGDIR=LOGDIR_`date +%F%T`_$RG
mkdir $LOGDIR

#COPY CREDENTIALS OVER
cp ../cred_lustre.yaml .

#CREATE MASTER CLUSTER and JUMPBOX USING THE TEMPLATES
az group create -l northcentralus -n $RG
echo ------------------------- `date +%F" "%T` Creating Compute Cluster
cp parameters-master.json .parameters-master.json.orig
ssh-keygen -t rsa -N "" -f id_rsa_lustre
sshkey=`cat id_rsa_lustre.pub`
sed -i "s%_SSHKEY%$sshkey%g" parameters-master.json

az group deployment validate -o table --resource-group $RG --template-file lustre-master.json --parameters @parameters-master.json
az group deployment create --name lustremasterdeployment -o table --resource-group $RG --template-file lustre-master.json --parameters @parameters-master.json

mv parameters-master.json $LOGDIR/parameters-master.json
mv .parameters-master.json.orig parameters-master.json

pubip=`az network public-ip list -g $RG --query [0].['ipAddress'][0] -o tsv`    
scp -i id_rsa_lustre id_rsa_lustre lustreuser@$pubip:/home/lustreuser/.ssh/
mv id_rsa_lustre* $LOGDIR/
touch $LOGDIR/$pubip

#CREATE OSS SERVER
echo ------------------------- `date +%F" "%T` Creating OSS Cluster
cp parameters-server.json .parameters-server.json.orig
CID=`grep user_id: cred_lustre.yaml | awk '{print $2}'`
CSEC=`grep password_id: cred_lustre.yaml | awk '{print $2}'`
TENID=`grep tenant_id: cred_lustre.yaml | awk '{print $2}'`

sed -i "s%_CID%$CID" parameters-server.json
sed -i "s%_CSEC%$CSEC" parameters-server.json
sed -i "s%_TENID%$TENID" parameters-server.json
sed -i "s%_SDS%$storageDisks%g" parameters-server.json
sed -i "s%_SSHKEY%$sshkey%g" parameters-server.json

az group deployment validate -o table --resource-group $RG --template-file lustre-server.json --parameters @parameters-server.json
az group deployment create --name lustreserverdeployment -o table --resource-group $RG --template-file lustre-server.json --parameters @parameters-server.json

mv parameters-server.json $LOGDIR/parameters-server.json
mv .parameters-server.json.orig parameters-server.json

#CREATE CLIENTS
echo ------------------------- `date +%F" "%T` Creating Client Cluster
cp parameters-client.json .parameters-client.json.orig

sed -i "s%_COMPNODES%$computeNodes%g" parameters-client.json
sed -i "s%_RG%$RG%g" parameters-client.json
sed -i "s%_SSHKEY%$sshkey%g" parameters-client.json

az group deployment validate -o table --resource-group $RG --template-file lustre-client.json --parameters @parameters-client.json
az group deployment create --name lustreclientdeployment -o table --resource-group $RG --template-file lustre-client.json --parameters @parameters-client.json

mv parameters-client.json $LOGDIR/parameters-client.json
mv .parameters-client.json.orig parameters-client.json
echo ------------------------- `date +%F" "%T` Finished