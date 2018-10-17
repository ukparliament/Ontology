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
	[Parameter(Mandatory=$true)] [string] $APIPrefix	
)

$ErrorActionPreference = "Stop"
$api="https://api.parliament.uk"

function Log([Parameter(Mandatory=$true)][string]$LogText){
    Write-Host ("{0} - {1}" -f (Get-Date -Format "HH:mm:ss.fff"), $LogText)
}

function Get-JMXAttribute([Parameter(Mandatory=$true)][string]$AttributeName){
    Log "Gets $AttributeName"
    $bodyTxt=@{
        "type"="read";
        "mbean"= "ReplicationCluster:name=ClusterInfo/Master";
        "attribute"= "$AttributeName";
    }
    $bodyJson=ConvertTo-Json $bodyTxt
    $response=Invoke-RestMethod -Uri "$api/jmx" -Method Post -ContentType "application/json" -Body $bodyJson -Headers $header -TimeoutSec 15
    $response.value
}

function Wait-NodeStatus{
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
            Log "Wait 30 seconds, response ($flag)"
            $counter++
            Start-Sleep -Seconds 30
        }
        if (($counter -gt 50) -and ($result -ne 0)) {
            throw "Invalid status of cluster"
        }
    }

    Get-JMXAttribute -AttributeName "NodeStatus"
}

function Check-TripleNumber([Parameter(Mandatory=$true)][string]$Message){
    Log "NumberOfTriples - $Message"
    Get-JMXAttribute -AttributeName "NumberOfTriples"
    Log "NumberOfExplicitTriples - $Message"
    Get-JMXAttribute -AttributeName "NumberOfExplicitTriples"
}

Log "Get API Management context"
$management=New-AzureRmApiManagementContext -ResourceGroupName $APIResourceGroupName -ServiceName $APIManagementName
Log "Get product id"
$apiReleaseProductId=(Get-AzureRmApiManagementProduct -Context $management -Title "$APIPrefix - Parliament [Release]").ProductId
Log "Retrives subscription"
$subscription=Get-AzureRmApiManagementSubscription -Context $management -ProductId $apiReleaseProductId
$subscriptionKey=$subscription.PrimaryKey

$header=@{"Ocp-Apim-Subscription-Key"="$subscriptionKey";"Api-Version"="$APIPrefix"}
$deleteSparql="PREFIX this: <https://id.parliament.uk/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
delete {
	?s ?p ?o.
}
insert {
    [] <http://www.ontotext.com/owlim/system#schemaTransaction> [].
}
where { 
    ?s rdfs:isDefinedBy this:schema;
	    ?p ?o.
}"

Check-TripleNumber -Message "Before delete"

Log "Delete schema"
try{
    Invoke-RestMethod -Uri "$api/rdf4j/repositories/Master/statements" -Method Post -Body $deleteSparql -ContentType "application/sparql-update" -TimeoutSec 180 -Headers $header -Verbose
}
catch [System.Net.WebException]{
    Log "Expected error"
    Log $_
}
Wait-NodeStatus
Check-TripleNumber -Message "After delete"

$ontology=Get-Content $OntologyFileLocation -Encoding UTF8
Log "Add schema"
try {
    Invoke-RestMethod -Uri "$api/rdf4j/repositories/Master/statements" -Method Post -Body $ontology -ContentType "application/sparql-update" -TimeoutSec 180 -Headers $header -Verbose
}
catch [System.Net.WebException]{
    Log "Expected error"
    Log $_
}

Wait-NodeStatus
Check-TripleNumber -Message "After new schema"

Log "Job done"