# Azure HPC Cluster with Lustre attached
The purpose of this repository is for a simple configuration of an HPC cluster inside of Azure with a Lustre File System configured and mounted.

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
7. The ssh key will be displayed upon completion, login to the jumpbox with that command
8. Compute node hostips are listed in the file 


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
