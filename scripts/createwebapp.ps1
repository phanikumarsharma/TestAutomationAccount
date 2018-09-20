$subsriptionid = Get-AutomationVariable -Name 'subsriptionid'
$ResourceGroupName = Get-AutomationVariable -Name 'ResourceGroupName'
$Location = Get-AutomationVariable -Name 'Location'
$Username = Get-AutomationVariable -Name 'Username'
$Password = Get-AutomationVariable -Name 'Password'

New-AzureRmAppServicePlan -Name "TestWebappplan999" -Location "centralus" -ResourceGroupName "TestAutomation-RG" -Tier Free
New-AzureRmWebApp -Name "TestWebappp99" -AppServicePlan "TestWebappplan999" -ResourceGroupName "TestAutomation-RG" -Location "centralus"
