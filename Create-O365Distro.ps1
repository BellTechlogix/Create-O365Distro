$ver = '0.01'
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
$importedList = import-csv c:\projects\BTL\exported-dls.csv

foreach($dl in $importedList)
{
    If ($dl.GroupType -eq 'Universal' -or $dl.GroupType -eq 'Global')
    {
        $Name = $dl.DisplayName
        $Managedby = $dl.ManagedByAddresses
        $Members = $dl.
        New-DistributionGroup -Name $Name -DisplayName $Name -ManagedBy $Managedby -Members Kristopher.roy@belltechlogix.com,hchen@belltechlogix.com -MemberDepartRestriction Closed -MemberJoinRestriction ApprovalRequired -PrimarySmtpAddress "Testing-scripted-create-dl@belltechlogix.com" -RequireSenderAuthenticationEnabled $false
    }
    If ($dl.GroupType -eq 'Universal, SecurityEnabled' -or $dl.GroupType -eq 'Global, SecurityEnabled')
    {
        $dl.DisplayName
    }
}

$name1 = "Testing-scripted-create-sec"
New-DistributionGroup -Name $name1 -DisplayName $name1 -ManagedBy Kristopher.roy@belltechlogix.com,hchen@belltechlogix.com -Members Kristopher.roy@belltechlogix.com,hchen@belltechlogix.com -MemberDepartRestriction Closed -MemberJoinRestriction ApprovalRequired -PrimarySmtpAddress "$name1@belltechlogix.com" -Type "Security" -RequireSenderAuthenticationEnabled $false
Set-DistributionGroup $name1 -emailaddresses @{Add=’securitygrouptest@belltechlogix.com’,’x500:/O=Bellind/OU=GMA_CCI/cn=Recipients/cn=secgrouptest-SendAs’}
