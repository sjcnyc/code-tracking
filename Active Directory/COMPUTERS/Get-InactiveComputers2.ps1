#Requires -Version 3.0 
<# 
    .SYNOPSIS

    .DESCRIPTION
 
    .NOTES 
        File Name  : 
        Author     : Sean Connealy
        Requires   : PowerShell Version 3.0 
        Date       : 6/26/2015

    .LINK 
        This script posted to: http://www.github/sjcnyc

    .EXAMPLE

#>

Begin {
  #initalize 
  Write-Verbose 'Initializing'
}
Process {
   Write-Verbose "=====> Processing $ComputerName <====="

    $htmlreport  = @()
    $htmlbody    = @()
    $Days        = 90
    $smtp        = 'ussmtp01.bmg.bagint.com'
    $from        = 'poshalerts@sonymusic.com'   
    $to          = 'sean.connealy@sonymusic.com'
    $subject     = 'Inavtive Computer Report'
    $spacer      = '<br />'

     #---------------------------------------------------------------------
     # Collect computer system information and convert to HTML fragment
     #---------------------------------------------------------------------
    
     Write-Verbose 'Collecting Inactive Computers'

     #$subhead = '<h3>Inactive Computer Report.</h3>'
     #$htmlbody += $subhead
    
     try {

     $QADParams =@{
        sizelimit = '0'
        pagesize = '2000'
        dontusedefaultincludedproperties = $true
        includedproperties = @('ComputerName', 'LastLogonTimeStamp', 'OSName', 'ParentContainer')
        searchroot = @('bmg.bagint.com/USA/GBL/WST/Windows7','bmg.bagint.com/USA/GBL/WST/XP')
      }

      $Comps=Get-QADComputer @QADParams | 
        Where-Object { $_.LastLogonTimeStamp -ne $Null -and ($Currentdate-$_.LastLogonTimeStamp).Days -gt $Days -and $_.parentcontainer -notlike '*Exclude*' } |
        Select-Object computername, osname, lastlogontimestamp, parentcontainer -ErrorAction 0

      $compinfocomplete=@()
      foreach ($comp in $comps) {
        $compinfo = [pscustomobject]@{
          'Computer'  = $comp.computername.Replace('$', '')
          'LastLogon' = $comp.lastlogontimestamp
          'OS'        = $comp.osname
          'Source OU' = $comp.parentcontainer.Replace('bmg.bagint.com', '')
          'target OU' = '/NYCtest/TST/WST/Disabled'
        }

        $compinfocomplete += $compinfo
        }
        $htmlbody += $compinfocomplete | ConvertTo-Html -Fragment
        $htmlbody += $spacer

      Write-Verbose "Disabling: $($comp.computername)"
      Write-Verbose "Moving: $($comp.computername)" 
  
      }catch {
        Write-Warning $_.Exception.Message
        $htmlbody += "<p>An error was encountered. $($_.Exception.Message)</p>"
        $htmlbody += $spacer
      }
        #---------------------------------------------------------------------
        # Generate the HTML report and output to file
        #---------------------------------------------------------------------
	
        Write-Verbose 'Producing HTML report'
    
        $reportime = Get-Date -format 'M/d/yyy h:mm tt'

        #Common HTML head and styles
      $htmlhead="
            <html>
            <style>
            BODY{font-family: Arial; font-size: 8pt;}
            H1{font-size: 28px;}
            H2{font-size: 18px;}
            H3{font-size: 10px;}
            TABLE{border: 1px solid black; border-collapse: collapse; font-size: 8pt;}
            TH{border: 1px solid black; background: #dddddd; padding: 5px; color: #000000;}
            TD{border: 1px solid black; padding: 5px; }
            tr:nth-child(odd) { background-color:#d3d3d3;} 
            tr:nth-child(even) { background-color:white;}
            td.pass{background: #7FFF00;}
            td.warn{background: #FFE600;}
            td.fail{background: #FF0000; color: #ffffff;}
            td.info{background: #85D4FF;}
            </style>
            <body>
            <h1>Inactive Computer Report</h1>
            <h3>($($comps.Count)) Computer(s) moved from $($comp.parentcontainer.Replace('bmg.bagint.com', '')) OU</h3>
            <h3>Generated: $reportime</h3>
            <br>"            

        $htmltail = '</body>
          </html>'

          $htmlreport = $htmlhead + $htmlbody + $htmltail

          $emailParams =@{
              to = $to  
              from = $from
              subject = $subject
              smtpserver = $smtp
              body = ($htmlreport | Out-String)
              bodyashtml = $true
            }
       Send-MailMessage @emailParams
    }
  
  End
  {
    #Wrap it up
    Write-Verbose '=====> Finished <====='
  }