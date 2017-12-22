# azhpc_lustre
Template to setup LustreFS using VMSS

Table of Contents
=================
* [Quickstart](#Lustre)
* [Lustre](#Lustre)
* [Deployment steps](#deployment-steps)
  * [Deploy Lustre MDS/MGS](#Deploy-the-Lustre-MDS/MGS)
  * [Deploy Lustre OSS](#Deploy-Lustre-OSS)
  * [Deploy Lustre Client](#Deploy-Lustre-Client)

# Quickstart 1
To deploy an Infiniband enabled compute cluster with a Lustre File Server attached and mounted:
1. Make sure you have quota for H-series (compute cluster) and F-series (jumpbox and storage cluster)
2. Open the [cloud shell](https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/cloud-shell/quickstart.md) from the Azure portal
3. Clone the repository, `git clone https://github.com/tanewill/azhpc_lustre`
4. Change directory to azhpc_lustre `cd azhpc_lustre`
5. Deploy the cluster `./deploy.sh [RESOURCE GROUP NAME] [NUMBER OF OSS SERVERS] [NUMBER OF DISKS PER SERVER]`
   For example: `./deploy.sh BTN-LUSTRETESET-RG100 4 10`
   The total disk size is the number of OSS Servers multipled by the number of disks per server multipled by 4TB
6. Complete deployment will take around 40 minutes


# Quickstart 2
* Deploy the Lustre MDS/MGS

  [![Click to deploy template on Azure](/images/deploybutton.png "Click to deploy template on Azure")](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ftanewill%2Fazhpc_lustre%2Fmaster%2Flustre-master.json) 

* Deploy the Lustre OSS

  [![Click to deploy template on Azure](/images/deploybutton.png "Click to deploy template on Azure")](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ftanewill%2Fazhpc_lustre%2Fmaster%2Flustre-server.json)

* Deploy the Lustre Clients

  [![Click to deploy template on Azure](/images/deploybutton.png "Click to deploy template on Azure")](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ftanewill%2Fazhpc_lustre%2Fmaster%2Flustre-client.json)

# Lustre
Lustre is currently the most widely used parallel file system in HPC solutions. Lustre file systems can scale to tens of thousands of client nodes, tens of petabytes of storage. Lustre file system performed well for large file system, you can refer the testing results for the same.

# Architecture
![Lustre Architecture](/images/lustre_arch.png)

## Estimated Monthly Cost for North Central US
Estimates calculated from [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)
 - Compute, 80 H16r cores
   - 5 H16 compute nodes @ 75% utilization, $5,459.81/month 
 - Storage, 256 TB
   - 1 DS3_v2 MGSMDT Server, $214.48/month
   - 8 F8s OSS Servers, $2,330.69/month
   - 64 (8/OSS Server) Premium, P50 Managed Disks. 256 TB, $31,716.20/month
   - 15 TB Azure Files, $912.63/month

Total Cost about $40,633.81/month (~$36,764.88/month with 3 year commit)


Note- Before setup Lustre FS make sure you have service principal (id, secrete and tenant id) to get artifacts from Azure.
# Deployment steps
To setup Lustre three steps need to be executed :
1. Deploy the Lustre MDS/MGS
2. Deploy the Lustre OSS
3. Deploy the Lustre Client

## Deploy the Lustre MDS/MGS
Metadata servers (MDS) manage the names and directories in the file system and d.	Management servers (MGS) works as master node for the whole setup and contains the information about all the nodes attached within the cluster. 

You have to provide these parameters to the template :

* _Location_ : Select the same location where MDS/MGS is deployed.
* _Vmss Name_ : Provide a name for prefix of VMs.
* _Node Count_ : Provide node count as per requirment.
* _VM Size_ : Select virtual machine size from the dropdown.
* _VM Image_ : Select virtual machine Image from the dropdown.
* _RGVnet Name_ : The name of the Resource Group used to deploy the Master VM and the VNET.
* _Mgs Node Name_: Provide the same name of MGS/MDS node .
* _Admin User Name_ : This is the name of the administrator account to create on the VM.
* _Sssh Key Data_ : The public SSH key to associate with the administrator user. Format has to be on a single line 'ssh-rsa key'.
* _Storage Disk Size_ : select from the dropdown.
* _Storage Disk Count_ : Provide the no. of storage disk as per requirement.

## Deploy Lustre MDS/MGS
[![Click to deploy template on Azure](http://azuredeploy.net/deploybutton.png "Click to deploy template on Azure")](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ftanewill%2Fazhpc_lustre%2Fmaster%2Flustre-master.json) 

## Deploy the Lustre OSS
Data in the Lustre filesystem is stored and retrieved by two components: the Object Storage Server (OSS, a server node) and the Object Storage Target (OST, the HDD/SSD that stores the data). Together, the OSS and OST provide the data to the Client.

A Lustre filesystem can have one or more OSS nodes. An OSS typically has between two and eight OSTs attached. To increase the storage capacity of the Lustre filesystem, additional OSTs can be attached. To increase the bandwidth of the Lustre filesystem, additional OSS can be attached.
## Provision the OSS nodes

You have to provide these parameters to the template :


* _Location_ : Select the location where NC series is available(for example East US,South Central US). 
* _Vmss Name_ : Enter the virtual machine name. 
* _Node_Count : Enter the virtual machine name._
* _VM Size_ : Select virtual machine size from the dropdown.
* _VM Image_ : Select virtual machine Image from the dropdown.
* _Client Id_ : Enter the created client id.
* _Client secret_ : Enter the created client secret.
* _Tenant Id_ : Enter the Tenant id.
* _MGS/MDS Node Name _ : Enter the host name of MGS/MDS node.
* _Admin Username_ : This is the name of the administrator account to create on the VM.
* _Ssh Key Data_ : The public SSH key to associate with the administrator user. Format has to be on a single line 'ssh-rsa key'.
* _Storage Disks Size_ : Select the disks size from the dropdown.
* _Storage Disks Count_ : Enter the disks count.

## Deploy Lustre OS
[![Click to deploy template on Azure](http://azuredeploy.net/deploybutton.png "Click to deploy template on Azure")](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ftanewill%2Fazhpc_lustre%2Fmaster%2Flustre-server.json)

## Deploy the Lustre Client
A Client in the Lustre filesystem is a machine that requires data. This could be a computation, visualization, or desktop node. Once mounted, a Client experiences the Lustre filesystem as if the filesystem were a local or NFS mount.
## Provision the Client nodes

You have to provide these parameters to the template :


* _Location_ : Select the same location where MDS/MGS is deployed.
* _Vmss Name_ : Provide a name for prefix of VMs.
* _Node Count_ : Provide node count as per requirment.
* _VM Size_ : Select virtual machine size from the dropdown.
* _VM Image_ : Select virtual machine Image from the dropdown.
* _Vnet RG_ : The name of the Resource Group used to deploy the Master VM and the VNET.
* _Mgs Node Name_: Provide the same name of MGS/MDS node .
* _Admin User Name_ : This is the name of the administrator account to create on the VM.
* _Ssh Key Data_ : The public SSH key to associate with the administrator user. Format has to be on a single line 'ssh-rsa key'.


## Deploy Lustre Client
[![Click to deploy template on Azure](http://azuredeploy.net/deploybutton.png "Click to deploy template on Azure")](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ftanewill%2Fazhpc_lustre%2Fmaster%2Flustre-client.json)
