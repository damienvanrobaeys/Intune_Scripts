param(
[string]$Device_Name,
[switch]$LastLocation,		
[switch]$MAP,
[switch]$Address	
)

write-host "Device name to locate is: $Device_Name"
write-host "Looking for the device ID..."
$Get_Device = Get-IntuneManagedDevice | Get-MSGraphAllPages | where{$_.deviceName -like "$Device_Name"}
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
		$Check_Location = (Invoke-MSGraphRequest -Url $URL_location -HttpMethod GET).deviceActionResults.deviceLocation	
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
		Invoke-MSGraphRequest -Url $url_locate_action -HttpMethod POST
		Do{
			$Check_Location = (Invoke-MSGraphRequest -Url $URL_location -HttpMethod GET).deviceActionResults.deviceLocation	
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

