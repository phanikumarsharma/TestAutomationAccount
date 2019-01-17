Import-Module AzureRM.profile
Import-Module AzureRM.Automation

$TenantId = Get-AutomationVariable -Name 'TenantId'
$subscriptionid = Get-AutomationVariable -Name 'subscriptionid'
$ResourceGroupName = Get-AutomationVariable -Name 'resourceGroupName'
$Location = Get-AutomationVariable -Name 'Location'
$ApplicationId = Get-AutomationVariable -Name 'ApplicationId'
$AppSecretKey = Get-AutomationVariable -Name 'AppSecretKey'

Select-AzureRmSubscription -SubscriptionId $subscriptionid
$securePassword = $AppSecretKey | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $applicationId, $securePassword
Login-AzureRmAccount -ServicePrincipal -Credential $credential -TenantId $TenantId

New-AzureRmResourceGroup -Name "RG01" -Location "South Central US"
