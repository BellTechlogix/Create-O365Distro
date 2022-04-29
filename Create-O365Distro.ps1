$ver = '1'
<#
Created By: BTL - Kristopher Roy
Created On: 29APR22
Script Home: https://github.com/BellTechlogix/Create-O365Distro
#>

#Verify most recent version being used
$curver = $ver
$data = Invoke-RestMethod -Method Get -Uri https://raw.githubusercontent.com/BellTechlogix/Create-O365Distro/master/Create-O365Distro.ps1
Invoke-Expression ($data.substring(0,13))
if($curver -ge $ver){powershell -Command "& {[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('You are running the most current script version $ver')}"}
ELSEIF($curver -lt $ver){powershell -Command "& {[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('You are running $curver the most current script version is $ver. Ending')}" 
EXIT}

#check for EchangeOnline module and attempt to install if missing
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

#Variables
$importedList = import-csv C:\projects\BTL\DistroGroups.csv
foreach($dl in $importedList){}

foreach($dl in $importedList)
{
    $Managedby = $dl.ManagedByAddresses.Split(',')|where{$_}
    $Members = $dl.Members.Split(',')|where{$_}
	$addresses = ($dl.SmtpAddresses+','+$dl.x500).split(',')|where{$_}
	if($dl.RequireSenderAuthenticationEnabled -eq 'False'){$reqauth = 0}ELSEIF($dl.RequireSenderAuthenticationEnabled -eq 'True'){$reqauth = 1}
    If ($dl.GroupType -eq 'Universal' -or $dl.GroupType -eq 'Global')
    {
        New-DistributionGroup -Name $dl.DisplayName -DisplayName $dl.DisplayName -Alias $dl.Alias -ManagedBy $Managedby -Members $Members -MemberDepartRestriction Closed -MemberJoinRestriction ApprovalRequired -PrimarySmtpAddress $dl.PrimarySmtpAddress -RequireSenderAuthenticationEnabled $reqauth
    }
    If ($dl.GroupType -eq 'Universal, SecurityEnabled' -or $dl.GroupType -eq 'Global, SecurityEnabled')
    {
        New-DistributionGroup -Name $dl.DisplayName -DisplayName $dl.DisplayName -Alias $dl.Alias -ManagedBy $Managedby -Members $Members -MemberDepartRestriction Closed -MemberJoinRestriction ApprovalRequired -PrimarySmtpAddress $dl.PrimarySmtpAddress -RequireSenderAuthenticationEnabled $reqauth -Type "Security"
    }
    Set-DistributionGroup $dl.DisplayName -emailaddresses @{Add=$addresses}
}
