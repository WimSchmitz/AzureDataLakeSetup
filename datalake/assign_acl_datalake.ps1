$parameters = Get-Content -Raw -Path './dl_parameters.json' | ConvertFrom-Json

# Parse variables from the JSON file
$entities = $parameters.entities
$containers = $parameters.containers
$resourceGroupName = $parameters.resourceGroupName
$dataLakeName =  $parameters.dataLakeName

# Get the storage account context using the resourcename & datalakename
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $dataLakeName
$ctx = $storageAccount.Context

foreach ($containerName in $containers.containerName){
        # Get the Current ACL for the container
        $aclContainer = (Get-AzDataLakeGen2Item -Context $ctx -FileSystem $containerName).ACL

        # Define read rights on container level for all entities
        ForEach ($entityId in $entities.entityId){
                $entityName = ($entities | Where-Object entityId -eq $entityId).entityName
                Write-Output "Defining r-x rights on container $containerName for $entityName"

                $aclContainer = set-AzDataLakeGen2ItemAclObject -AccessControlType group -Permission "r-x" -EntityId $entityId -InputObject $aclContainer
        }
        
        # Update the read rights for the container
        Update-AzDataLakeGen2Item -Context $ctx -FileSystem $containerName -ACL $aclContainer

        ForEach ($folderName in ($containers | Where-Object containerName -eq $containerName).folders){
                # Get the Current ACL for the container
                $aclFolder = (Get-AzDataLakeGen2Item -Context $ctx -FileSystem $containerName -Path $folderName).ACL

                # Define rights based on acl_parameters.json on folder level for all entities
                ForEach ($entityId in $entities.entityId){
                        
                        $permission = ($entities | Where-Object entityId -eq $entityId).accessList.$folderName
                        $permission = (&{If($permission.length -gt 0) {$permission} Else {"---"}})

                        $entityName = ($entities | Where-Object entityId -eq $entityId).entityName
                        Write-Output "Defining $permission rights on folder $folderName in conatiner $containerName for $entityName"

                        $aclFolder = set-AzDataLakeGen2ItemAclObject -AccessControlType group -Permission $permission -EntityId $entityId -InputObject $aclFolder
                        $aclFolder = set-AzDataLakeGen2ItemAclObject -AccessControlType group -Permission $permission -EntityId $entityId -InputObject $aclFolder -DefaultScope
                }

                # Update the read rights for the folder
                Update-AzDataLakeGen2Item -Context $ctx -FileSystem $containerName -Path $folderName -ACL $aclFolder
                Update-AzDataLakeGen2AclRecursive -Context $ctx -FileSystem $containerName -Path $folderName -ACL $aclFolder
        }
}