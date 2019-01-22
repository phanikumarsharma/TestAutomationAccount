$tenantId = Get-AutomationVariable -Name 'tenantId'
$subscriptionId = Get-AutomationVariable -Name 'subscriptionId'
$resourceGroupName = Get-AutomationVariable -Name 'resourceGroupName'
$Location = Get-AutomationVariable -Name 'Location'
$accountName = Get-AutomationVariable -Name 'accountName'
$applicationDisplayName = Get-AutomationVariable -Name 'applicationDisplayName'
$applicationId = Get-AutomationVariable -Name 'applicationId'
$appSecretKey = Get-AutomationVariable -Name 'appSecretKey'
$securePassword = $appSecretKey | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($applicationId, $securePassword)
Connect-AzureRmAccount -Credential $cred -ServicePrincipal -TenantId $tenantId

$userPassword = ConvertTo-SecureString -String $securePassword -AsPlainText -Force
$userCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $applicationId, $userPassword
Add-AzureRmAccount -TenantId $tenantid -ServicePrincipal -SubscriptionId $subscriptionId -Credential $userCredential

 
