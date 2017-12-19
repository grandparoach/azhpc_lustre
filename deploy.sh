#!/bin/bash

set -x
RG=$1
#set -xeuo pipefail
LOGDIR=LOGDIR_`date +%F%T`_$RG
mkdir $LOGDIR
#CREATE COMPUTE CLUSTER USING THE TEMPLATES
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
mv id_rsa_lustre* $LOGDIR/

#MASTER

#SERVER

#CLIENT