Import-Module AzureRM.profile
Import-Module AzureRM.Automation

$subscriptionid = Get-AutomationVariable -Name 'subscriptionid'
$ResourceGroupName = Get-AutomationVariable -Name 'resourceGroupName'
$Location = Get-AutomationVariable -Name 'Location'
$Username = Get-AutomationVariable -Name 'Username'
$Password = Get-AutomationVariable -Name 'Password'

$CredentialAssetName = 'DefaultAzureCredential'
#Get the credential with the above name from the Automation Asset store
$Cred = Get-AutomationPSCredential -Name $CredentialAssetName
Login-AzureRmAccount -Credential $Cred
Select-AzureRmSubscription -SubscriptionId $subsriptionid
New-AzureRmResourceGroup -Name "RG01" -Location "South Central US"
