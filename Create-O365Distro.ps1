$ver = '0.01'
<#
Created By: BTL - Kristopher Roy
Created On: 29APR22
Script Home: https://github.com/BellTechlogix/Create-O365Distro
#>

#Verify most recent version being used
$curver = $ver
$data = Invoke-RestMethod -Method Get -Uri https://raw.githubusercontent.com/BellTechlogix/GTIL-Onboarding-to-Groups/master/Onboarding-Groups.ps1
Invoke-Expression ($data.substring(0,13))
if($curver -ge $ver){powershell -Command "& {[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('You are running the most current script version $ver')}"}
ELSEIF($curver -lt $ver){powershell -Command "& {[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('You are running $curver the most current script version is $ver. Ending')}" 
EXIT}


IF(Get-Module -ListAvailable|where{$_.name -like "ExchangeOnlineManagement*"}){$EXO = $True}
Else{
    Install-Module -Name ExchangeOnlineManagement
	start-sleep -seconds 5
	IF(Get-Module -ListAvailable|where{$_.name -like "ExchangeOnlineManagement*"}){$EXO = $True}
    ELSE{
	    powershell -Command "& {[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('ExchangeOnlineManagement Module is missing and will not auto-install please resolve then re-run')}"
        Exit
	}
}

#Authenticate and add connect modules
try{Connect-ExchangeOnline}Catch{
    powershell -Command "& {[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('Exchange Module failed to load, trying again')}"
    Connect-ExchangeOnline
}