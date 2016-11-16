Add-PSSnapin Veeam*

$Jobs = Get-VBRJob
$ResultsData = @()

foreach ($Job in $Jobs) { 

    $LastSession = $Job.FindLastSession()
    
    $JobName = $Job.Name
    $LastResult = $Job.GetLastResult()
    $Type = $Job.JobType
    $StartTime = $LastSession.CreationTime
    $FinishTime = $LastSession.EndTime
    $Duration = '{0:00}:{1:00}:{2:00}' -f (New-TimeSpan -Start $StartTime -End $FinishTime | % {$_.Hours,$_.Minutes,$_.Seconds})
    $Message = $LastSession.GetDetails()

    $obj = New-Object PSobject
	$obj | Add-Member -MemberType NoteProperty -name "Job Name" -value $JobName
	$obj | Add-Member -MemberType NoteProperty -name Type -value $Type
	$obj | Add-Member -MemberType NoteProperty -name "Last Result" -value $LastResult
	$obj | Add-Member -MemberType NoteProperty -name Start -value $StartTime
	$obj | Add-Member -MemberType NoteProperty -name Finish -value $FinishTime
	$obj | Add-Member -MemberType NoteProperty -name Duration -value $Duration
	$obj | Add-Member -MemberType NoteProperty -name Message -value $Message
	$ResultsData += $obj

}

$ResultsData = $ResultsData | sort -Property "Job Name"

$EmailHTML = @"
<style type="text/css">

            table {
                border-collapse: collapse;
                font-family: verdana,tahoma,arial;
                font-size: 12px;
                text-align: left;
            }

            th {
                background-color: #0099FF;
                padding-left: 10px;
                padding-right: 10px;
                padding-top: 5px;
                padding-bottom: 5px;
                border-color: #000000;
                border-style: solid;
                border-width: 1px;
            }

            td {
                padding: 5px;
                border-color: #000000;
                border-style: solid;
                border-width: 1px;
            }
</style>
"@

$ResultsHTML = $ResultsData | ConvertTo-Html -Head $EmailHTML
$ResultsHTML = $ResultsHTML -replace (">Success"," style='background-color:#00AA00'>Success")
$ResultsHTML = $ResultsHTML -replace (">Failed"," style='background-color:red'>Failed")
$ResultsHTML = $ResultsHTML -replace (">Warning"," style='background-color:orange'>Warning")

$Date = Get-Date -format "dd-MM-yyy"
$emailTo = "sysadmin@contoso.com"
$emailSubject = "Backups Report - $Date"
$emailFrom = "veeam@contoso.com"
$emailServer = "mail.contoso.com"

Send-MailMessage -To $emailTo -From $emailFrom -Subject $emailSubject -SmtpServer $emailServer -Body "$ResultsHTML" -BodyAsHtml