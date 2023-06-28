param(
[string]$user_id,
[string]$device_id,
[string]$app_id
)

Function Write_Log
	{
		param(
		$Message_Type,	
		$Message
		)
		
		$MyDate = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)		
		write-host "$MyDate - $Message_Type : $Message"	
	}

Write_Log -Message_Type "INFO" -Message "Authenticating..." 
Write_Log -Message_Type "SUCCESS" -Message "Authentication" 

Connect-MgGraph

Write_Log -Message_Type "INFO" -Message "Checking application on Intune"

$Apps_URL = 'https://graph.microsoft.com/beta/deviceAppManagement/mobileApps?$filter' + "=contains(id,'$app_id')"
$Get_App = (Invoke-MgGraphRequest -Uri $Apps_URL  -Method GET).value | where {$_.id -eq $app_id}	
$Appli_ID = $Get_App.ID	
$App_DisplayName = $Get_App.displayName

Write_Log -Message_Type "INFO" -Message "Found application: $App_DisplayName"
Write_Log -Message_Type "INFO" -Message "Checking application status"

$App_Status_URL = "https://graph.microsoft.com/beta/users('$user_id')/mobileAppIntentAndStates('$device_id')"
$Get_App_Status = (Invoke-MgGraphRequest -Uri $App_Status_URL -Method GET -ea silentlycontinue)
$App_Status = $Get_App_Status.mobileAppList | where {$_.applicationId -eq "$App_ID"}
$Install_State = $App_Status.installState
If($Install_State -eq "installed")
	{
		Write_Log -Message_Type "INFO" -Message "Application $App_DisplayName is installed"		
	}ElseIf($Install_State -eq "failed"){					
		$Troubleshooting_GUID = $device_id+"_" + $App_ID
		$Troubleshooting_URL = "https://graph.microsoft.com/beta/users('$User_ID')/mobileAppTroubleshootingEvents('$Troubleshooting_GUID')"													
		$Get_Troubleshooting_infos = (Invoke-MgGraphRequest -Uri $Troubleshooting_URL -Method GET -ea silentlycontinue)					
		$Get_Troubleshooting_History = $Get_Troubleshooting_infos.history 
		$Install_Error_Code = $Get_Troubleshooting_History.errorCode
		$Failure_Details = $Get_Troubleshooting_History.troubleshootingErrorDetails.failureDetails   	

		Write_Log -Message_Type "INFO" -Message "Application $App_DisplayName install failed with below reason:
Code: $Install_Error_Code
Raison: $Failure_Details"																								
	}
