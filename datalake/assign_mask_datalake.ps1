$parameters = Get-Content -Raw -Path './dl_parameters.json' | ConvertFrom-Json

# Parse variables from the JSON file
$containers = $parameters.containers
$resourceGroupName = $parameters.resourceGroupName
$dataLakeName =  $parameters.dataLakeName

# Get the storage account context using the resourcename & datalakename
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $dataLakeName
$ctx = $storageAccount.Context

foreach ($containerName in $containers.containerName){
    # Get the Current ACL for the container
    $aclContainer = (Get-AzDataLakeGen2Item -Context $ctx -FileSystem $containerName).ACL

    # Define read & write rights on container level for the MASK
    $aclContainer = set-AzDataLakeGen2ItemAclObject -AccessControlType mask -Permission "rwx" -InputObject $aclContainer
    $aclContainer = set-AzDataLakeGen2ItemAclObject -AccessControlType mask -Permission "rwx" -DefaultScope -InputObject $aclContainer

    Write-Output "Updating rwx rights on container $containerName for mask"
    Update-AzDataLakeGen2AclRecursive -Context $ctx -FileSystem $containerName -ACL $aclContainer
}
