<#
.EXAMPLE
  ./bootstrap-state.ps1
  ./bootstrap-state.ps1 -Location ukwest -ResourceGroup rg-tfstate-dev
#>
param(
    [string]$Location           = "uksouth",
    [string]$ResourceGroup      = "rg-tfstate-lab",
    [string]$StorageAccountName = "sttfstate$(Get-Random -Maximum 99999)",  # globally unique, lowercase/numbers only
    [string]$ContainerName      = "tfstate"
)

# RG for the state state
az group create --name $ResourceGroup --location $Location

# Storage Account
az storage account create --name $StorageAccountName --resource-group $ResourceGroup --location $Location --sku Standard_LRS --kind StorageV2 --min-tls-version TLS1_2 --allow-blob-public-access false

# Enable Versioning
az storage account blob-service-properties update --account-name $StorageAccountName --resource-group $ResourceGroup --enable-versioning true

# Get blob access, so Terraform uses Entra auth instead of the account key
$me    = az ad signed-in-user show --query id -o tsv
$scope = az storage account show --name $StorageAccountName --resource-group $ResourceGroup --query id -o tsv
az role assignment create --assignee $me --role "Storage Blob Data Contributor" --scope $scope

# Since Role assignments take a minute or two to apply retry the container creation
for ($i = 1; $i -le 6; $i++) {
    az storage container create --name $ContainerName --account-name $StorageAccountName --auth-mode login --only-show-errors
    if ($LASTEXITCODE -eq 0) { break }
    Write-Host "Waiting for role assignment to take effect... ($i/6)"
    Start-Sleep -Seconds 30
}

#Confirmations
Write-Host "`nState storage ready:"
Write-Host "  Resource group:  $ResourceGroup"
Write-Host "  Storage account: $StorageAccountName"
Write-Host "  Container:       $ContainerName"