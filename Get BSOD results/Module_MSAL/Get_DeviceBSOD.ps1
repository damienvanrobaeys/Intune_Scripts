param(
[string]$DeviceName,
[switch]$ShowGrid
)

# Authentication part with Azure app
# $tenantID = ""
# $clientId = ""

# With a certificate
# $Thumbprint = ""
# $ClientCertificate = Get-Item "Cert:\LocalMachine\My\$($thumbPrint)"
# $myAccessToken = Get-MsalToken -ClientId $clientID -TenantId $tenantID -ClientCertificate $ClientCertificate

# With a secret
# $Secret = ""
# $myAccessToken = Get-MsalToken -ClientId $clientID -TenantId $tenantID -ClientSecret $Secret

# Interactive Authentication part with native PowerShell intune app
# $myAccessToken = Get-MsalToken -ClientId d1ddf0e4-d672-4dae-b554-9d5bdfd93547 -RedirectUri "urn:ietf:wg:oauth:2.0:oob" -Interactive


write-host "Getting BSOD results for device: $DeviceName"

write-host "Looking for the device ID..."
$DevicesURL = "https://graph.microsoft.com/beta/deviceManagement/managedDevices?" + '$filter=deviceName%20eq%20' + "'$DeviceName'"		
$DeviceID = (Invoke-RestMethod -Headers @{Authorization = "Bearer $($myAccessToken.AccessToken)" } -Uri $DevicesURL -Method Get).value 
If($DeviceID -eq $null)
	{
		write-warning "Can not find the device $DeviceName"
		Break
	}	
write-host "Device ID is: $DeviceID"
	
write-host "Checking BSOD results"
$StartupHistory_url = "https://graph.microsoft.com/beta/deviceManagement/userExperienceAnalyticsDeviceStartupHistory?" + '$filter=deviceId%20eq%20%27' + "$DeviceID%27"		
$Get_BSOD = (Invoke-RestMethod -Headers @{Authorization = "Bearer $($myAccessToken.AccessToken)" } -Uri $StartupHistory_url -Method Get).value | Where {$_.restartCategory -eq "blueScreen"} 
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