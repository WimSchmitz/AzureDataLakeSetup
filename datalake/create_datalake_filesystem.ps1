$parameters = Get-Content -Raw -Path './dl_parameters.json' | ConvertFrom-Json

# Parse variables from the JSON file
$containers = $parameters.containers
$resourceGroupName = $parameters.resourceGroupName
$dataLakeName =  $parameters.dataLakeName

# Get the storage account context using the resourcename & datalakename
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $dataLakeName
$ctx = $storageAccount.Context

foreach ($containerName in $containers.containerName) {
    ## Container Creation
    if (Get-AzStorageContainer -Context $ctx -Name $containerName -ErrorAction SilentlyContinue) {
        Write-Output "Container $containerName already exists" }
    else {
    Write-Output "Creating container $containerName"
    New-AzStorageContainer -Context $ctx -Name $containerName} 

    ## Child Folder Creation
    $childrenFolders = Get-AzDataLakeGen2ChildItem -Context $ctx -FileSystem $containerName -OutputUserPrincipalName
   
    Foreach ($folderName in ($containers | Where-Object containerName -eq $containerName).folders)
    {
        if ($childrenFolders) {
            if ($childrenFolders.Path.Contains($folderName)) {
                Write-Output "Folder $folderName already exists in $containerName" }
            else {
                Write-Output "Creating $folderName in $containerName"
            New-AzDataLakeGen2Item -Context $ctx -FileSystem $containerName -Path $folderName -Directory } 
            }
        else {
            Write-Output "Creating $folderName in $containerName"
            New-AzDataLakeGen2Item -Context $ctx -FileSystem $containerName -Path $folderName -Director
        }
    } 
}