$subsriptionid = Get-AutomationVariable -Name 'subsriptionid'
$ResourceGroupName = Get-AutomationVariable -Name 'ResourceGroupName'
$Location = Get-AutomationVariable -Name 'Location'
$Username = Get-AutomationVariable -Name 'Username'
$Password = Get-AutomationVariable -Name 'Password'
$appplan =  Get-AutomationVariable -Name 'appplan'
$webapp =  Get-AutomationVariable -Name 'webapp'
$Securepass=ConvertTo-SecureString -String $Password -AsPlainText -Force
$Azurecred=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList($Username, $Securepass)
$login= Login-AzureRmAccount -Credential $Azurecred -SubscriptionId $subsriptionid
New-AzureRmAppServicePlan -Name $appplan -Location $Location -ResourceGroupName $ResourceGroupName -Tier Free
New-AzureRmWebApp -Name $webapp -AppServicePlan $appplan -ResourceGroupName $ResourceGroupName -Location $Location
