param (
		[Parameter(Mandatory=$true)]
		[string]$AzureADGroup,
		[Parameter(Mandatory=$true)]
		[string]$AutopilotProfileName		
    )


# ***************************************************************************************
# 									Check for module part	
# ***************************************************************************************

#Checking for correct modules and installing them if needed
$InstalledModules = Get-InstalledModule
$Module_Name = "MSAL.PS"
If ($InstalledModules.name -notcontains $Module_Name) {
	Write-Host "Installing module $Module_Name"
	Install-Module $Module_Name -Force
}
Else {
	Write-Host "$Module_Name Module already installed"
}		

#Importing Module
Write-Host "Importing Module $Module_Name"
Import-Module $Module_Name



# ***************************************************************************************
# 									Authentication part	
# ***************************************************************************************

#Connecting to Azure AD to Create the Group
# Write-Host "Connecting to Azure AD, fill the credential prompt"		
$myToken = Get-MsalToken -ClientId d1ddf0e4-d672-4dae-b554-9d5bdfd93547 -RedirectUri "urn:ietf:wg:oauth:2.0:oob" -Interactive


# ***************************************************************************************
# 									Create profile part	
# ***************************************************************************************
$AutopilotProfileDescription = "$AutopilotProfileName Azure AD Join AutoPilot Profile"
$Profile_Body = @{
	"@odata.type"                          = "#microsoft.graph.azureADWindowsAutopilotDeploymentProfile"
	displayName                            = "$($AutopilotProfileName)"
	description                            = "$($AutopilotProfileDescription)"
	language                               = 'os-default'
	extractHardwareHash                    = $false
	enableWhiteGlove                       = $true
	outOfBoxExperienceSettings             = @{
		"@odata.type"             = "microsoft.graph.outOfBoxExperienceSettings"
		hidePrivacySettings       = $true
		hideEULA                  = $true
		userType                  = 'Standard'
		deviceUsageType           = 'singleuser'
		skipKeyboardSelectionPage = $false
		hideEscapeLink            = $true
	}
	enrollmentStatusScreenSettings         = @{
		'@odata.type'                                    = "microsoft.graph.windowsEnrollmentStatusScreenSettings"
		hideInstallationProgress                         = $true
		allowDeviceUseBeforeProfileAndAppInstallComplete = $true
		blockDeviceSetupRetryByUser                      = $false
		allowLogCollectionOnInstallFailure               = $true
		customErrorMessage                               = "An error has occured. Please contact your IT Administrator"
		installProgressTimeoutInMinutes                  = "45"
		allowDeviceUseOnInstallFailure                   = $true
	}
} | ConvertTo-Json		
		
$Profile_URL = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeploymentProfiles"
$Create_Profile = Invoke-RestMethod -Headers @{Authorization = "Bearer $($myToken.AccessToken)" }  -Uri $Profile_URL -Method POST -Body $Profile_Body -ContentType 'application/json'
$Get_Profile_ID = $Create_Profile.ID



# ***************************************************************************************
# 									Assign profile part	
# ***************************************************************************************
$Assignment_Body = @"
{"target":{"@odata.type":"#microsoft.graph.groupAssignmentTarget","groupId":"$($AzureADGroup)"}}
"@

$Profile_Assignment_URL = "$Profile_URL/$($Get_Profile_ID)/assignments"
$Assign_Profile = Invoke-RestMethod -Headers @{Authorization = "Bearer $($myToken.AccessToken)" }  -Uri $Profile_Assignment_URL -Method POST -Body $Assignment_Body -ContentType 'application/json'
Write-Host "Profil created and assign to the group!" -ForegroundColor Green
	
	
	
	
	
		