Import-Module AzureRM.profile
Import-Module AzureRM.Automation

$tenantId = Get-AutomationVariable -Name 'tenantId'
$subscriptionId = Get-AutomationVariable -Name 'subscriptionId'
$resourceGroupName = Get-AutomationVariable -Name 'resourceGroupName'
$Location = Get-AutomationVariable -Name 'Location'
$applicationId = Get-AutomationVariable -Name 'applicationId'
$appSecretKey = Get-AutomationVariable -Name 'appSecretKey'
$connectionAssetName = "AzureRunAsConnection"
$conn = Get-AutomationConnection -Name $ConnectionAssetName
Add-AzureRmAccount -ServicePrincipal -Tenant $conn.TenantID -ApplicationId $conn.ApplicationId -CertificateThumbprint $conn.CertificateThumbprint -ErrorAction Stop | Write-Verbose
Set-AzureRmContext -SubscriptionId $conn.SubscriptionId -ErrorAction Stop | Write-Verbose




<#
Import-Module AzureRM.profile
Import-Module AzureRM.Automation

$tenantId = Get-AutomationVariable -Name 'tenantId'
$subscriptionId = Get-AutomationVariable -Name 'subscriptionId'
$resourceGroupName = Get-AutomationVariable -Name 'resourceGroupName'
$Location = Get-AutomationVariable -Name 'Location'
$applicationId = Get-AutomationVariable -Name 'applicationId'
$appSecretKey = Get-AutomationVariable -Name 'appSecretKey'

$CredentialAssetName = 'DefaultAzureCredential'
#Get the credential with the above name from the Automation Asset store
$Cred = Get-AutomationPSCredential -Name $CredentialAssetName
Add-AzureRmAccount -Environment 'AzureCloud' -Credential $Cred

$securePassword = $appSecretKey | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($applicationId, $appSecretKey)
Login-AzureRmAccount -ServicePrincipal -Credential $credential -TenantId $tenantId
Select-AzureRmSubscription -SubscriptionId $subscriptionId 

New-AzureRmResourceGroup -Name "RG01" -Location "South Central US"
#>
