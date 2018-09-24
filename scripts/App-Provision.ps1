$subsriptionid = Get-AutomationVariable -Name 'subsriptionid'
$ResourceGroupName = Get-AutomationVariable -Name 'ResourceGroupName'
$Location = Get-AutomationVariable -Name 'Location'
$fileURI = Get-AutomationVariable -Name 'fileURI'
$Username = Get-AutomationVariable -Name 'Username'
$Password = Get-AutomationVariable -Name 'Password'


Invoke-WebRequest -Uri $fileURI -OutFile "C:\msft-rdmi-saas-offering.zip"
New-Item -Path "C:\msft-rdmi-saas-offering" -ItemType directory -Force -ErrorAction SilentlyContinue
Expand-Archive "C:\msft-rdmi-saas-offering.zip" -DestinationPath "C:\msft-rdmi-saas-offering" -ErrorAction SilentlyContinue
$AzureModulesPath = Get-ChildItem -Path "C:\msft-rdmi-saas-offering\msft-rdmi-saas-offering"| Where-Object {$_.FullName -match 'AzureModules.zip'}
Expand-Archive $AzureModulesPath.fullname -DestinationPath 'C:\Modules\Global' -ErrorAction SilentlyContinue

Import-Module AzureRM.Resources
Import-Module AzureRM.Profile
Import-Module AzureRM.Websites
Import-Module Azure
Import-Module AzureRM.Automation

    Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope Process -Force -Confirm:$false
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force -Confirm:$false
    Get-ExecutionPolicy -List
    #The name of the Automation Credential Asset this runbook will use to authenticate to Azure.
    $CredentialAssetName = 'DefaultAzureCredential'

    #Get the credential with the above name from the Automation Asset store
    $Cred = Get-AutomationPSCredential -Name $CredentialAssetName
    Add-AzureRmAccount -Environment 'AzureCloud' -Credential $Cred
    Select-AzureRmSubscription -SubscriptionId $subsriptionid

    $EnvironmentName = "AzureCloud"
    $AppServicePlan = "msft-rdmi-saas-$((get-date).ToString("ddMMyyyyhhmm"))"
    $WebApp = "RDmiMgmtWeb-$((get-date).ToString("ddMMyyyyhhmm"))"
    $ApiApp = "RDmiMgmtApi-$((get-date).ToString("ddMMyyyyhhmm"))"


try
{

    ## RESOURCE GROUP ##
        Add-AzureRmAccount -Environment "AzureCloud" -Credential $Cred
        Select-AzureRmSubscription -SubscriptionId $subsriptionid
        
        try 
        {
            ## APPSERVICE PLAN ##
               
            #create an appservice plan
        
            Write-Output "Creating AppServicePlan in resource group  $ResourceGroupName ...";
            New-AzureRmAppServicePlan -Name $AppServicePlan -Location $Location -ResourceGroupName $ResourceGroupName -Tier Standard
            $AppPlan = Get-AzureRmAppServicePlan -Name $AppServicePlan -ResourceGroupName $ResourceGroupName
            Write-Output "AppServicePlan with name $AppServicePlan has been created"

        }
        catch [Exception]
        {
            Write-Output $_.Exception.Message
        }

        if($AppServicePlan)
        {
            try
            {
                ## CREATING APPS ##

                # create a web app
            
                Write-Output "Creating a WebApp in resource group  $ResourceGroupName ...";
                New-AzureRmWebApp -Name $WebApp -Location $Location -AppServicePlan $AppServicePlan -ResourceGroupName $ResourceGroupName
                Write-Output "WebApp with name $WebApp has been created"

                ## CREATING API-APP ##

                # Create an api app
            
                Write-Output "Creating a ApiApp in resource group  $ResourceGroupName ...";
                $ServerFarmId = $AppPlan.Id
                $propertiesobject = @{"ServerFarmId"= $ServerFarmId}
                New-AzureRmResource -Location $Location -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites -ResourceName $ApiApp -Kind 'api' -ApiVersion 2016-08-01 -PropertyObject $propertiesobject -Force
                Write-Output "ApiApp with name $ApiApp has been created"
            }
            catch [Exception]
            {
                Write-Output $_.Exception.Message
            }
        
        }
     
}
catch [Exception]
<<<<<<< HEAD:scripts/App-Provision.ps1
{
    Write-Output $_.Exception.Message
}

New-PSDrive -Name RemoveAccount -PSProvider FileSystem -Root "C:\" | Out-Null
@"
Param(
    [Parameter(Mandatory=`$True)]
    [string] `$SubscriptionId,
    [Parameter(Mandatory=`$True)]
    [String] `$Username,
    [Parameter(Mandatory=`$True)]
    [string] `$Password,
    [Parameter(Mandatory=`$True)]
    [string] `$ResourceGroupName
 
)

Import-Module AzureRM.profile
Import-Module AzureRM.Automation

`$Securepass=ConvertTo-SecureString -String `$Password -AsPlainText -Force
`$Azurecred=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList(`$Username, `$Securepass)
`$login=Login-AzureRmAccount -Credential `$Azurecred -SubscriptionId `$SubscriptionId

Remove-AzureRmAutomationAccount -Name "msftsaas-autoAccount" -ResourceGroupName `$ResourceGroupName -Force 
"@| Out-File -FilePath RemoveAccount:\RemoveAccount.ps1 -Force

    $CredentialAssetName = 'DefaultAzureCredential'

    #Get the credential with the above name from the Automation Asset store
    $Cred = Get-AutomationPSCredential -Name $CredentialAssetName
   login-AzureRmAccount -Environment 'AzureCloud' -Credential $Cred
    Select-AzureRmSubscription -SubscriptionId $subsriptionid


    $runbookName='removemsftsaasact'
    $automationAccountName="msftsaas-autoAccount"
    #Create a Run Book
    $AAcctRunbook=New-AzureRmAutomationRunbook -Name $runbookName -Type PowerShell -ResourceGroupName $ResourceGroupName -AutomationAccountName $automationAccountName

    #Import modules to Automation Account
    $modules="AzureRM.profile,Azurerm.compute,azurerm.resources"
    $modulenames=$modules.Split(",")
    foreach($modulename in $modulenames){
    Set-AzureRmAutomationModule -Name $modulename -AutomationAccountName $automationAccountName -ResourceGroupName $ResourcegroupName
=======
    {
        Write-Output $_.Exception.Message
>>>>>>> a9c4b1adb94b927219847933ce75fc58f338636c:scripts/New-RdmiMgmtSetup.ps1
    }


