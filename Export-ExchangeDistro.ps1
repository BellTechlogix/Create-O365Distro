$date = get-date -Format "yyy-MM-dd"
$timestamp = get-date -Format "yyyy-MM-dd (%H:mm:ss)"
$folder = "c:\Reports"
#mail recipients for sending report
$recipients = @("Kristopher <kroy@belltechlogix.com>","Jack <hchen@belltechlogix.com>","Tim <TWheeler@belltechlogix.com>","Chris <CAvery@belltechlogix.com>")


#from address
$from = "Reports@belltechlogix.com"

#smtpserver
$smtp = "smtp.belltechlogix.com"

Add-PSsnapin Microsoft.Exchange.Management.PowerShell.E2010
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$DLs = get-DistributionGroup|select DisplayName,SamAccountName,GroupType,Alias,@{n='SmtpAddresses';e={ $_.EmailAddresses.SmtpAddress -join "," }},@{n='X500';e={"x500:"+$_.LegacyExchangeDN}},WindowsEmailAddress,PrimarySmtpAddress,@{n='ManagedByGUIds';e={$_.ManagedBy.objectguid  -join ","}},ManagedByAddresses,Members,IsDirSynced
FOREACH($DL in $DLs)
{
    $DL.Members = (Get-DistributionGroupMember $DL.DisplayName|select @{n='SmtpAddresses';e={ $_.PrimarySMTPAddress}}).SmtpAddresses  -join ","
    If($DL.ManagedByGUIds -ne $NULL -and $DL.ManagedByGUIds -ne "" -and $DL.ManagedByGUIds -ne " ")
    {
        $GUIDs = $DL.ManagedbyGUIds.split(",")
        $count = 0
        FOREACH($GUID in $GUIds)
        {
            IF((get-recipient -Identity $GUID).primarysmtpaddress.address -NE $NULL)
            {
                $count++
                IF($count -eq 1)
                {
                    $DL.ManagedByAddresses += (get-recipient -Identity $GUID).primarysmtpaddress.address
                }
                IF($count -gt 1)
                {
                    $DL.ManagedByAddresses += ","+(get-recipient -Identity $GUID).primarysmtpaddress.address
                }
            }
        }
    }
}

$DLs|export-csv $folder\DistroGroups.csv -NoTypeInformation
Send-MailMessage -from $from -to $recipients -subject "BTL - Distro Export" -smtpserver $smtp -Attachments $folder\DistroGroups.csv