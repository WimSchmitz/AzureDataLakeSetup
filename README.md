# AzureDataLakeSetup
Set up a Data Lake File System &amp; ACL for an Azure Storage Account with Powershell Scripts

# Prerequisites
You need to have a storage account deployed in a resource group, and have a service connection available that has `Microsoft.Storage/storageAccounts/*` rights on that storage account.

# Usage
Change the dl_parameters to reflect the Data Lake File System Structure you want to create and define AD Groups/Entities and their respective rights on the Data Lake.
Currently, it is working in the case of one Storage Account containing both a Test & Produciton Data Lake.
Use the YAML file to create a pipeline in your environment, link it up with a Service Conneciton and run the pipeline.