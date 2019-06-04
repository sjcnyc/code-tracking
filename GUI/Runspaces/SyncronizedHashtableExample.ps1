
    function OnApplicationLoad {    
        return $true #return true for success or false for failure
    }

    function OnApplicationExit {
        $script:ExitCode = 0 #Set the exit code for the Packager
    }

    function Call-Searching_pff {
        [void][reflection.assembly]::Load('mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
        [void][reflection.assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
        [void][reflection.assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
        [void][reflection.assembly]::Load('System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
        [void][reflection.assembly]::Load('System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
        [void][reflection.assembly]::Load('System.Xml, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
        [void][reflection.assembly]::Load('System.DirectoryServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
        [void][reflection.assembly]::Load('System.Core, Version=3.5.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
        [void][reflection.assembly]::Load('System.ServiceProcess, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')

        [System.Windows.Forms.Application]::EnableVisualStyles()
        $formSearchingFiles = New-Object 'System.Windows.Forms.Form'
        $label = New-Object 'System.Windows.Forms.Label'
        $progressbar = New-Object 'System.Windows.Forms.ProgressBar'
        $InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'

        $FormEvent_Load={


$syncHash = [hashtable]::Synchronized(@{})
#Where $syncHash is the name of your hash table
#Add Variables and Objects to the hash table:

$syncHash.ProgressBar = $progressBar
#$syncHash.ProgressBar.Value = 1
#Create new variable ProgressBar in hash table and assign $progressBar to it
#Create new thread and allow the use of the hash table:

$processRunspace =[runspacefactory]::CreateRunspace()
$processRunspace.ApartmentState = 'STA'
$processRunspace.ThreadOptions = 'ReuseThread'          
$processRunspace.Open()
$processRunspace.SessionStateProxy.SetVariable('syncHash',$syncHash)   

$psCmd = [PowerShell]::Create().AddScript({


})


$psCmd.Runspace = $processRunspace
$data = $psCmd.BeginInvoke()
 
#Change value of $progressBar from new thread:
#$syncHash.ProgressBar.Value = 0
   
        }

        $Form_StateCorrection_Load=
        {
            #Correct the initial state of the form to prevent the .Net maximized form issue
            $formSearchingFiles.WindowState = $InitialFormWindowState
        }

        $Form_Cleanup_FormClosed=
        {
            #Remove all event handlers from the controls
            try
            {
                $formSearchingFiles.remove_Load($FormEvent_Load)
                $formSearchingFiles.remove_Load($Form_StateCorrection_Load)
                $formSearchingFiles.remove_FormClosed($Form_Cleanup_FormClosed)
            }
            catch [Exception]{ }
        }

        # formSearchingFiles
        $formSearchingFiles.Controls.Add($label)
        $formSearchingFiles.Controls.Add($progressbar)
        $formSearchingFiles.ClientSize = '394, 122'
        $formSearchingFiles.FormBorderStyle = 'FixedDialog'
        $formSearchingFiles.MaximizeBox = $False
        $formSearchingFiles.Name = 'formSearchingFiles'
        $formSearchingFiles.StartPosition = 'CenterScreen'
        $formSearchingFiles.Text = 'Compatibility Checker'
        $formSearchingFiles.add_Load($FormEvent_Load)

        # label
        $label.Location = '12, 27'
        $label.Name = 'label'
        $label.Size = '368, 26'
        $label.TabIndex = 1
        $label.Text = 'Searching for files, please wait..'
        $label.TextAlign = 'MiddleCenter'

        # progressbar
        $progressbar.Location = '12, 68'
        $progressbar.MarqueeAnimationSpeed = 40
        $progressbar.Name = 'progressbar'
        $progressbar.Size = '370, 30'
        $progressbar.Style = 'Marquee'
        $progressbar.TabIndex = 0

        #Save the initial state of the form
        $InitialFormWindowState = $formSearchingFiles.WindowState
        #Init the OnLoad event to correct the initial state of the form
        $formSearchingFiles.add_Load($Form_StateCorrection_Load)
        #Clean up the control events
        $formSearchingFiles.add_FormClosed($Form_Cleanup_FormClosed)
        #Show the Form
        return $formSearchingFiles.ShowDialog()
    } #End Function

    #Call OnApplicationLoad to initialize
    if((OnApplicationLoad) -eq $true)
    {
        #Call the form
        Call-Searching_pff | Out-Null
        #Perform cleanup
        OnApplicationExit
    }
