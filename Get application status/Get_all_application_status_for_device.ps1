param(
[string]$user_id,
[string]$device_id
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

Connect-MgGraph

Write_Log -Message_Type "SUCCESS" -Message "Authentication" 
Write_Log -Message_Type "INFO" -Message "Checking applications for device: $device_id"

$ManagedApps_URL = "https://graph.microsoft.com/beta/users('$user_id')/mobileAppIntentAndStates('$device_id')"
$Apps = (Invoke-MgGraphRequest -Uri $ManagedApps_URL -Method GET -ea silentlycontinue).mobileAppList
$App_Status = @()
ForEach($App in $Apps)
	{
		$App_ID = $app.applicationId
		$Install_State = $App.installState
		If($Install_State -eq "failed")
			{				
				$Troubleshooting_GUID = $device_id+"_" + $App_ID
				$Troubleshooting_URL = "https://graph.microsoft.com/beta/users('$User_ID')/mobileAppTroubleshootingEvents('$Troubleshooting_GUID')"													
				$Get_Troubleshooting_infos = (Invoke-MgGraphRequest -Uri $Troubleshooting_URL -Method GET -ea silentlycontinue)					
				$Get_Troubleshooting_History = $Get_Troubleshooting_infos.history 
				$Install_Error_Code = $Get_Troubleshooting_History.errorCode
				$Failure_Details = $Get_Troubleshooting_History.troubleshootingErrorDetails.failureDetails   																										
			}
		Else
			{
				$Install_Error_Code = ""
				$Failure_Details = ""				
			}
		
		$Obj = New-Object PSObject
		Add-Member -InputObject $Obj -MemberType NoteProperty -Name "Name" -Value $App.displayName
		Add-Member -InputObject $Obj -MemberType NoteProperty -Name "Version" -Value $App.displayVersion
		Add-Member -InputObject $Obj -MemberType NoteProperty -Name "State" -Value $App.installState	
		Add-Member -InputObject $Obj -MemberType NoteProperty -Name "Error code" -Value $Install_Error_Code		
		Add-Member -InputObject $Obj -MemberType NoteProperty -Name "Error details" -Value $Failure_Details				
		$App_Status += $Obj				
	}
	
$App_Status | out-gridview	