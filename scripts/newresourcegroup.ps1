$subscriptionid = Get-AutomationVariable -Name 'subscriptionid'
$ResourceGroupName = Get-AutomationVariable -Name 'resourceGroupName'
$Location = Get-AutomationVariable -Name 'Location'
$Username = Get-AutomationVariable -Name 'Username'
$Password = Get-AutomationVariable -Name 'Password'

New-AzureRmResourceGroup -Name RG01 -Location "South Central US"
