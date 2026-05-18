$Tenant = ""  # tenant name
$ClientID = "" # azure app client id 
$Secret = '' # azure app secret
$SharePoint_SiteID = ""  # sharepoint site id	
$SharePoint_Path = ""  # sharepoint main path
$SharePoint_ExportFolder = "Windows/Logs"  # folder where to upload file

$CompName = $env:computername
$Get_Day_Date = Get-Date -Format "dd-MM-yyyy"
$Log_File = "C:\Windows\Temp\Collect_Device_Content_$CompName" + "_$Get_Day_Date.log"
If(!(test-path $Log_File)){new-item $Log_File -type file -force | out-null}

Function Write_Log
	{
		param(
		$Message_Type,	
		$Message
		)
		
		$MyDate = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)		
		Add-Content $Log_File  "$MyDate - $Message_Type : $Message"	
		write-host "$MyDate - $Message_Type : $Message"	
	}
	
Function Get_DeviceUpTime
	{
		param(
		[Switch]$Show_Days,
		[Switch]$Show_Uptime			
		)		
		
		$Last_reboot = Get-ciminstance Win32_OperatingSystem | Select -Exp LastBootUpTime
		$Check_FastBoot = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -ea silentlycontinue).HiberbootEnabled 
		If(($Check_FastBoot -eq $null) -or ($Check_FastBoot -eq 0))
			{
				$Boot_Event = Get-WinEvent -ProviderName 'Microsoft-Windows-Kernel-Boot'| where {$_.ID -eq 27 -and $_.message -like "*0x0*"}
				If($Boot_Event -ne $null)
					{
						$Last_boot = $Boot_Event[0].TimeCreated
					}
			}
		ElseIf($Check_FastBoot -eq 1)
			{
				$Boot_Event = Get-WinEvent -ProviderName 'Microsoft-Windows-Kernel-Boot'| where {$_.ID -eq 27 -and $_.message -like "*0x1*"}
				If($Boot_Event -ne $null)
					{
						$Last_boot = $Boot_Event[0].TimeCreated
					}
			}		
			
		If($Last_boot -eq $null)
			{
				$Uptime = $Uptime = $Last_reboot
			}
		Else
			{
				If($Last_reboot -ge $Last_boot)
					{
						$Uptime = $Last_reboot
					}
				Else
					{
						$Uptime = $Last_boot
					}
			}
		
		If($Show_Days)
			{
				$Current_Date = get-date
				$Diff_boot_time = $Current_Date - $Uptime
				$Boot_Uptime_Days = $Diff_boot_time.Days	
				$Real_Uptime = $Boot_Uptime_Days
			}
		ElseIf($Show_Uptime)
			{
				$Real_Uptime = $Uptime
				
			}
		ElseIf(($Show_Days -eq $False) -and ($Show_Uptime -eq $False))
			{
				$Real_Uptime = $Uptime				
			}			
		Return "$Real_Uptime"
	}
	
Function DownloadFile
{
    param (
        [string[]]$Blob,
        [string[]]$Container,
        [string[]]$File,
        [string[]]$Folder
    )	
	
	write-output "Blob storage: $Blob"
	write-output "Container: $Container"
	write-output "File to download: $File"
	write-output "Export folder: $Folder"
	
	$SAS_Token = "sv=2024-11-04&ss=b&srt=o&sp=ryx&se=2027-04-01T15:58:00Z&st=2026-03-23T08:43:00Z&spr=https&sig=z1YNv%2FQhkSOasGEKFPrGxN7Awvmqy2Jzpv7WRZAzgLw%3D"
	If($SAS_Token -ne $null){
		$File_URL = "https://" + $Blob + ".blob.core.windows.net/" + $container + "/" + $file + "?$SAS_Token"	
	}Else{
		$File_URL = "https://" + $Blob + ".blob.core.windows.net/" + $container + "/" + $file		
	}
	$Full_Export_Path = "$Folder\$file"
	Invoke-WebRequest -Uri $File_URL -OutFile $Full_Export_Path -UseBasicParsing
}	
	
Function Get-NetworkStatistics
{
	$properties = 'Protocol','LocalAddress','LocalPort'
	$properties += 'RemoteAddress','RemotePort','State','ProcessName','PID'

	netstat -ano | Select-String -Pattern '\s+(TCP|UDP)' | ForEach-Object{

	$item = $_.line.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)
		If($item[1] -notmatch '^\[::')
		{	
			If (($la = $item[1] -as [ipaddress]).AddressFamily -eq 'InterNetworkV6')
			{
				$localAddress = $la.IPAddressToString
				$localPort = $item[1].split('\]:')[-1]
			}
			Else
			{
				$localAddress = $item[1].split(':')[0]
				$localPort = $item[1].split(':')[-1]
			}

			If (($ra = $item[2] -as [ipaddress]).AddressFamily -eq 'InterNetworkV6')
			{
				$remoteAddress = $ra.IPAddressToString
				$remotePort = $item[2].split('\]:')[-1]
			}
			Else
			{
				$remoteAddress = $item[2].split(':')[0]
				$remotePort = $item[2].split(':')[-1]
			}

			New-Object PSObject -Property @{
			PID = $item[-1]
			ProcessName = (Get-Process -Id $item[-1] -ErrorAction SilentlyContinue).Name
			Protocol = $item[0]
			LocalAddress = $localAddress
			LocalPort = $localPort
			RemoteAddress =$remoteAddress
			RemotePort = $remotePort
			State = if($item[0] -eq 'tcp') {$item[3]} else {$null}
			} |Select-Object -Property $properties
		}
	}
}		
	
Try
	{
		$OutFile = "C:\Windows\Temp\OnDemand_Content_to_collect.xml"
		DownloadFile -Blob "stagrtdwpprddevices" -Container "ondemandlogs" -File "OnDemand_Content_to_collect.xml" -Folder "C:\Windows\Temp"		
		$ContenttoCollect_File_Path = "C:\Windows\Temp\OnDemand_Content_to_collect.xml"				
		$XML_Downloaded = $True
		Write_Log -Message_Type "SUCCESS" -Message "Downloading XML"
	}
Catch
	{
		Write_Log -Message_Type "ERROR" -Message "Downloading XML"																		
		EXIT 1
	}	


$Logs_Collect_Folder = "C:\Windows\Temp\Logs_" + "$CompName" + "_$Get_Day_Date"
$Logs_Collect_Folder_ZIP = "$Logs_Collect_Folder" + ".zip"
$EVTX_files = "$Logs_Collect_Folder\EVTX_Files"
$Reg_Export = "$Logs_Collect_Folder\Export_Reg_Values.csv"
$Reg_Export_Folder = "$Logs_Collect_Folder\RegExport"
$Logs_Folder = "$Logs_Collect_Folder\All_logs"
$Device_Infos = "$Logs_Collect_Folder\Device infos"

$Content_to_collect_XML = [xml] (Get-Content $ContenttoCollect_File_Path)
If(test-path $Logs_Collect_Folder){remove-item $Logs_Collect_Folder -Recurse -Force}
new-item $Logs_Collect_Folder -type Directory -force | out-null
If(!(test-path $EVTX_files)){new-item $EVTX_files -type Directory -force | out-null}
If(!(test-path $Logs_Folder)){new-item $Logs_Folder -type Directory -force | out-null}	
If(!(test-path $Reg_Export_Folder)){new-item $Reg_Export_Folder -type Directory -force | out-null}	
If(!(test-path $Device_Infos)){new-item $Device_Infos -type Directory -force | out-null}	

Function Export_Logs_Files_Folders
	{
		param(
		$Log_To_Export,	
		$Log_Output
		)	
		
		If(test-path $Log_To_Export)
			{
				$Content_Name = Get-Item $Log_To_Export
				Try
					{
						Copy-Item $Log_To_Export $Log_Output -Recurse -Force -ea silentlycontinue
						Write_Log -Message_Type "SUCCESS" -Message "The folder $Content_Name has been successfully copied"													
					}
				Catch
					{
						Write_Log -Message_Type "ERROR" -Message "An issue occured while copying the folder $Content_Name"																				
					}
			}
		Else
			{
				Write_Log -Message_Type "ERROR" -Message "The following path does not exist: $Log_To_Export"			
			}
	}	
	
	
Function Export_Registry_Values
	{
		param(
		$Reg_Path,	
		$Reg_Specific_Value,
		$Output_Path
		)	
		
		If(test-path "registry::$Reg_Path")
			{					
				$Reg_Array = @()
				$Get_Reg_Values = Get-ItemProperty -path registry::$Reg_Path
				If($Reg_Specific_Value)
					{
						$List_Values = $Get_Reg_Values.$Reg_Specific_Value
						$Get_Reg_Values_Array = New-Object PSObject
						$Get_Reg_Values_Array = $Get_Reg_Values_Array | Add-Member NoteProperty Name $Reg_Specific_Value -passthru
						$Get_Reg_Values_Array = $Get_Reg_Values_Array | Add-Member NoteProperty Value $List_Values -passthru
						$Get_Reg_Values_Array = $Get_Reg_Values_Array | Add-Member NoteProperty Reg_Path $Reg_Path -passthru
					}
				Else	
					{
						$List_Values = $Get_Reg_Values.psobject.properties | select name, value | Where-Object {($_.name -ne "PSPath" -and $_.name -ne "PSParentPath" -and $_.name -ne "PSChildName" -and $_.name -ne "PSProvider")}
						$Get_Reg_Values_Array = New-Object PSObject
						$Get_Reg_Values_Array = $List_Values
						$Get_Reg_Values_Array = $Get_Reg_Values_Array | Add-Member NoteProperty Reg_Path $Reg_Path -passthru
					}
				
				$Reg_Array += $Get_Reg_Values_Array
				
				If(!(test-path $Output_Path))
					{			
						Try
							{
								$Reg_Array | export-csv $Output_Path  -notype
								Write_Log -Message_Type "SUCCESS" -Message "Registry values from $Reg_Path have been successfully exported"													
							}
						Catch
							{
								Write_Log -Message_Type "ERROR" -Message "An issue occured while exporting registry values from $Reg_Path"																				
							}					
					}
				Else
					{
						Try
							{
								$Reg_Array | export-csv -Append $Output_Path  -notype
								Write_Log -Message_Type "SUCCESS" -Message "Registry values from $Reg_Path have been successfully exported"													
							}
						Catch
							{
								Write_Log -Message_Type "ERROR" -Message "An issue occured while exporting registry values from $Reg_Path"																				
							}															
					}					
			}
		Else
			{
				Write_Log -Message_Type "ERROR" -Message "The following REG path does not exist: $Reg_Path"			
			}
	}	


Write_Log -Message_Type "INFO" -Message "Starting collecting Intune logs on $CompName"

Add-content $Log_File ""
Add-content $Log_File "---------------------------------------------------------------------------------------------------------"
Write_Log -Message_Type "INFO" -Message "Step 1 - Collecting event logs"
Add-content $Log_File "---------------------------------------------------------------------------------------------------------"		
$Event_Logs = Get-WinEvent -ListLog *
ForEach($Log in $Event_Logs) {
    Try{
        $LogName = ($log.LogName -replace '[\\/:*?"<>|]', '_')
        $EVTX_Log = Join-Path $EVTX_files "$LogName.evtx"
		Write_Log -Message_Type "INFO" -Message "Collecting logs from:  $($log.LogName)"
        # wevtutil epl "$($Log.LogName)" $EVTX_Log
        wevtutil epl "$($Log.LogName)" -ow:true /q:"*[System[TimeCreated[timediff(@SystemTime) <= 1296000000 ]]]" "$EVTX_Log" | out-null		
		Write_Log -Message_Type "SUCCESS" -Message "Collecting logs from:  $($log.LogName)"		
    }
    Catch {
		Write_Log -Message_Type "ERROR" -Message "Collecting logs from:  $($log.LogName)"		
    }
}
		
		
Add-content $Log_File ""
Add-content $Log_File "---------------------------------------------------------------------------------------------------------"
Write_Log -Message_Type "INFO" -Message "Step 2 - Copying files and folders"
Add-content $Log_File "---------------------------------------------------------------------------------------------------------"	
$Folder_To_Check = $Content_to_collect_XML.Content_to_collect.Folders.Folder_Path
ForEach($Explorer_Content in $Folder_To_Check)
	{		
		Export_Logs_Files_Folders -Log_To_Export $Explorer_Content -Log_Output $Logs_Folder		
	}	
	

Add-content $Log_File ""
Add-content $Log_File "---------------------------------------------------------------------------------------------------------"
Write_Log -Message_Type "INFO" -Message "Step 3 - Collecting registry keys"
Add-content $Log_File "---------------------------------------------------------------------------------------------------------"	
$Reg_Keys_To_Check = $Content_to_collect_XML.Content_to_collect.Reg_Keys.RegistryKey
ForEach($Reg in $Reg_Keys_To_Check)
	{
		If(!(Test-Path -Path "Registry::$Reg")) 
		{
			Write_Log -Message_Type "ERROR" -Message "Key not found: $Reg"	
		}Else{
			$FileName = $Reg.Replace("\","_")
			$Reg_Path = "$Reg_Export_Folder\$FileName.reg"
			reg export $Reg $Reg_Path /y	
			Write_Log -Message_Type "SUCCESS" -Message "Registry key export: $Reg"				
		}			
	}			

			
Add-content $Log_File ""
Add-content $Log_File "---------------------------------------------------------------------------------------------------------"
Write_Log -Message_Type "INFO" -Message "Step 3 - Collecting other content: services, KB..."
Add-content $Log_File "---------------------------------------------------------------------------------------------------------"		

# Copy folder Infos du poste
$CompName = $env:computername
$Device_Infos_Folder = "C:\Windows\temp\Device_Logs_From_$CompName\Infos du poste"

$Hotfix_CSV = "$Device_Infos\Hotfix_List.csv"
$Hotfix_list = Get-wmiobject win32_quickfixengineering | Select-Object hotfixid, Description, Caption, InstalledOn  | Sort-Object InstalledOn 
$Hotfix_list | export-CSV $Hotfix_CSV -delimiter ";" -notypeinformation	

$Services_CSV = "$Device_Infos\Services_List.csv"
$services_List = Get-wmiobject win32_service | Select-Object Name, Caption, State, Startmode
$services_List | export-CSV $Services_CSV -delimiter ";" -notypeinformation	

$ScheduledTask_CSV = "$Device_Infos\Scheduled_Task.csv"
$ScheduledTask_List = Get-ScheduledTask | select TaskName, TaskPath, State
$ScheduledTask_List | export-CSV $ScheduledTask_CSV -delimiter ";" -notypeinformation	

$Drivers_CSV = "$Device_Infos\Drivers_List.csv"
$Drivers_List = gwmi Win32_PnPSignedDriver | Select-Object devicename, manufacturer, driverversion, infname, IsSigned | where-object {$_.devicename -ne $null -and $_.infname -ne $null} | sort-object devicename -Unique 			
$Drivers_List | export-CSV $Drivers_CSV -delimiter ";" -notypeinformation	
	
$Process_CSV = "$Device_Infos\Process_List.csv"
$Process_List = gwmi win32_process | select ProcessName, caption, CommandLine, path, CreationDate, Description, ExecutablePath, Name, ProcessID, SessionID	
$Process_List | export-CSV $Process_CSV -delimiter ";" -notypeinformation	

$Pending_Updates_CSV = "$Device_Infos\Pending_Updates.csv"
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateSearcher = $UpdateSession.CreateupdateSearcher()
$Updates = @($UpdateSearcher.Search("IsHidden=0 and IsInstalled=0 and Type='Software'").Updates)
$Pending_Updates = $Updates  | Select-Object Title, Description, LastdeploymentChangeTime, SupportUrl, Type, RebootRequired 
$Pending_Updates | export-CSV $Pending_Updates_CSV -delimiter ";" -notypeinformation	

$Get_Disk_info = Get-PhysicalDisk | where {$_.DeviceId -eq 0} 	
$Get_Disk_info_Details = $Get_Disk_info| Get-StorageReliabilityCounter | select *
$Get_Disk_info | export-csv "$Device_Infos\Disk_Info.csv" -notype -delimiter ";"
$Get_Disk_info_Details | export-csv "$Device_Infos\Hard_Disk_Details.csv" -notype -delimiter ";"

$Printers_CSV = "$Device_Infos\Printers_List.csv"
$Get_Printers = get-printer | select Name,Type,DriverName,PortName
$Get_Printers | export-CSV $Printers_CSV -delimiter ";" -notypeinformation			

$NetAdapters_CSV = "$Device_Infos\NetAdapters_List.csv"
$Get_NetAdapters = Get-NetAdapter | select Name,InterfaceDescription,ifIndex,Status,MacAddress,LinkSpeed
$Get_NetAdapters | export-csv $NetAdapters_CSV -notype -delimiter ";" -force		

$Processors_CSV = "$Device_Infos\Processors_List.csv"
$Get_Processors = Get-ciminstance Win32_Processor
$Get_Processors | export-csv $Processors_CSV -notype -delimiter ";" -force

$MissingDrivers_CSV = "$Device_Infos\Missing_Drivers_List.csv"
$Get_MissingDrivers = Get-WmiObject Win32_PNPEntity | Where-Object {$_.ConfigManagerErrorCode -eq 28 }
$Get_MissingDrivers | export-csv $MissingDrivers_CSV -notype -delimiter ";" -force

$MpPreference_CSV = "$Device_Infos\MpPreference_List.csv"
$Get_MpPreference = Get-MpPreference
$Get_MpPreference | export-csv $MpPreference_CSV -notype -delimiter ";" -force

$MpComputerStatus_CSV = "$Device_Infos\MpComputerStatus_List.csv"
$Get_MpComputerStatus = Get-MpComputerStatus	
$Get_MpComputerStatus | export-csv $MpComputerStatus_CSV -notype -delimiter ";" -force

$DsregcmdCSV = "$Device_Infos\DSregcmd.csv"
$Dsregcmd = New-Object PSObject ; Dsregcmd /status | Where {$_ -match ' : '}|ForEach {$Item = $_.Trim() -split '\s:\s'; $Dsregcmd|Add-Member -MemberType NoteProperty -Name $($Item[0] -replace '[:\s]','') -Value $Item[1] -EA SilentlyContinue}		
$Dsregcmd | export-csv $DsregcmdCSV -notype -delimiter ";"

ipconfig | out-file "$Device_Infos\IP.txt"
Get_DeviceUpTime | out-file "$Device_Infos\Uptime.txt"

# Getting device certificates
$Cert_machine_CSV = "$Device_Infos\Certificate_Device.csv"
gci Cert:\LocalMachine -recurse | select Subject, Issuer, Thumbprint, NotBefore, NotAfter | export-CSV $Cert_machine_CSV -delimiter ";" -notypeinformation	

# Getting user certificates
$Cert_Users_CSV = "$Device_Infos\Certificate_User.csv"
gci Cert:\CurrentUser -recurse | select Subject, Issuer, Thumbprint, NotBefore, NotAfter | export-CSV $Cert_Users_CSV -delimiter ";" -notypeinformation		
	
# Getting local admin
$Get_Local_AdminGroup = Gwmi win32_group -Filter "Domain='$env:computername' and SID='S-1-5-32-544'"
$Get_Local_AdminGroup_Name = $Get_Local_AdminGroup.Name
$Get_Local_AdminGroup_Members = ([ADSI]"WinNT://./$Get_Local_AdminGroup_Name").psbase.Invoke('Members') | % {
 ([ADSI]$_).InvokeGet('AdsPath')
}
$Get_Local_AdminGroup_Members = $Get_Local_AdminGroup_Members -replace "WinNT://",""
$Get_Local_AdminGroup_Members | out-file "$Device_Infos\Local_Admin.txt"
	
# Getting local user account(s)	
get-localuser | select name, description, PasswordLastSet, Enabled | export-CSV "$Device_Infos\Local_User.csv" -delimiter ";" -notypeinformation		
	
# Getting running processes and their port number
$NetworkStatistics_CSV = "$Device_Infos\Process_and_ports_List.csv"
$Get_NetworkStatistics = Get-NetworkStatistics	
$Get_NetworkStatistics | export-csv $NetworkStatistics_CSV -notype -delimiter ";" -force		
	
Add-content $Log_File ""
Add-content $Log_File "---------------------------------------------------------------------------------------------------------"
Write_Log -Message_Type "INFO" -Message "Step 5 - Creating the ZIP with logs"
Add-content $Log_File "---------------------------------------------------------------------------------------------------------"
Try
	{
		Add-Type -assembly "system.io.compression.filesystem"
		[io.compression.zipfile]::CreateFromDirectory($Logs_Collect_Folder, $Logs_Collect_Folder_ZIP) 
		Write_Log -Message_Type "SUCCESS" -Message "The ZIP file has been successfully created"	
		Write_Log -Message_Type "INFO" -Message "The ZIP is located in :$Logs_Collect_Folder_ZIP"				
	}
Catch
	{
		Write_Log -Message_Type "ERROR" -Message "An issue occured while creating the ZIP file"		
	}

# Authentification sur SharePoint et upload du fichier
$Body = @{  
    client_id = $ClientID
    client_secret = $Secret
    scope = "https://graph.microsoft.com/.default"   
    grant_type = 'client_credentials'  
}  
  
Write_Log -Message_Type "INFO" -Message "SharePoint connexion"	
$Graph_Url = "https://login.microsoftonline.com/$($Tenant).onmicrosoft.com/oauth2/v2.0/token"  

Try
	{
		$AuthorizationRequest = Invoke-RestMethod -Uri $Graph_Url -Method "Post" -Body $Body  
		Write_Log -Message_Type "SUCCESS" -Message "Connected to SharePoint"	
	}
Catch
	{
		Write_Log -Message_Type "ERROR" -Message "Connexion to SharePoint failed"	
		EXIT
	}
	
$Access_token = $AuthorizationRequest.Access_token  
$Header = @{  
    Authorization = $AuthorizationRequest.access_token  
    "Content-Type"= "application/json"  
    'Content-Range' = "bytes 0-$($fileLength-1)/$fileLength"	
}  

$SharePoint_Graph_URL = "https://graph.microsoft.com/v1.0/sites/$SharePoint_SiteID/drives"  
$BodyJSON = $Body | ConvertTo-Json -Compress  

Write_Log -Message_Type "INFO" -Message "Getting SharePoint site info"	

Try
	{
		$Result = Invoke-RestMethod -Uri $SharePoint_Graph_URL -Method 'GET' -Headers $Header -ContentType "application/json"   
		Write_Log -Message_Type "SUCCESS" -Message "Getting SharePoint site info"		
	}
Catch
	{
		Write_Log -Message_Type "ERROR" -Message "Getting SharePoint site info"	
		EXIT
	}

$DriveID = $Result.value| Where-Object {$_.webURL -eq $SharePoint_Path } | Select-Object id -ExpandProperty id  

$FileName = $Logs_Collect_Folder_ZIP.Split("\")[-1]  
$createUploadSessionUri = "https://graph.microsoft.com/v1.0/sites/$SharePoint_SiteID/drives/$DriveID/root:/$SharePoint_ExportFolder/$($fileName):/createUploadSession"

Write_Log -Message_Type "INFO" -Message "File to upload: $FileName"	
Write_Log -Message_Type "INFO" -Message "Preparing the file for the upload"	

Try
	{
		$uploadSession = Invoke-RestMethod -Uri $createUploadSessionUri -Method 'POST' -Headers $Header -ContentType "application/json" 
		Write_Log -Message_Type "SUCCESS" -Message "Preparing the file for the upload"			
	}
Catch
	{
		Write_Log -Message_Type "ERROR" -Message "Preparing the file for the upload"			
		EXIT
	}

$fileInBytes = [System.IO.File]::ReadAllBytes($Logs_Collect_Folder_ZIP)
$fileLength = $fileInBytes.Length

$headers = @{
  'Content-Range' = "bytes 0-$($fileLength-1)/$fileLength"
}

Write_Log -Message_Type "INFO" -Message "Uploading file"	
Try
	{
		$response = Invoke-RestMethod -Method 'Put' -Uri $uploadSession.uploadUrl -Body $fileInBytes -Headers $headers
		Write_Log -Message_Type "SUCCESS" -Message "File has been uploaded"	
		$Upload_file_status = $true
	}
Catch
	{
		Write_Log -Message_Type "ERROR" -Message "Failed to upload the file"
		EXIT
	}
												
If(test-path $Logs_Collect_Folder){Remove-Item $Logs_Collect_Folder -Force -Recurse}
If(test-path $Logs_Collect_Folder_ZIP){Remove-Item $Logs_Collect_Folder_ZIP -Force}

If($Upload_file_status -eq $True)
	{
		write-output "File uploaded"	
		EXIT 0			
	}
Else
	{
		$Reported_error = $error[0].exception.message			
		write-output "KO (Add file): $Reported_error"	
		EXIT 1		
	}
