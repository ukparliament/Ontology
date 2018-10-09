<#
.SYNOPSIS
Updates GraphDB schema.

.DESCRIPTION
Updates GraphDB schema with new Ontology.

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
	[Parameter(Mandatory=$true)] [string] $AzureFunctionsName,
	[Parameter(Mandatory=$true)] [string] $OrchestrationResourceGroupName,
	[Parameter(Mandatory=$true)] [string] $APIPrefix	
)

$ErrorActionPreference = "Stop"

function Log([Parameter(Mandatory=$true)][string]$LogText){
    Write-Host ("{0} - {1}" -f (Get-Date -Format "HH:mm:ss.fff"), $LogText)
}

function Get-JMXAttribute([Parameter(Mandatory=$true)][string]$AttributeName){
    Log "Gets $AttributeName on master"
    $bodyTxt=@{
        "type"="read";
        "mbean"= "ReplicationCluster:name=ClusterInfo/Master";
        "attribute"= "$AttributeName";
    }
    $bodyJson=ConvertTo-Json $bodyTxt
    $response=Invoke-RestMethod -Uri "https://$APIManagementName.azure-api.net/jmx" -Method Post -ContentType "application/json" -Body $bodyJson -Headers $header -TimeoutSec 15
    $response.value
}

Log "Retrive trigger code for $AzureFunctionsName"
$properties=Invoke-AzureRmResourceAction -ResourceGroupName $OrchestrationResourceGroupName -ResourceType Microsoft.Web/sites/config -ResourceName "$AzureFunctionsName/publishingcredentials" -Action list -ApiVersion 2015-08-01 -Force
$base64Info=[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $properties.properties.publishingUserName,$properties.properties.publishingPassword)))
$masterKeyResponse=Invoke-RestMethod -Uri "https://$AzureFunctionsName.scm.azurewebsites.net/api/functions/admin/masterkey" -Headers @{Authorization=("Basic {0}" -f $base64Info)} -Method GET

Log "Read file in utf-8"
$txt=Get-Content $OntologyFileLocation -Encoding UTF8

Log "Update schema"
Invoke-RestMethod -Uri "https://$AzureFunctionsName.azurewebsites.net/api/GraphDBSchemaUpdate?code=$($masterKeyResponse.masterKey)" -Method Post -ContentType "text/turtle" -Body $txt -TimeoutSec 300 -Verbose

Log "Get API Management context"
$management=New-AzureRmApiManagementContext -ResourceGroupName $APIResourceGroupName -ServiceName $APIManagementName
Log "Get product id"
$apiReleaseProductId=(Get-AzureRmApiManagementProduct -Context $management -Title "$APIPrefix - Parliament [Release]").ProductId
Log "Retrives subscription"
$subscription=Get-AzureRmApiManagementSubscription -Context $management -ProductId $apiReleaseProductId
$subscriptionKey=$subscription.PrimaryKey

$header=@{"Ocp-Apim-Subscription-Key"="$subscriptionKey";"Api-Version"="$APIPrefix"}

Log "Wait 10sec"
Start-Sleep -Seconds 10

$result=1
$counter=0;
while($result -ne 0) {
    Log "Counter $counter"
    $status=Get-JMXAttribute -AttributeName "NodeStatus"
    $status
    $result=1
    foreach($node in $status){
        Log "Status $node"
        $flag=$node.Split(' ')[0]
        if ($flag -eq "[ON]") {
            $result=0
            break
        }
    }
    if ($result -ne 0){
        Log "Wait 10 seconds, response ($flag)"
        $counter++
        Start-Sleep -Seconds 10
    }
    if (($counter -gt 20) -and ($result -ne 0)) {
        throw "Invalid status of cluster"
    }
}

Get-JMXAttribute -AttributeName "NodeStatus"

Log "Job done"