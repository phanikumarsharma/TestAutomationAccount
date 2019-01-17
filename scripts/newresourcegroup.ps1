Import-Module AzureRM.profile
Import-Module AzureRM.Automation

$TenantId = Get-AutomationVariable -Name 'TenantId'
$subscriptionid = Get-AutomationVariable -Name 'subscriptionid'
$ResourceGroupName = Get-AutomationVariable -Name 'resourceGroupName'
$Location = Get-AutomationVariable -Name 'Location'
$ApplicationId = Get-AutomationVariable -Name 'ApplicationId'
$AppSecretKey = Get-AutomationVariable -Name 'AppSecretKey'

$CredentialAssetName = 'DefaultAzureCredential'
#Get the credential with the above name from the Automation Asset store
$Cred = Get-AutomationPSCredential -Name $CredentialAssetName
Login-AzureRmAccount -Credential $Cred
Select-AzureRmSubscription -SubscriptionId $subscriptionid

New-AzureRmResourceGroup -Name "RG01" -Location "South Central US"
