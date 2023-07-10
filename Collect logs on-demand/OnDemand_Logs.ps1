<#
# Author & creator: Damien VAN ROBAEYS
# Website: http://www.systanddeploy.com
# Twitter: https://twitter.com/syst_and_deploy
#>

# ***************************************************************************
# Part to fill
# ***************************************************************************

# SharePoint config
$Sharepoint_App_ID = ''
$Sharepoint_App_Secret = ''
$Sharepoint_Folder = ''
$Sharepoint_Site_URL = ''	

# XML content
$XML_OnBlob = $False
$XML_Logs_URL = ""

# ***************************************************************************
# Part to fill
# ***************************************************************************


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


If($XML_OnBlob -eq $True)
	{
		Try
			{
				$OutFile = "C:\Windows\Temp\Contentto_Collect.XML"
				Invoke-WebRequest -Uri $XML_Logs_URL -OutFile $OutFile -UseBasicParsing
				$ContenttoCollect_File_Path = "C:\Windows\Temp\Contentto_Collect.xml"				
				$XML_Downloaded = $True
				Write_Log -Message_Type "SUCCESS" -Message "Downloading XML"
			}
		Catch
			{
				Write_Log -Message_Type "ERROR" -Message "Downloading XML"																		
				EXIT 1
			}	
	}
Else
	{
$ContenttoCollect_File_Path = "C:\Windows\Temp\Contentto_Collect.xml"
$Contentto_Collect_XML = @"
<Content_to_collect>
	<Folders>
		<Folder_Path>C:\ProgramData\Microsoft\IntuneManagementExtension</Folder_Path>
		<Folder_Path>C:\Windows\debug</Folder_Path>	
		<Folder_Path>C:\ProgramData\GRTgaz\Debug</Folder_Path>			
		<Folder_Path>C:\Windows\Logs</Folder_Path>	
		<Folder_Path>C:\Windows\ccmsetup</Folder_Path>	
		<Folder_Path>C:\Windows\Panther</Folder_Path>	
		<Folder_Path>C:\Windows\Minidump</Folder_Path>	
		<Folder_Path>C:\Windows\SoftwareDistribution\ReportingEvents.log</Folder_Path>	
	</Folders>
	<Event_Logs>
		<Event_Log>
			<Event_Name>System</Event_Name>
			<Event_Path>System</Event_Path>			
		</Event_Log>
		
		<Event_Log>
			<Event_Name>Application</Event_Name>
			<Event_Path>Application</Event_Path>			
		</Event_Log>
		
		<Event_Log>
			<Event_Name>Umbrella Roaming Security Module</Event_Name>
			<Event_Path>Cisco AnyConnect Umbrella Roaming Security Module</Event_Path>			
		</Event_Log>

		<Event_Log>
			<Event_Name>Wired-AutoConfig</Event_Name>
			<Event_Path>Microsoft-Windows-Wired-AutoConfig/Operational</Event_Path>			
		</Event_Log>

		<Event_Log>
			<Event_Name>WLAN-AutoConfig</Event_Name>
			<Event_Path>Microsoft-Windows-WLAN-AutoConfig/Operational</Event_Path>			
		</Event_Log>
		
		<Event_Log>
			<Event_Name>DeviceManagement_Admin</Event_Name>
			<Event_Path>Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin</Event_Path>			
		</Event_Log>
		
		<Event_Log>
			<Event_Name>DeviceManagement_Operational</Event_Name>
			<Event_Path>Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Operational</Event_Path>			
		</Event_Log>
		
		<Event_Log>
			<Event_Name>AAD_Analytic</Event_Name>
			<Event_Path>Microsoft-Windows-AAD/Analytic</Event_Path>			
		</Event_Log>
		
		<Event_Log>
			<Event_Name>AAD_Operational</Event_Name>
			<Event_Path>Microsoft-Windows-AAD/Operational</Event_Path>			
		</Event_Log>
		
		<Event_Log>
			<Event_Name>assignedaccess_Operational</Event_Name>
			<Event_Path>Microsoft-Windows-assignedaccess/Operational</Event_Path>			
		</Event_Log>
		
		<Event_Log>
			<Event_Name>assignedaccess_Admin</Event_Name>
			<Event_Path>Microsoft-Windows-assignedaccess/Admin</Event_Path>			
		</Event_Log>
		
		<Event_Log>
			<Event_Name>assignedaccessbroker_Admin</Event_Name>
			<Event_Path>Microsoft-Windows-assignedaccessbroker/Admin</Event_Path>			
		</Event_Log>
		
		<Event_Log>
			<Event_Name>assignedaccessbroker_Operational</Event_Name>
			<Event_Path>Microsoft-Windows-assignedaccessbroker/Operational</Event_Path>			
		</Event_Log>
		
		<Event_Log>
			<Event_Name>provisioning_diagnostics</Event_Name>
			<Event_Path>Microsoft-Windows-provisioning-diagnostics-provider/Admin</Event_Path>			
		</Event_Log>
		
		<Event_Log>
			<Event_Name>Windows_shell_core</Event_Name>
			<Event_Path>Microsoft-Windows-shell-core/Operational</Event_Path>			
		</Event_Log>
		
		<Event_Log>
			<Event_Name>user_device_registration</Event_Name>
			<Event_Path>Microsoft-Windows-user device registration/Admin</Event_Path>			
		</Event_Log>
		
		<Event_Log>
			<Event_Name>ModernDeployment_Diag_Autopilot</Event_Name>
			<Event_Path>Microsoft-Windows-ModernDeployment-Diagnostics-Provider/Autopilot</Event_Path>			
		</Event_Log>
		
		<Event_Log>
			<Event_Name>ModernDeployment_Diag_Admin</Event_Name>
			<Event_Path>Microsoft-Windows-ModernDeployment-Diagnostics-Provider/Admin</Event_Path>			
		</Event_Log>
		
		<Event_Log>
			<Event_Name>ModernDeployment_Diag_ManagementService</Event_Name>
			<Event_Path>Microsoft-Windows-ModernDeployment-Diagnostics-Provider/ManagementService</Event_Path>			
		</Event_Log>
		
		<Event_Log>
			<Event_Name>AppxDeploymentServer</Event_Name>
			<Event_Path>Microsoft-Windows-AppxDeploymentServer/Operational</Event_Path>			
		</Event_Log>
	</Event_Logs>
	<Reg_Keys>
		<Reg_Key>
			<Reg_Path>HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run</Reg_Path>
			<Reg_Specific_Value></Reg_Specific_Value>			
		</Reg_Key>	
		<Reg_Key>
			<Reg_Path>HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion</Reg_Path>
			<Reg_Specific_Value>ReleaseId</Reg_Specific_Value>			
		</Reg_Key>				
	</Reg_Keys>	
</Content_to_collect>
"@
$Contentto_Collect_XML | out-file $ContenttoCollect_File_Path	
	}

$CompName = $env:computername
$Get_Day_Date = Get-Date -Format "dd-MM-yyyy"
$Log_File = "C:\Windows\Debug\Collect_Device_Content_$CompName" + "_$Get_Day_Date.log"
$Logs_Collect_Folder = "C:\Windows\Temp\Logs_" + "$CompName" + "_$Get_Day_Date"
$Logs_Collect_Folder_ZIP = "$Logs_Collect_Folder" + ".zip"
$EVTX_files = "$Logs_Collect_Folder\EVTX_Files"
$Logs_Folder = "$Logs_Collect_Folder\All_logs"
$Device_Infos = "$Logs_Collect_Folder\Device info"
$Reg_Export = "$Device_Infos\Export_Reg_Values.csv"

$Content_to_collect_XML = [xml] (Get-Content $ContenttoCollect_File_Path)
If(test-path $Logs_Collect_Folder){remove-item $Logs_Collect_Folder -Recurse -Force}
new-item $Logs_Collect_Folder -type Directory -force | out-null
If(!(test-path $EVTX_files)){new-item $EVTX_files -type Directory -force | out-null}
If(!(test-path $Log_File)){new-item $Log_File -type file -force | out-null}
If(!(test-path $Logs_Folder)){new-item $Logs_Folder -type Directory -force | out-null}	
If(!(test-path $Device_Infos)){new-item $Device_Infos -type Directory -force | out-null}	
	
Function Export_Event_Logs
	{
		param(
		$Log_To_Export,	
		$Log_Output,
		$File_Name
		)	
		
		Write_Log -Message_Type "INFO" -Message "Collecting logs from: $Log_To_Export"
		Try
			{
				# Getting events from the last 15 days
				WEVTUtil export-log $Log_To_Export -ow:true /q:"*[System[TimeCreated[timediff(@SystemTime) <= 1296000000 ]]]" "$Log_Output\$File_Name.evtx" | out-null				
				Write_Log -Message_Type "SUCCESS" -Message "Event log $File_Name.evtx has been successfully exported"
			}
		Catch
			{
				Write_Log -Message_Type "ERROR" -Message "An issue occured while exporting event log $File_Name.evtx"
			}
	}	
	
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
$Events_To_Check = $Content_to_collect_XML.Content_to_collect.Event_Logs.Event_Log
ForEach($Event in $Events_To_Check)
	{
		$Event_Name = $Event.Event_Name
		$Event_Path = $Event.Event_Path	
		Export_Event_Logs -Log_To_Export $Event_Path -Log_Output $EVTX_files -File_Name $Event_Name		
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
$Reg_Keys_To_Check = $Content_to_collect_XML.Content_to_collect.Reg_Keys.Reg_Key
ForEach($Reg in $Reg_Keys_To_Check)
	{
		$Get_Reg_Path = $Reg.Reg_Path
		$Get_Reg_Specific_Value = $Reg.Reg_Specific_Value	
		If($Get_Reg_Specific_Value -ne $null)
			{
				Export_Registry_Values -Reg_Path $Get_Reg_Path -Reg_Specific_Value $Get_Reg_Specific_Value -Output_Path $Reg_Export			
			}
		Else
			{
				Export_Registry_Values -Reg_Path $Get_Reg_Path -Output_Path $Reg_Export					
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

ipconfig | out-file "$Device_Infos\IP.txt"

$Cert_machine_CSV = "$Device_Infos\Certificate_Device.csv"
gci Cert:\LocalMachine -recurse | select Subject, Issuer, Thumbprint, NotBefore, NotAfter | export-CSV $Cert_machine_CSV -delimiter ";" -notypeinformation	

$Cert_Users_CSV = "$Device_Infos\Certificate_User.csv"
gci Cert:\CurrentUser -recurse | select Subject, Issuer, Thumbprint, NotBefore, NotAfter | export-CSV $Cert_Users_CSV -delimiter ";" -notypeinformation		
	
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

$Is_Nuget_Installed = $False     
$Sharepoint_Connected = $False	

If(!(Get-PackageProvider | where {$_.Name -eq "Nuget"}))
	{                                         
		Try
			{
				[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
				Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Scope currentuser -Force -Confirm:$False | out-null                                                                                                                 
				$Is_Nuget_Installed = $True 
				Write_Log -Message_Type "INFO" -Message "Package Nuget installed"				
			}
		Catch
			{
				$Is_Nuget_Installed = $False  
				Write_Log -Message_Type "INFO" -Message "Package Nuget installed"								
			}
	}
Else
	{
		$Is_Nuget_Installed = $True      
	}


If($Is_Nuget_Installed -eq $True)
	{
		Try
			{
				Install-Module -Name "PnP.PowerShell" -RequiredVersion 1.12.0 -Force -AllowClobber
				Import-Module pnp.powershell -RequiredVersion 1.12.0
				$PnP_Module_Status = $True	  
				Write_Log -Message_Type "SUCCESS" -Message "Module PnP imported"					
			}
		Catch
			{
				$PnP_Module_Status = $False	  
				Write_Log -Message_Type "ERROR" -Message "Module PnP imported"			
			}                                                   
	}

If($PnP_Module_Status -eq $True)
	{ 
		Try
			{
				Connect-PnPOnline -Url $Sharepoint_Site_URL -ClientID $Sharepoint_App_ID -ClientSecret $Sharepoint_App_Secret -WarningAction Ignore
				$Sharepoint_Connected = $True
				Write_Log -Message_Type "SUCCESS" -Message "SharePoint authentication"
			}
		Catch
			{
				$Sharepoint_Connected = $False	
				Write_Log -Message_Type "ERROR" -Message "SharePoint authentication"
			}	 
	
		If($Sharepoint_Connected -eq $True)
			{
				Write_Log -Message_Type "INFO" -Message "Uploading file"
				Write_Log -Message_Type "INFO" -Message "File to upload: $Logs_Collect_Folder_ZIP"

				Try
					{
						Add-PnPFile -Path $Logs_Collect_Folder_ZIP -Folder $Sharepoint_Folder #| out-null
						Write_Log -Message_Type "SUCCESS" -Message "Upload du fichier"		
						$Upload_Status = $True						
					}
				Catch
					{
						Write_Log -Message_Type "ERROR" -Message "Uploading file"
						$Last_Error = $error[0]
						Write_Log -Message_Type "ERROR" -Message "$Last_Error"						
						$Upload_Status = $False												
					}
				Disconnect-PnPOnline
			}	
	}

# remove-item $Logs_Collect_Folder -Force -Recurse
remove-item $Logs_Collect_Folder_ZIP -Force	
