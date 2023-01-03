param(
[int]$Count,
[switch]$CSV,
[switch]$GridView,
$Export_Folder
)	

# Authentication part with Azure app
# $tenantID = ""
# $clientId = ""

# With a certificate
# $Thumbprint = ""
# $ClientCertificate = Get-Item "Cert:\LocalMachine\My\$($thumbPrint)"
# Connect-MgGraph -Certificate $ClientCertificate -TenantId $TenantId -ClientId $ClientId -ForceRefresh | out-null		

# With a secret
# $Secret = ""
# $body =  @{
    # Grant_Type    = "client_credentials"
    # Scope         = "https://graph.microsoft.com/.default"
    # Client_Id     = $clientId
    # Client_Secret = $secret
# }
# $connection = Invoke-RestMethod `
    # -Uri https://login.microsoftonline.com/$tenantid/oauth2/v2.0/token `
    # -Method POST `
    # -Body $body
# $token = $connection.access_token
# Connect-MgGraph -AccessToken $token

If($CSV)
	{
		If($Export_Folder -ne $null)
			{
				$Result_file = "$Export_Folder\Exported_Results.csv"
			}
		Else
			{
				$Result_file = "$env:temp\Devices_BSOD.csv"
			}	
	}

$Top_BSOD_URL = "https://graph.microsoft.com/beta/deviceManagement/userExperienceAnalyticsDevicePerformance?dtFilter=all&`$orderBy=blueScreenCount%20desc&`$top=$Count&`$filter=blueScreenCount%20ge%201%20and%20blueScreenCount%20le%2050"
$All_BSOD = (Invoke-MgGraphRequest -Uri $Top_BSOD_URL -Method get).Value
$BSOD_Array = @()		
ForEach($BSOD in $All_BSOD)
	{
		$Device_Model = $BSOD.model
		$Device_Name = $BSOD.deviceName
		$BSOD_Count = $BSOD.blueScreenCount
		$DeviceID = $BSOD.id

		$StartupHistory_url = "https://graph.microsoft.com/beta/deviceManagement/userExperienceAnalyticsDeviceStartupHistory?" + '$filter=deviceId%20eq%20%27' + "$DeviceID%27"		
		$Get_BSOD = ((Invoke-MgGraphRequest -Uri $StartupHistory_url -Method get).value | Where {$_.restartCategory -eq "blueScreen"})[-1]	
		$Last_BSOD_Date = $Get_BSOD.startTime
		$Last_BSOD_Code = $Get_BSOD.restartStopCode
		$OS = $Get_BSOD.operatingSystemVersion		
		
		$BSOD_Obj = New-Object PSObject
		Add-Member -InputObject $BSOD_Obj -MemberType NoteProperty -Name "Device" -Value $Device_Name		
		Add-Member -InputObject $BSOD_Obj -MemberType NoteProperty -Name "Model" -Value $Device_Model		
		Add-Member -InputObject $BSOD_Obj -MemberType NoteProperty -Name "BSOD count" -Value $BSOD_Count		
		Add-Member -InputObject $BSOD_Obj -MemberType NoteProperty -Name "OS version" -Value $OS				
		Add-Member -InputObject $BSOD_Obj -MemberType NoteProperty -Name "Last BSOD date" -Value $Last_BSOD_Date		
		Add-Member -InputObject $BSOD_Obj -MemberType NoteProperty -Name "Last BSOD stop code" -Value $Last_BSOD_Code
		$BSOD_Array += $BSOD_Obj	
	}
	
If($CSV)
	{
		$BSOD_Array | Export-CSV $Result_file -Delimiter ";" -NoTypeInformation		
		invoke-item $Result_file
	}
	
If($GridView)
	{
		$BSOD_Array | Out-Gridview
	}