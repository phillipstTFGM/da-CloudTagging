<#
    https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-using-tags

#>

# Check Az module

$AzModuleVersion = "2.0.0"

if (!(Get-InstalledModule -Name Az -MinimumVersion $AzModuleVersion -ErrorAction SilentlyContinue)) {
    Write-Host "This script requires to have Az Module version $AzModuleVersion installed..
It was not found, please install from: https://docs.microsoft.com/en-us/powershell/azure/install-az-ps"
    exit
} 


# Remove and re-add module if applicable:
$fnName = 'Tagging'
if(get-Module | Where-Object {$_.name -eq $fnName}){Remove-Module -Name $fnName}
Import-Module -Name ((Get-Item -Path ".\").FullName+"\Tagging.psm1") | out-null


# Set up working directories and files
$exclusionsDirPath = (Get-Item -Path ".\").FullName+"\TagExclusions\resource-capabilities\"
$exclusionsFileName = "\tag-support.csv"
$exclusionsFilePath = $exclusionsDirPath+$exclusionsFileName
$of = (Get-Item -Path ".\").FullName+"\results_$(get-date -format yyMMdd-HHmmssff).csv"
write-host $of
# $(get-date -format yyMMdd-HHmmssff)

if (Test-Path $of){Remove-Item $of}
("ResourceId,Subscription,ResourceGroup,Resource,ResourceType,Tags") | Out-File $of -Append

# Shouldnt need this
#Connect-AzAccount;

# Get latest exclusion file from Git Hub 
# pullExclusions $exclusionsDirPath

# Return array of resources to !not! be excluded.
$exclusions = getTagAllowed $exclusionsFilePath


# Only required for granularity
$subname="TfGM Geospatia"
$ResourceGroupName="CS-WebJobs-NorthEurope-scheduler"


# Shouldnt need this
#Connect-AzAccount;

$subs = Get-AzSubscription #-SubscriptionName $subname
$i = 0
$taggedResources = @()
# Relevant tags
$tags = @{"Project"=""}


foreach ($sub in $subs)
{

    Write-Host "............................."
    write-host $sub.Name
    
    Select-AzSubscription -Subscription $sub | Out-Null
    $rgs = Get-AzResource -Tag $tags

    # Loop over resource groups
    foreach ($resource in $rgs)
    {
        #write-host " > "$rg.ResourceGroupName

                
        #foreach ($resource in $r)
        #{
        #    $resource
        $tagStr = getTagValue $resource.Tags "Project" #convertHTtoString $resource.Tags
        ($resource.ResourceId+","+$sub.Name+","+
        $rg.ResourceGroupName+","+$resource.Name+
        ","+$resource.ResourceType+","+$tagStr) | Out-File $of -Append

        #}
        
    }
    $i=$i+1
    #if ($i -eq 3)
    #{break}
}