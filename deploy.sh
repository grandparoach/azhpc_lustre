#!/bin/bash

set -x
RG=$1
storageDisks=8
#set -xeuo pipefail
LOGDIR=LOGDIR_`date +%F%T`_$RG
mkdir $LOGDIR

#COPY CREDENTIALS OVER
cp ../cred_lustre.yaml .

#CREATE MASTER CLUSTER and JUMPBOX USING THE TEMPLATES
az group create -l northcentralus -n $RG
echo ------------------------- `date +%F" "%T` Creating Compute Cluster
cp master-parameters.json .master-parameters.json.orig
ssh-keygen -t rsa -N "" -f id_rsa_lustre
sshkey=`cat id_rsa_lustre.pub`
sed -i "s%_SSHKEY%$sshkey%g" master-parameters.json

az group deployment validate -o table --resource-group $RG --template-file lustre-master.json --parameters @master-parameters.json
az group deployment create --name lustremasterdeployment -o table --resource-group $RG --template-file lustre-master.json --parameters @master-parameters.json

mv master-parameters.json $LOGDIR/master-parameters.json
mv .master-parameters.json.orig master-parameters.json

pubip=az network public-ip list -g $RG --query [0].['ipAddress'][0] -o tsv
scp -i id_rsa_lustre id_rsa_lustre lustreuser@$pubip:/home/lustreuser/.ssh/
mv id_rsa_lustre* $LOGDIR/

#CREATE OSS SERVER
echo ------------------------- `date +%F" "%T` Creating OSS Cluster
cp server-parameters.json .server-parameters.json.orig
CID=`grep user_id: cred_lustre.yaml | awk '{print $2}'`
CSEC=`grep password_id: cred_lustre.yaml | awk '{print $2}'`
TENID=`grep tenant_id: cred_lustre.yaml | awk '{print $2}'`

sed -i "s%_CID%$CID" server-parameters.json
sed -i "s%_CSEC%$CSEC" server-parameters.json
sed -i "s%_TENID%$TENID" server-parameters.json
sed -i "s%_SDS%$storageDisks%g" server-parameters.json
sed -i "s%_SSHKEY%$sshkey%g" server-parameters.json

az group deployment validate -o table --resource-group $RG --template-file lustre-server.json --parameters @server-parameters.json
az group deployment create --name lustreserverdeployment -o table --resource-group $RG --template-file lustre-server.json --parameters @server-parameters.json

mv server-parameters.json $LOGDIR/server-parameters.json
mv .server-parameters.json.orig server-parameters.json

#CLIENT