param(
[string]$DeviceName,
[switch]$ShowGrid
)

# Authentication part with Azure app
# $tenantID = ""
# $clientId = ""

# With a certificate
# $Thumbprint = ""
# $authority = "https://login.windows.net/$tenantID"
# Update-MSGraphEnvironment -AppId $clientId -Quiet
# Update-MSGraphEnvironment -AuthUrl $authority -Quiet
# Connect-MSGraph -CertificateThumbprint $Thumbprint

# With a secret
# $Secret = ""
# $authority = "https://login.windows.net/$tenantID"
# Update-MSGraphEnvironment -AppId $clientId -Quiet
# Update-MSGraphEnvironment -AuthUrl $authority -Quiet
# Connect-MSGraph -ClientSecret $Secret -Quiet

# Interactive Authentication part with native PowerShell intune app
connect-msgraph | out-null

write-host "Getting BSOD results for device: $DeviceName"
$DevicesURL = "https://graph.microsoft.com/beta/deviceManagement/managedDevices?" + '$filter=deviceName%20eq%20' + "'$DeviceName'"		
$DeviceID = (Invoke-MSGraphRequest -Url $DevicesURL -HttpMethod get).value.id	
If($DeviceID -eq $null)
	{
		write-warning "Can not find the device $DeviceName"
		Break
	}	
	
write-host "Device ID is: $DeviceID"

write-host "Checking BSOD results"
$StartupHistory_url = "https://graph.microsoft.com/beta/deviceManagement/userExperienceAnalyticsDeviceStartupHistory?" + '$filter=deviceId%20eq%20%27' + "$DeviceID%27"		
$Get_BSOD = (Invoke-MSGraphRequest -Url $StartupHistory_url -HttpMethod get).value | Where {$_.restartCategory -eq "blueScreen"}
If($Get_BSOD -eq $null)
	{
		write-warning "There is no BSOD result for device: $DeviceName"
		Break
	}	
	
$BSOD_Array = @()		
ForEach($BSOD in $Get_BSOD)
	{
		$BSOD_Obj = New-Object PSObject
		Add-Member -InputObject $BSOD_Obj -MemberType NoteProperty -Name "Device name" -Value $DeviceName
		Add-Member -InputObject $BSOD_Obj -MemberType NoteProperty -Name "Device ID" -Value $DeviceID
		Add-Member -InputObject $BSOD_Obj -MemberType NoteProperty -Name "OS version" -Value $BSOD.operatingSystemVersion				
		Add-Member -InputObject $BSOD_Obj -MemberType NoteProperty -Name "Date" -Value $BSOD.startTime		
		Add-Member -InputObject $BSOD_Obj -MemberType NoteProperty -Name "Stop code" -Value $BSOD.restartStopCode
		Add-Member -InputObject $BSOD_Obj -MemberType NoteProperty -Name "Fault bucket" -Value $BSOD.restartFaultBucket
		$BSOD_Array += $BSOD_Obj	
	}
If($ShowGrid)
	{
		$BSOD_Array | out-gridview
	}	
Else
	{
		$Get_BSOD
	}