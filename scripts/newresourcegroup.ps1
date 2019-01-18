$tenantId = Get-AutomationVariable -Name 'tenantId'
$subscriptionId = Get-AutomationVariable -Name 'subscriptionId'
$resourceGroupName = Get-AutomationVariable -Name 'resourceGroupName'
$Location = Get-AutomationVariable -Name 'Location'
$applicationId = Get-AutomationVariable -Name 'applicationId'
$appSecretKey = Get-AutomationVariable -Name 'appSecretKey'
$securePassword = $appSecretKey | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($applicationId, $appSecretKey)
Login-AzureRmAccount -ServicePrincipal -Credential $credential -TenantId $tenantId
Select-AzureRmSubscription -SubscriptionId $subscriptionId 
