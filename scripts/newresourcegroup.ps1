$tenantId = Get-AutomationVariable -Name 'tenantId'
$subscriptionId = Get-AutomationVariable -Name 'subscriptionId'
$resourceGroupName = Get-AutomationVariable -Name 'resourceGroupName'
$Location = Get-AutomationVariable -Name 'Location'
$accountName = Get-AutomationVariable -Name 'accountName'
$applicationDisplayName = Get-AutomationVariable -Name 'applicationDisplayName'
$CertPassword = Get-AutomationVariable -Name 'SelfSignedCertPlainPassword'
$applicationId = Get-AutomationVariable -Name 'applicationId'
$appSecretKey = Get-AutomationVariable -Name 'appSecretKey'
$securePassword = $appSecretKey | ConvertTo-SecureString -AsPlainText -Force
$CredentialAssetName = 'DefaultAzureCredential'
#Get the credential with the above name from the Automation Asset store
$Cred = Get-AutomationPSCredential -Name $CredentialAssetName
Add-AzureRmAccount -Credential $Cred

 Param (

 [Parameter(Mandatory=$false)]
 [String] $subscriptionId = Get-AutomationVariable -Name 'subscriptionId',

 [Parameter(Mandatory=$false)]
 [String] $resourceGroupName = Get-AutomationVariable -Name 'resourceGroupName',

 [Parameter(Mandatory=$false)]
 [String] $accountName = Get-AutomationVariable -Name 'accountName',

 [Parameter(Mandatory=$false)]
 [String] $applicationDisplayName = Get-AutomationVariable -Name 'applicationDisplayName',

 [Parameter(Mandatory=$false)]
 [SecureString] $CertPassword = Get-AutomationVariable -Name 'CertPassword',

 [Parameter(Mandatory=$false)]
 [int] $NoOfMonthsUntilExpired = 12,

 [string]$backupCertVaultName


 )


#Uncomment for authentication if running independently
#Add-AzureRmAccount -EnvironmentName "AzureUSGovernment"
#Select-AzureRmSubscription -SubscriptionId $SubscriptionId


$CurrentDate = Get-Date
$KeyId = (New-Guid).Guid
$CertPath = Join-Path $env:TEMP ($ApplicationDisplayName + ".pfx")

Write-Verbose "Create a new certificate for authentication of server (automation run as) service principal"
$Cert = Get-ChildItem -Path cert:\LocalMachine\My | Where-Object { ( $PSItem.Subject -eq "CN=SDTestAutomationUserRunAs") -and ($PSItem.NotAfter -gt (Get-Date).AddDays(90)) }

if( -not $Cert) {
	$Cert = New-SelfSignedCertificate -DnsName $ApplicationDisplayName -CertStoreLocation cert:\LocalMachine\My -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider"
}
Write-Verbose "Exporting authentication certificate"
Export-PfxCertificate -Cert ("Cert:\localmachine\my\" + $Cert.Thumbprint) -FilePath $CertPath -Password $CertPassword -Force | Write-Verbose

$PFXCert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate -ArgumentList @($CertPath, ([PSCredential]::new('fakeCred',$CertPassword).GetNetworkCredential().Password))
$KeyValue = [System.Convert]::ToBase64String($PFXCert.GetRawCertData())

Write-Verbose "Create Azure PSADKeyCredential"
$KeyCredential = New-Object Microsoft.Azure.Commands.Resources.Models.ActiveDirectory.PSADKeyCredential
$KeyCredential.StartDate = $CurrentDate
$KeyCredential.EndDate= $PFXCert.GetExpirationDateString()
$KeyCredential.KeyId = $KeyId
$KeyCredential.CertValue = $KeyValue

Write-Verbose "Checking for existing AzureRmADApplication $($applicationDisplayName)."
$Application = Get-AzureRmADApplication -DisplayNameStartWith $ApplicationDisplayName -ErrorAction SilentlyContinue

if ($null -eq $Application) {
	Write-Verbose "Creating Azure AD application $($applicationDisplayName)."
	# Create the Azure AD application - use newly create certificate for key credentials
	$Application = New-AzureRmADApplication -DisplayName $applicationDisplayName -HomePage ("http://" + $ApplicationDisplayName) -IdentifierUris ("http://" + $KeyId) -KeyCredentials $keyCredential
}

 $newApp = Get-AzureRmADApplication -ApplicationId "$($Application.ApplicationId)" -ErrorAction SilentlyContinue
 $AppRetries = 0;
  While ($newApp -eq $null -and $AppRetries -le 6)
 {
        sleep 5
        $newApp = Get-AzureRmADApplication -ApplicationId "$($Application.ApplicationId)" -ErrorAction SilentlyContinue
        $AppRetries++;
 }

# Create the child service principal for the Azure AD application
if (-not (Get-AzureRmADServicePrincipal | Where {$_.ApplicationId -eq $Application.ApplicationId})) {
	New-AzureRMADServicePrincipal -ApplicationId $Application.ApplicationId | Write-Verbose
}
Get-AzureRmADServicePrincipal | Where {$_.ApplicationId -eq $Application.ApplicationId} | Write-Verbose

 #When the service principal becomes active, create the appropriate role assignments
 $Retries = 0;
 $NewRole = Get-AzureRMRoleAssignment -ServicePrincipalName $Application.ApplicationId -ErrorAction SilentlyContinue
 While ($NewRole -eq $null -and $Retries -le 6)
 {
    # Sleep here for a few seconds to allow the service principal application to become active (should only take a couple of seconds normally)
    Sleep 5
    Try {
        New-AzureRMRoleAssignment -RoleDefinitionName "Contributor" -ServicePrincipalName $Application.ApplicationId | Write-Verbose -ErrorAction SilentlyContinue
        New-AzureRMRoleAssignment -RoleDefinitionName "User Access Administrator" -ServicePrincipalName $Application.ApplicationId | Write-Verbose -ErrorAction SilentlyContinue
    }
    Catch {
         Write-Verbose "Service Principal not yet active, delay before adding the the role assignment."
    }
    Sleep 10
    $NewRole = Get-AzureRMRoleAssignment -ServicePrincipalName $Application.ApplicationId -ErrorAction SilentlyContinue
    $Retries++;
 }
 Write-Verbose "Azure AD application - $($applicationDisplayName) - and service principal with role assignment(s) created."

 # Get the tenant id for this subscription
 $SubscriptionInfo = Get-AzureRmSubscription -SubscriptionId $subscriptionId
 $TenantID = $SubscriptionInfo | Select TenantId -First 1

 # Create the automation resources

Write-Verbose "Create the Azure automation certificate object"
if (-not ( get-AzureRmAutomationCertificate -ResourceGroupName $resourceGroupName -AutomationAccountName $accountName -Name "AzureRunAsCertificate"  -ErrorAction SilentlyContinue)) {
 New-AzureRmAutomationCertificate -ResourceGroupName $resourceGroupName -AutomationAccountName $accountName -Path $CertPath -Name "AzureRunAsCertificate" -Password $CertPassword -Exportable | write-verbose
 Write-Verbose "Azure automation certificate created - AzureRunAsCertificate - in Azure automation account: $($accountName)."
}

 # Create a Automation connection asset named AzureRunAsConnection in the Automation account. This connection uses the service principal, with the newly uploaded certificate.
 $ConnectionAssetName = "AzureRunAsConnection"
 Remove-AzureRmAutomationConnection -ResourceGroupName $resourceGroupName -AutomationAccountName $accountName -Name $ConnectionAssetName -Force -ErrorAction SilentlyContinue
 $ConnectionFieldValues = @{"ApplicationId" = $Application.ApplicationId; "TenantId" = $TenantID.TenantId; "CertificateThumbprint" = $Cert.Thumbprint; "SubscriptionId" = $SubscriptionId}
 New-AzureRmAutomationConnection -ResourceGroupName $resourceGroupName -AutomationAccountName $accountName -Name $ConnectionAssetName -ConnectionTypeName AzureServicePrincipal -ConnectionFieldValues $ConnectionFieldValues

 Write-Output "Azure automation connection created - $($ConnectionAssetName) - in Azure automation account: $($accountName)."


 if($backupCertVaultName){
    $secret = ConvertTo-SecureString -String $KeyValue -AsPlainText -Force
    $secretContentType = 'application/x-pkcs12'
    Set-AzureKeyVaultSecret -VaultName $backupCertVaultName -Name "$($applicationDisplayName)Cert" -SecretValue $secret -ContentType $secretContentType
 }
