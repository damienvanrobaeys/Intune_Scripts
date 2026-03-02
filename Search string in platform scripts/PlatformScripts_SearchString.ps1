param(
[Parameter(Mandatory=$true)][string]$Pattern,	
[switch]$All,		
[switch]$GridView,		
[switch]$PST
)

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
# Connect-MgGraph -Certificate $ClientCertificate -TenantId $TenantId -ClientId $ClientId  | out-null		

$Scripts_URL = "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts"
$Get_Scripts = (Invoke-MgGraphRequest -Uri $Scripts_URL  -Method GET).value
$Data_Array = @()
ForEach($Script in $Get_Scripts)
{
	$Script_Name = $Script.displayName
	$Script_Id = $Script.id
	$Script_FileName = $Script.fileName
	$Script_lastModifiedDateTime = $Script.lastModifiedDateTime
	$Script_createdDateTime = $Script.createdDateTime	

	$Script_info = "$Scripts_URL/$Script_Id"
	$Get_Script_info = (Invoke-MgGraphRequest -Uri $Script_info  -Method GET -SkipHttpErrorCheck) 	

	$ScriptContent = $Get_Script_info.scriptContent	
	If($ScriptContent -eq $null){
		$String_Found = "Empty"
	}Else{
		$Script_Decoded = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($ScriptContent))
		$Script_check = $Script_Decoded | Select-String "$Pattern"
		If($Script_check -ne $null)
		{
			$String_Found = "Yes"
		}Else{
			$String_Found = "No"
		}				
	}
			
	$Obj = [PSCustomObject]@{
		Name     				= $Script_Name
		ID     					= $Script_Id
		"With string"     		= $String_Found		
		FileName     			= $Script_FileName
		LastModifiedDateTime    = $Script_lastModifiedDateTime		
	}
	
	$Data_Array += $Obj
}	

If($All)
{
	$Results = $Data_Array
}Else{
	$Results = $Data_Array | where {$_."With string" -eq "Yes"}
}

If($GridView){$Results | Out-GridView}
If($PST){$Results | Export-Csv -Path "$env:temp\CVE-2025-54100_Script_Report.csv" -NoTypeInformation -Encoding UTF8;invoke-item $env:temp}
