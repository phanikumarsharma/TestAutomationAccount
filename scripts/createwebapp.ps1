$subsriptionid = Get-AutomationVariable -Name 'subsriptionid'
$ResourceGroupName = Get-AutomationVariable -Name 'ResourceGroupName'
$Location = Get-AutomationVariable -Name 'Location'
$Username = Get-AutomationVariable -Name 'Username'
$Password = Get-AutomationVariable -Name 'Password'

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

try
{
    # Copy the files from github to VM
    Import-Module AzureRM.Profile
    Import-Module AzureRM.Resources

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

            }
            catch [Exception]
            {
                Write-Output $_.Exception.Message
            }
        
        }

}

catch [Exception]
{
    Write-Output $_.Exception.Message
}
