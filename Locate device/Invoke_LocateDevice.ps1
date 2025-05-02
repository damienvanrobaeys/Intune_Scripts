param(
[string]$Device_Name,
[switch]$UseLastLocation,		
[switch]$MAP,
[switch]$Address	
)


# Validate if no parameter is passed
if (-not $PSBoundParameters.Keys.Count) {
    Write-Warning "Please specify a parameter."
    Break
}

# Prompt credentials
Connect-MgGraph

# With a secret
# $tenantID = ""
# $clientId = ""
# $Secret = ""
# $myAccessToken = Get-MsalToken -ClientId $clientID -TenantId $tenantID -ClientSecret $Secret
# Connect-MgGraph -TenantId $tenantID -ClientSecretCredential $ClientSecretCredential

# With a certificate
# $Script:tenantID = ""
# $Script:clientId = ""	
# $Script:Thumbprint = ""
# $ClientCertificate = Get-Item "Cert:\LocalMachine\My\$($thumbPrint)"	
# Connect-MgGraph -Certificate $ClientCertificate -TenantId $TenantId -ClientId $ClientId  | out-null		
	
write-host "Device name to locate is: $Device_Name"
write-host "Looking for the device ID..."
$Intune_Devices_URL = 'https://graph.microsoft.com/beta/deviceManagement/managedDevices?$filter' + "=contains(deviceName,'$Device_Name')"
$Get_Device = (Invoke-MgGraphRequest -Uri $Intune_Devices_URL  -Method GET).value
If($Get_Device -eq $null)
	{
		write-warning "Can not find the device $Device_Name"
		Break
	}

$Get_Device_ID = $Get_Device.id
write-host "Device ID is: $Get_Device_ID"

$URL_location = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$Get_Device_ID"
$URL_locate_action = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$Get_Device_ID/locateDevice"

If($UseLastLocation)
	{
		$Check_Last_Location_Action = (Invoke-MgGraphRequest -Uri $URL_location  -Method GET).deviceActionResults | where {$_.actionName -eq "locateDevice"}		
		If($Check_Last_Location_Action -ne $null)
			{
				$Last_Check_Date = $Check_Last_Location_Action.lastUpdatedDateTime
				$Check_Location = $Check_Last_Location_Action.deviceLocation
				write-host "Last check: $Last_Check_Date"
			}
		Else
			{
				write-warning "Location is empty..."
			}
	}
Else
	{
		Invoke-MgGraphRequest -Uri $url_locate_action -Method POST
		Do{
			$Check_Location = (Invoke-MgGraphRequest -Uri $URL_location  -Method GET).deviceActionResults.deviceLocation
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
		write-host "Latitude: $Latitude, Longitude: $Longitude"
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

