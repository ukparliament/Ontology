<#
.SYNOPSIS
Resets GraphDB respository.

.DESCRIPTION
Resets GraphDB respository: adds new Ontology and loads backup to populate the store.

.PARAMETER APIResourceGroupName
Name of the Resource Group where the API Management is.

.PARAMETER OntologyFileLocation
Location of the file with ontology (sparql).

.NOTES
This script is for use as a part of deployment in VSTS only.
#>

Param(
    [Parameter(Mandatory=$true)] [string] $APIResourceGroupName,
	[Parameter(Mandatory=$true)] [string] $APIManagementName,
    [Parameter(Mandatory=$true)] [string] $OntologyFileLocation,
	[Parameter(Mandatory=$true)] [string] $BackupFileUrl,
	[Parameter(Mandatory=$true)] [string] $APIPrefix	
)

$ErrorActionPreference = "Stop"

function Log([Parameter(Mandatory=$true)][string]$LogText){
    Write-Host ("{0} - {1}" -f (Get-Date -Format "HH:mm:ss.fff"), $LogText)
}

Log "Get API Management context"
$management=New-AzureRmApiManagementContext -ResourceGroupName $APIResourceGroupName -ServiceName $APIManagementName
Log "Get product id"
$apiReleaseProductId=(Get-AzureRmApiManagementProduct -Context $management -Title "$APIPrefix - Parliament [Orchestration]").ProductId
Log "Retrives subscription"
$subscription=Get-AzureRmApiManagementSubscription -Context $management -ProductId $apiReleaseProductId
$subscriptionKey=$subscription.PrimaryKey

$api="https://$APIManagementName.azure-api.net/$APIPrefix"
$header=@{"Ocp-Apim-Subscription-Key"="$subscriptionKey"}

Log "Restore backup"
Invoke-RestMethod -Uri "$api/graph-store/repositories/Master/statements" -Method Put -Body $backup -ContentType "application/x-trig" -TimeoutSec 360 -Headers $header -Verbose

Log "Read file in utf-8"
$txt=Get-Content $OntologyFileLocation -Encoding UTF8

Log "Add ontology"
Invoke-RestMethod -Uri "$api/graph-store/repositories/Master/statements" -Method Post -Body $txt -ContentType "application/sparql-update" -TimeoutSec 180 -Headers $header -Verbose

Log "Job done"