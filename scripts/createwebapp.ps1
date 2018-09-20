$subsriptionid = Get-AutomationVariable -Name 'subsriptionid'
$ResourceGroupName = Get-AutomationVariable -Name 'ResourceGroupName'
$Location = Get-AutomationVariable -Name 'Location'
$Username = Get-AutomationVariable -Name 'Username'
$Password = Get-AutomationVariable -Name 'Password'
$appplan =  Get-AutomationVariable -Name 'appplan'
$webapp =  Get-AutomationVariable -Name 'webapp'
New-AzureRmAppServicePlan -Name "TestWebappplan999" -Location $Location -ResourceGroupName $ResourceGroupName -Tier Free
New-AzureRmWebApp -Name "TestWebappp99" -AppServicePlan "TestWebappplan999" -ResourceGroupName $ResourceGroupName -Location $Location
