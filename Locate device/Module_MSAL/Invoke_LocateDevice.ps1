param(
[string]$Device_Name,
[switch]$LastLocation,		
[switch]$MAP,
[switch]$Address	
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

write-host "Device name to locate is: $Device_Name"
write-host "Looking for the device ID..."
$Intune_Devices_URL = "https://graph.microsoft.com/beta/deviceManagement/managedDevices"
$Intune_list_Devices = (Invoke-RestMethod -Headers @{Authorization = "Bearer $($myAccessToken.AccessToken)" } -Uri $Intune_Devices_URL -Method Get).value 
$Get_Device = $Intune_list_Devices | Where {$_.deviceName -eq $Device_Name}
If($Get_Device -eq $null)
	{
		write-warning "Can not find the device $Device_Name"
		Break
	}
$Get_Device_ID = $Get_Device.ID
write-host "Device ID is: $Get_Device_ID"

$URL_location = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$Get_Device_ID"
$URL_locate_action = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$Get_Device_ID/locateDevice"

If($LastLocation)
	{
		$Check_Location = (Invoke-RestMethod -Headers @{Authorization = "Bearer $($myAccessToken.AccessToken)" } -Uri $URL_location -Method Get).deviceActionResults.deviceLocation	 
		If($Check_Location -ne $null)
			{
				$Last_Check_Date = $Check_Location.lastCollectedDateTime									
				write-host "Last check: $Last_Check_Date"												
			}	
		Else
			{
				write-warning "Location is empty..."
			}						
	}
Else
	{
		(Invoke-RestMethod -Headers @{Authorization = "Bearer $($myAccessToken.AccessToken)" } -Uri $url_locate_action -Method POST)	 

		Do{
			$Check_Location = (Invoke-RestMethod -Headers @{Authorization = "Bearer $($myAccessToken.AccessToken)" } -Uri $URL_location -Method Get).deviceActionResults.deviceLocation	 			
			If($Check_Location -eq $null)
				{
					write-host "Locating the device..."
					start-sleep 5
				}

		} Until($Check_Location -ne $null)			
	}

If($Check_Location -ne $null)
	{
		$Latitude = $Check_Location.latitude
		$Longitude = $Check_Location.longitude				
		If($MAP){Start-Process "https://www.google.com/maps?q=$Latitude,$Longitude"}
		If($Address)
			{
				$Lat = ($Latitude.ToString()).replace(",",".")
				$Long = ($Longitude.ToString()).replace(",",".")
				$Location = "https://geocode.xyz/" + "$Lat,$Long" + "?geoit=json"
				Try
					{
						Invoke-RestMethod $Location	
					}
				Catch
					{
						write-warning "Error while getting location address"
					}						
			}	

		If((!($MAP)) -and (!($Address)))
			{
				$Check_Location
			}
	}

