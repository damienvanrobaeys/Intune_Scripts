param (
		[Parameter(Mandatory=$true)]
        [string]$DynamicGroupName,
        [Parameter()]
        [string]$OrderID
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
# 									Create group part	
# ***************************************************************************************
##DynamicGroupRule Properties:
$DynamicGroupRule = "(device.devicePhysicalIds -any _ -eq ""[OrderID]:$OrderID"")"
		
# Creating group
$Group_URL = "https://graph.microsoft.com/beta/groups/"	
$group = @{
	"displayName" = $DynamicGroupName;
	"description" = "This is used Windows 10 Autopilot Device with the OrderID $OrderID";
	"groupTypes" = @("DynamicMembership");
	"mailEnabled" = $False;
	"mailNickname" = "AutoPilotGroup-$OrderID";
	"membershipRule" = $DynamicGroupRule;
	"membershipRuleProcessingState" = "On";
	"securityEnabled" = $True
}	

$requestBody = $group | ConvertTo-Json #-Depth 5
$Create_group = Invoke-RestMethod -Headers @{Authorization = "Bearer $($myToken.AccessToken)" }  -Uri $Group_URL -Method POST -Body $requestBody -ContentType 'application/json'
$Group_ID = $Create_group.id

Write-Host "Group created! Save this Object ID: $($Group_ID) in a notepad for later use" -ForegroundColor Green


	
		