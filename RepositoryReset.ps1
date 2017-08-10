<#
.SYNOPSIS
Resets GraphDB respository.

.DESCRIPTION
Resets GraphDB respository: adds Ontology, Houses, Genders and Parliamentary Periods.

.PARAMETER APIResourceGroupName
Name of the Resource Group where the API Management is.

.PARAMETER SchemaNamespace
Namespace for ontology.

.PARAMETER OntologyFileLocation
Location of the file with ontology (sparql).

.NOTES
This script is for use as a part of deployment in VSTS only.
#>

Param(
    [Parameter(Mandatory=$true)] [string] $APIResourceGroupName,
    [Parameter(Mandatory=$true)] [string] $SchemaNamespace,
    [Parameter(Mandatory=$true)] [string] $OntologyFileLocation
)

$ErrorActionPreference = "Stop"

function Log([Parameter(Mandatory=$true)][string]$LogText){
    Write-Host ("{0} - {1}" -f (Get-Date -Format "HH:mm:ss.fff"), $LogText)
}

Log "Get API Management"
$apiManagement=Find-AzureRmResource -ResourceGroupNameEquals $APIResourceGroupName -ResourceType "Microsoft.ApiManagement/service"
Log "Get API Management context"
$management=New-AzureRmApiManagementContext -ResourceGroupName $APIResourceGroupName -ServiceName $apiManagement.Name
Log "Get product id"
$apiReleaseProductId=(Get-AzureRmApiManagementProduct -Context $management -Title "Parliament - Release").ProductId
Log "Retrives subscription"
$subscription=Get-AzureRmApiManagementSubscription -Context $management -ProductId $apiReleaseProductId
$subscriptionKey=$subscription.PrimaryKey

$api="https://$($apiManagement.Name).azure-api.net"
$header=@{"Ocp-Apim-Subscription-Key"="$subscriptionKey"}

Log "Setting initial data"
$ttls=@(
    "<{0}> a parl:House;parl:houseName ""House of Commons"".",
    "<{0}> a parl:House;parl:houseName ""House of Lords"".",
    "<{0}> a parl:Gender;parl:genderName ""Female"";parl:genderMnisId ""F"".",
    "<{0}> a parl:Gender;parl:genderName ""Male"";parl:genderMnisId ""M""."
	"<{0}> a parl:Threshold;parl:thresholdName ""Moderation""."
	"<{0}> a parl:Threshold;parl:thresholdName ""Response""."
	"<{0}> a parl:Threshold;parl:thresholdName ""Debate""."
	"<{0}> a parl:RejectionCode;parl:rejectionCodeName ""no-action""."
	"<{0}> a parl:RejectionCode;parl:rejectionCodeName ""irrelevant""."
	"<{0}> a parl:RejectionCode;parl:rejectionCodeName ""honours""."
	"<{0}> a parl:RejectionCode;parl:rejectionCodeName ""foi""."
	"<{0}> a parl:RejectionCode;parl:rejectionCodeName ""fake-name""."
	"<{0}> a parl:RejectionCode;parl:rejectionCodeName ""duplicate""."
	"<{0}> a parl:RejectionCode;parl:rejectionCodeName ""libellous""."
	"<{0}> a parl:RejectionCode;parl:rejectionCodeName ""offensive""."
)

$parliamentPeriods=@(
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1801-01-22""^^xsd:date; parl:parliamentPeriodEndDate ""1802-06-29""^^xsd:date; parl:parliamentPeriodNumber ""1""^^xsd:integer; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{1}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1802-11-16""^^xsd:date; parl:parliamentPeriodEndDate ""1806-10-24""^^xsd:date; parl:parliamentPeriodNumber ""2""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1806-12-15""^^xsd:date; parl:parliamentPeriodEndDate ""1807-04-29""^^xsd:date; parl:parliamentPeriodNumber ""3""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1807-06-22""^^xsd:date; parl:parliamentPeriodEndDate ""1812-09-29""^^xsd:date; parl:parliamentPeriodNumber ""4""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1812-11-24""^^xsd:date; parl:parliamentPeriodEndDate ""1818-06-10""^^xsd:date; parl:parliamentPeriodNumber ""5""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1819-01-14""^^xsd:date; parl:parliamentPeriodEndDate ""1820-02-29""^^xsd:date; parl:parliamentPeriodNumber ""6""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1820-04-21""^^xsd:date; parl:parliamentPeriodEndDate ""1826-06-02""^^xsd:date; parl:parliamentPeriodNumber ""7""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1826-11-14""^^xsd:date; parl:parliamentPeriodEndDate ""1830-07-24""^^xsd:date; parl:parliamentPeriodNumber ""8""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1830-10-26""^^xsd:date; parl:parliamentPeriodEndDate ""1831-04-23""^^xsd:date; parl:parliamentPeriodNumber ""9""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1831-06-14""^^xsd:date; parl:parliamentPeriodEndDate ""1832-12-03""^^xsd:date; parl:parliamentPeriodNumber ""10""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1833-01-29""^^xsd:date; parl:parliamentPeriodEndDate ""1834-12-29""^^xsd:date; parl:parliamentPeriodNumber ""11""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1835-02-19""^^xsd:date; parl:parliamentPeriodEndDate ""1837-07-17""^^xsd:date; parl:parliamentPeriodNumber ""12""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1837-11-15""^^xsd:date; parl:parliamentPeriodEndDate ""1841-06-23""^^xsd:date; parl:parliamentPeriodNumber ""13""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1841-08-19""^^xsd:date; parl:parliamentPeriodEndDate ""1847-07-23""^^xsd:date; parl:parliamentPeriodNumber ""14""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1847-11-18""^^xsd:date; parl:parliamentPeriodEndDate ""1852-07-01""^^xsd:date; parl:parliamentPeriodNumber ""15""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1852-11-04""^^xsd:date; parl:parliamentPeriodEndDate ""1857-03-21""^^xsd:date; parl:parliamentPeriodNumber ""16""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1857-04-30""^^xsd:date; parl:parliamentPeriodEndDate ""1859-04-23""^^xsd:date; parl:parliamentPeriodNumber ""17""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1859-05-31""^^xsd:date; parl:parliamentPeriodEndDate ""1865-07-06""^^xsd:date; parl:parliamentPeriodNumber ""18""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1866-02-01""^^xsd:date; parl:parliamentPeriodEndDate ""1868-11-11""^^xsd:date; parl:parliamentPeriodNumber ""19""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1868-12-10""^^xsd:date; parl:parliamentPeriodEndDate ""1874-01-26""^^xsd:date; parl:parliamentPeriodNumber ""20""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1874-03-05""^^xsd:date; parl:parliamentPeriodEndDate ""1880-03-24""^^xsd:date; parl:parliamentPeriodNumber ""21""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1880-04-29""^^xsd:date; parl:parliamentPeriodEndDate ""1885-11-18""^^xsd:date; parl:parliamentPeriodNumber ""22""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1886-01-12""^^xsd:date; parl:parliamentPeriodEndDate ""1886-06-26""^^xsd:date; parl:parliamentPeriodNumber ""23""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1886-08-05""^^xsd:date; parl:parliamentPeriodEndDate ""1892-06-28""^^xsd:date; parl:parliamentPeriodNumber ""24""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1892-08-04""^^xsd:date; parl:parliamentPeriodEndDate ""1895-07-08""^^xsd:date; parl:parliamentPeriodNumber ""25""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1895-08-12""^^xsd:date; parl:parliamentPeriodEndDate ""1900-09-17""^^xsd:date; parl:parliamentPeriodNumber ""26""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1900-12-03""^^xsd:date; parl:parliamentPeriodEndDate ""1906-01-08""^^xsd:date; parl:parliamentPeriodNumber ""27""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1906-02-13""^^xsd:date; parl:parliamentPeriodEndDate ""1910-01-10""^^xsd:date; parl:parliamentPeriodNumber ""28""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1910-02-15""^^xsd:date; parl:parliamentPeriodEndDate ""1910-11-28""^^xsd:date; parl:parliamentPeriodNumber ""29""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1911-01-31""^^xsd:date; parl:parliamentPeriodEndDate ""1918-11-25""^^xsd:date; parl:parliamentPeriodNumber ""30""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1919-02-04""^^xsd:date; parl:parliamentPeriodEndDate ""1922-10-26""^^xsd:date; parl:parliamentPeriodNumber ""31""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1922-11-20""^^xsd:date; parl:parliamentPeriodEndDate ""1923-11-16""^^xsd:date; parl:parliamentPeriodNumber ""32""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1924-01-08""^^xsd:date; parl:parliamentPeriodEndDate ""1924-10-09""^^xsd:date; parl:parliamentPeriodNumber ""33""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1924-12-02""^^xsd:date; parl:parliamentPeriodEndDate ""1929-05-10""^^xsd:date; parl:parliamentPeriodNumber ""34""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1929-06-25""^^xsd:date; parl:parliamentPeriodEndDate ""1931-10-07""^^xsd:date; parl:parliamentPeriodNumber ""35""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1931-11-03""^^xsd:date; parl:parliamentPeriodEndDate ""1935-10-25""^^xsd:date; parl:parliamentPeriodNumber ""36""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1935-11-26""^^xsd:date; parl:parliamentPeriodEndDate ""1945-06-15""^^xsd:date; parl:parliamentPeriodNumber ""37""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1945-08-01""^^xsd:date; parl:parliamentPeriodEndDate ""1950-02-03""^^xsd:date; parl:parliamentPeriodNumber ""38""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1950-03-01""^^xsd:date; parl:parliamentPeriodEndDate ""1951-10-05""^^xsd:date; parl:parliamentPeriodNumber ""39""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1951-10-31""^^xsd:date; parl:parliamentPeriodEndDate ""1955-05-06""^^xsd:date; parl:parliamentPeriodNumber ""40""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1955-06-07""^^xsd:date; parl:parliamentPeriodEndDate ""1959-09-18""^^xsd:date; parl:parliamentPeriodNumber ""41""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1959-10-20""^^xsd:date; parl:parliamentPeriodEndDate ""1964-09-25""^^xsd:date; parl:parliamentPeriodNumber ""42""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1964-10-27""^^xsd:date; parl:parliamentPeriodEndDate ""1966-03-10""^^xsd:date; parl:parliamentPeriodNumber ""43""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1966-04-18""^^xsd:date; parl:parliamentPeriodEndDate ""1970-05-29""^^xsd:date; parl:parliamentPeriodNumber ""44""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1970-06-29""^^xsd:date; parl:parliamentPeriodEndDate ""1974-02-08""^^xsd:date; parl:parliamentPeriodNumber ""45""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1974-03-06""^^xsd:date; parl:parliamentPeriodEndDate ""1974-09-20""^^xsd:date; parl:parliamentPeriodNumber ""46""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1974-10-22""^^xsd:date; parl:parliamentPeriodEndDate ""1979-04-07""^^xsd:date; parl:parliamentPeriodNumber ""47""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1979-05-09""^^xsd:date; parl:parliamentPeriodEndDate ""1983-05-13""^^xsd:date; parl:parliamentPeriodNumber ""48""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1983-06-15""^^xsd:date; parl:parliamentPeriodEndDate ""1987-05-18""^^xsd:date; parl:parliamentPeriodNumber ""49""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1987-06-17""^^xsd:date; parl:parliamentPeriodEndDate ""1992-03-16""^^xsd:date; parl:parliamentPeriodNumber ""50""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1992-04-27""^^xsd:date; parl:parliamentPeriodEndDate ""1997-04-08""^^xsd:date; parl:parliamentPeriodNumber ""51""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""1997-05-07""^^xsd:date; parl:parliamentPeriodEndDate ""2001-05-14""^^xsd:date; parl:parliamentPeriodNumber ""52""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""2001-06-13""^^xsd:date; parl:parliamentPeriodEndDate ""2005-04-11""^^xsd:date; parl:parliamentPeriodNumber ""53""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""2005-05-11""^^xsd:date; parl:parliamentPeriodEndDate ""2010-04-12""^^xsd:date; parl:parliamentPeriodNumber ""54""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""2010-05-18""^^xsd:date; parl:parliamentPeriodEndDate ""2015-03-30""^^xsd:date; parl:parliamentPeriodNumber ""55""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""2015-05-18""^^xsd:date; parl:parliamentPeriodEndDate ""2017-05-03""^^xsd:date; parl:parliamentPeriodNumber ""56""^^xsd:integer; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>; parl:parliamentPeriodHasImmediatelyFollowingParliamentPeriod <{2}>.",
    "<{0}> a parl:ParliamentPeriod; parl:parliamentPeriodStartDate ""2017-06-13""^^xsd:date; parl:parliamentPeriodNumber ""57""^^xsd:integer; ; parl:parliamentPeriodHasImmediatelyPreviousParliamentPeriod <{1}>."
)

Log "Generating ids"
$ttl="PREFIX parl:<{0}> " -f $SchemaNamespace;

Log "Ids for hardcoded data"
foreach ($ttlVar in $ttls){
    Log $ttlVar
    $id=Invoke-RestMethod -Uri "$api/id/generate" -Method GET -Headers $header
    Log "Id: $id"
    $ttl+=$ttlVar -f $id
}

Log "Ids for parliamentary periods"
$parliamentIds=@()
for($i=0;$i -lt $parliamentPeriods.Length;$i++){
    Log "Period $($i+1)"
    $id=Invoke-RestMethod -Uri "$api/id/generate" -Method GET -Headers $header
    $parliamentIds+=$id
}

for($i=0;$i -lt $parliamentPeriods.Length;$i++){
    Log "Period $($i+1): $($parliamentIds[$i])"
    if ($i -eq 0) {
        $ttl+=($parliamentPeriods[$i] -f $parliamentIds[$i], $parliamentIds[$i+1])
    }
    if (($i -gt 0) -and ($i -lt ($parliamentPeriods.Length-1))) {
        $ttl+=($parliamentPeriods[$i] -f $parliamentIds[$i], $parliamentIds[$i-1], $parliamentIds[$i+1])
    }
    if ($i -eq ($parliamentPeriods.Length-1)) {
        $ttl+=($parliamentPeriods[$i] -f $parliamentIds[$i], $parliamentIds[$i-1])
    }
}

#SPARQL below removes ALL DATA and ontology
$clearOntologySparql="DELETE{?s ?p ?o}INSERT{[] <http://www.ontotext.com/owlim/system#schemaTransaction> [].}WHERE {?s ?p ?o}"
Log "Removing data and old ontology"
Invoke-RestMethod -Uri "$api/rdf4j/master-0/repositories/Master/statements" -ContentType "application/x-www-form-urlencoded" -Method POST -Body @{update=$clearOntologySparql;} -Headers $header

$sparql=Get-Content -Path $OntologyFileLocation -Raw
Log "Posting ontology"
Invoke-RestMethod -Uri "$api/rdf4j/master-0/repositories/Master/statements" -ContentType "application/x-www-form-urlencoded" -Method POST -Body @{update=$sparql;} -Headers $header

Log "Posting data"
Invoke-RestMethod -Uri "$api/rdf4j/master-0/repositories/Master/statements" -ContentType "application/x-turtle" -Method POST -Body $ttl -Headers $header

Log "Job well done!"