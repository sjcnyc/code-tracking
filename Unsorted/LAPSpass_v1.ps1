<#
.Synopsis
    A standalone Powershell GUI that can be used to retrieve a LAPS set Password for a Computer Account. No need to 
    install LAPS Password powershell extensions, or LAPS UI, or AD Powershell extensions.
.DESCRIPTION
    Use this script to get the (Administrator) password set for a Computer Account by LAPS. The script queries AD using 
    the Logged on User, or provided Credentials, for the LAPS Password set for a Computer. 
    https://technet.microsoft.com/en-us/library/security/3062591.aspx
    The GUI uses the font Consolas, making the displayed password more legible, and easier to distinguish between 
    similar characters.
    The Computer Account FQDN is used making it possible to query multiple domains. 
.EXAMPLE
    Run the GUI, retrieve the password using logged on rights, or by specifying different rights.    
.INPUTS

.OUTPUTS

.NOTES
    - You might need to change the font size for '$AdmPasswordOutput.Font' depending on how long your passwords are.
    - You can create a standalone .exe using ps2exe (https://ps2exe.codeplex.com/) or similar.  
      e.g.: .\ps2exe.ps1 -InputFile ".\LAPSpass_v1.ps1" -OutputFile ".\LAPSpass.exe" -noconsole -x86 -sta
    - The Script does not require that the LAPS or AD Powershell extensions be installed.
    - When converted to an .exe SEP heuristics finds this script suspicious so you may need to whitelist it.
.FUNCTIONALITY
    Retrieve a LAPS set password for a Computer Account you have permissions to view.
.Author
    Dalker 07/03/2016
#>

# ============================================================================================================
# ==== Variables =============================================================================================
# ============================================================================================================

# App Name.
$AppNAME = "LAPSpass"

# Set the default FQDN (so that users do not need to append this).
$DefaultComputerFQDN = ".contoso.com"

# Version.
$Ver = "1.0"

# Admin Account Name (if not default).
$AdminAccount = "Administrator"

# ============================================================================================================
# ==== Create GUI ============================================================================================
# ============================================================================================================

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

#==< GUI >=======================================================================
$GUI = New-Object System.Windows.Forms.Form
$GUI.ClientSize = New-Object System.Drawing.Size(278, 294)
$GUI.FormBorderStyle = 'Fixed3D'
$GUI.MaximizeBox = $false
$GUI.Text = "$AppNAME - v$Ver"
#==< ADAccountGroupBox >=========================================================
$ADAccountGroupBox = New-Object System.Windows.Forms.GroupBox
$ADAccountGroupBox.Font = New-Object System.Drawing.Font("Tahoma", 8.25, [System.Drawing.FontStyle]::Regular, `
                          [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$ADAccountGroupBox.Location = New-Object System.Drawing.Point(12, 2)
$ADAccountGroupBox.Size = New-Object System.Drawing.Size(250, 74)
$ADAccountGroupBox.TabStop = $false
$ADAccountGroupBox.Text = "AD Account"
#==< UsernameTxt >===============================================================
$UsernameTxt = New-Object System.Windows.Forms.Label
$UsernameTxt.Font = New-Object System.Drawing.Font("Tahoma", 8, [System.Drawing.FontStyle]::Regular, `
                    [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$UsernameTxt.Location = New-Object System.Drawing.Point(19, 20)
$UsernameTxt.Size = New-Object System.Drawing.Size(90, 20)
$UsernameTxt.Text = "Username:"
#==< PasswordTxt >===============================================================
$PasswordTxt = New-Object System.Windows.Forms.Label
$PasswordTxt.Font = New-Object System.Drawing.Font("Tahoma", 8, [System.Drawing.FontStyle]::Regular, `
                    [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$PasswordTxt.Location = New-Object System.Drawing.Point(140, 20)
$PasswordTxt.Size = New-Object System.Drawing.Size(90, 20)
$PasswordTxt.Text = "Password:"
#==< UsernameInput >=============================================================
$UsernameInput = New-Object System.Windows.Forms.TextBox
$UsernameInput.Font = New-Object System.Drawing.Font("Tahoma", 9, [System.Drawing.FontStyle]::Regular, `
                      [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$UsernameInput.Location = New-Object System.Drawing.Point(19, 40)
$UsernameInput.Size = New-Object System.Drawing.Size(115, 20)
$UsernameInput.TabIndex = 0
$UsernameInput.Text = ""
#==< PasswordInput >=============================================================
$PasswordInput = New-Object System.Windows.Forms.MaskedTextBox
$PasswordInput.Font = New-Object System.Drawing.Font("Tahoma", 9, [System.Drawing.FontStyle]::Regular, `
                      [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$PasswordInput.Location = New-Object System.Drawing.Point(140, 40)
$PasswordInput.Size = New-Object System.Drawing.Size(115, 20)
$PasswordInput.TabIndex = 1
$PasswordInput.PasswordChar = '*'
#==< ComputernameTxt >===========================================================
$ComputernameTxt = New-Object System.Windows.Forms.Label
$ComputernameTxt.Font = New-Object System.Drawing.Font("Tahoma", 8, [System.Drawing.FontStyle]::Regular, `
                        [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$ComputernameTxt.Location = New-Object System.Drawing.Point(6, 83)
$ComputernameTxt.Size = New-Object System.Drawing.Size(200, 20)
$ComputernameTxt.Text = "Computer Name:"
#==< ComputerNameInput >=========================================================
$ComputerNameInput = New-Object System.Windows.Forms.TextBox
$ComputerNameInput.Font = New-Object System.Drawing.Font("Tahoma", 8.25, [System.Drawing.FontStyle]::Regular, `
                          [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$ComputerNameInput.Location = New-Object System.Drawing.Point(8, 106)
$ComputerNameInput.Size = New-Object System.Drawing.Size(200, 21)
$ComputerNameInput.TabIndex = 2
$ComputerNameInput.Text = $DefaultComputerFQDN
$ComputerNameInput.Focus()
#==< ComputerNameInputToolTip >=======================================================
$ComputerNameInputToolTip = New-Object System.Windows.Forms.ToolTip
$ComputerNameInputToolTip.InitialDelay = 300
$ComputerNameInputToolTip.SetToolTip($ComputerNameInput, "Computer Name must be a Fully Qualified Domain Name `n(FQDN) e.g. pc1$DefaultComputerFQDN")
#==< SearchButton >==============================================================
$SearchButton = New-Object System.Windows.Forms.Button
$SearchButton.Font = New-Object System.Drawing.Font("Tahoma", 9, [System.Drawing.FontStyle]::Regular, `
                     [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$SearchButton.Location = New-Object System.Drawing.Point(215, 106)
$SearchButton.Size = New-Object System.Drawing.Size(57, 21)
$SearchButton.TabIndex = 3
$SearchButton.Text = "Search"
$SearchButton.UseVisualStyleBackColor = $true
$SearchButton.Add_Click({ 
	SearchButtonClick
	;})
#==< SearchButtonToolTip >=======================================================
$SearchButtonToolTip = New-Object System.Windows.Forms.ToolTip
$SearchButtonToolTip.InitialDelay = 300
$SearchButtonToolTip.SetToolTip($SearchButton, "Search for the $AdminAccount Password for a Computer.")
#==< AdmPasswordTxt >============================================================
$AdmPasswordTxt = New-Object System.Windows.Forms.Label
$AdmPasswordTxt.Font = New-Object System.Drawing.Font("Tahoma", 9, [System.Drawing.FontStyle]::Regular, `
                       [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$AdmPasswordTxt.Location = New-Object System.Drawing.Point(12, 140)
$AdmPasswordTxt.Size = New-Object System.Drawing.Size(185, 20)
$AdmPasswordTxt.Text = "$AdminAccount Password:"
#==< AdmPasswordOutput >=========================================================
$AdmPasswordOutput = New-Object System.Windows.Forms.TextBox
$AdmPasswordOutput.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$AdmPasswordOutput.Font = New-Object System.Drawing.Font("Consolas", 18, [System.Drawing.FontStyle]::Regular, `
                          [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$AdmPasswordOutput.Location = New-Object System.Drawing.Point(14, 160)
$AdmPasswordOutput.Size = New-Object System.Drawing.Size(248, 29)
$AdmPasswordOutput.Text = ""
$AdmPasswordOutput.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center
$AdmPasswordOutput.ForeColor = "White"
$AdmPasswordOutput.BackColor = [System.Drawing.SystemColors]::Menu
$AdmPasswordOutput.TabStop = $false
$AdmPasswordOutput.ReadOnly = $True
#==< PasswordExpiresTxt >========================================================
$PasswordExpiresTxt = New-Object System.Windows.Forms.Label
$PasswordExpiresTxt.Font = New-Object System.Drawing.Font("Tahoma", 9, [System.Drawing.FontStyle]::Regular, `
                           [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$PasswordExpiresTxt.Location = New-Object System.Drawing.Point(53, 200)
$PasswordExpiresTxt.Size = New-Object System.Drawing.Size(104, 20)
$PasswordExpiresTxt.Text = "Password Expires:"
#==< PasswordExpiresOutput >=====================================================
$PasswordExpiresOutput = New-Object System.Windows.Forms.Label
$PasswordExpiresOutput.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$PasswordExpiresOutput.Font = New-Object System.Drawing.Font("Tahoma", 9.75, [System.Drawing.FontStyle]::Regular, `
                              [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$PasswordExpiresOutput.Location = New-Object System.Drawing.Point(54, 220)
$PasswordExpiresOutput.Size = New-Object System.Drawing.Size(168, 18)
$PasswordExpiresOutput.Text = ""
$PasswordExpiresOutput.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$PasswordExpiresOutput.BackColor = [System.Drawing.SystemColors]::Menu
#==< StatusGroupBox >============================================================
$StatusGroupBox = New-Object System.Windows.Forms.GroupBox
$StatusGroupBox.Location = New-Object System.Drawing.Point(3, 245)
$StatusGroupBox.Size = New-Object System.Drawing.Size(272, 40)
$StatusGroupBox.TabStop = $True
$StatusGroupBox.Text = "Status"
#==< StatusBoxOutput >===========================================================
$StatusBoxOutput = New-Object System.Windows.Forms.Label
$StatusBoxOutput.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$StatusBoxOutput.Font = New-Object System.Drawing.Font("Tahoma", 8.25, [System.Drawing.FontStyle]::Regular, `
                        [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$StatusBoxOutput.Location = New-Object System.Drawing.Point(6, 262)
$StatusBoxOutput.Size = New-Object System.Drawing.Size(266, 14)
$StatusBoxOutput.Text = ""
$StatusBoxOutput.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$StatusBoxOutput.BackColor = [System.Drawing.SystemColors]::Menu
$StatusBoxOutput.ForeColor = "Black"
#==< Create GUI controls >=======================================================
$GUI.Controls.Add($UsernameTxt)
$GUI.Controls.Add($UsernameInput)
$GUI.Controls.Add($PasswordInput)
$GUI.Controls.Add($PasswordTxt)
$GUI.Controls.Add($ADAccountGroupBox)
$GUI.Controls.Add($ComputernameTxt)
$GUI.Controls.Add($ComputerNameInput)
$GUI.Controls.Add($SearchButton)
$GUI.Controls.Add($AdmPasswordTxt)
$GUI.Controls.Add($AdmPasswordOutput)
$GUI.Controls.Add($PasswordExpiresTxt)
$GUI.Controls.Add($PasswordExpiresOutput)
$GUI.Controls.Add($StatusBoxOutput)
$GUI.Controls.Add($StatusGroupBox)

# ============================================================================================================
# ==== Functions =============================================================================================
# ============================================================================================================

function Main { # Launch GUI.
	[System.Windows.Forms.Application]::EnableVisualStyles()
	[System.Windows.Forms.Application]::Run($GUI)
    } # <== Main

function SearchButtonClick($object) { # Search Button clicked.
    # Disable Search button
    $SearchButton.Enabled = $false # Disable Search button

	# Set some options
    $StatusBoxOutput.ForeColor = "Black"
    $AdmPasswordOutput.ForeColor = "Black"
    $AdmPasswordOutput.BackColor = [System.Drawing.SystemColors]::Menu
    $PasswordExpiresOutput.BackColor = [System.Drawing.SystemColors]::Menu
    $AdmPasswordOutput.Text = " "
    $PasswordExpiresOutput.Text = " "
    $StatusBoxOutput.Text = "Working ..."

    start-sleep -m 150 # Status Messages etc not cleared if we don't slow things down a bit

  	# Set some variables.
    $Domain = $NULL
    $AdmPass = $NULL

	# Get Username and Password from GUI.
	$Username = $UsernameInput.Text
	$Password = $PasswordInput.Text
    $ComputerNameInput.Focus()
    
    # If the Username/Password is not empty.
    if ((![string]::IsNullOrEmpty($Username)) -or (![string]::IsNullOrEmpty($Password))) {
        # Username but no Password.
        if ((![string]::IsNullOrEmpty($Username)) -and ([string]::IsNullOrEmpty($Password))) {
            # Change Status Message.
            $AdmPasswordOutput.Text = "error"
            $PasswordExpiresOutput.Text = "n/a"
            $StatusBoxOutput.ForeColor = "Red"
            $StatusBoxOutput.Text = "Please Enter a Password!"
            $SearchButton.Enabled = $true # Enable Search button
            return
            }
        # Password but no Username.
        if (([string]::IsNullOrEmpty($Username)) -and (![string]::IsNullOrEmpty($Password))) {
            # Change Status Message.
            $AdmPasswordOutput.Text = "error"
            $PasswordExpiresOutput.Text = "n/a"
            $StatusBoxOutput.ForeColor = "Red"
            $StatusBoxOutput.Text = "Please Enter a Username!"
            $SearchButton.Enabled = $true # Enable Search button
            return
            }
        } 
    	
	# Get the Computer Name.
	$ComputerName = $ComputerNameInput.Text
    if (([string]::IsNullOrEmpty($ComputerName)) -Or ($ComputerName -eq $DefaultComputerFQDN)) { # Empty.
        # Change Status Message.
        $AdmPasswordOutput.Text = "error"
        $PasswordExpiresOutput.Text = "n/a"
        $StatusBoxOutput.ForeColor = "Red"
        $StatusBoxOutput.Text = "Enter a Computer Name!"
        $SearchButton.Enabled = $true # Enable Search button
        return
        }

    # Check if Computer Name is in FQDN format. (We want the FQDN so we can get the Domain Name.)
    if ($ComputerName -notlike "*.*") {
        # Change Status Message.
        $AdmPasswordOutput.Text = "error"
        $PasswordExpiresOutput.Text = "n/a"
        $StatusBoxOutput.ForeColor = "Red"
        $StatusBoxOutput.Text = "Name must be a FQDN e.g. pc1$DefaultComputerFQDN"
        $SearchButton.Enabled = $true # Enable Search button
        return
        }
               
    # Get the domain name from the Computer FQDN.
    $SplitComputerName = $ComputerName.Split(".") # Split the Computer name into it's parts   
    $Domain = $ComputerName.Replace($SplitComputerName[0] + ".","") # Remove the Computer Name, leaving Domain.
    $ComputerName = $SplitComputerName[0] # The part before the first "." is the Computer Name.

    # Create LDAP connection.
    if ([string]::IsNullOrEmpty($Username) -or [string]::IsNullOrEmpty($Password)) { # Check as logged on user.
            $LDAPDomain = New-Object System.DirectoryServices.DirectoryEntry "LDAP://$Domain"			
	    } else { # Check using provided credentials.
            $LDAPDomain = New-Object System.DirectoryServices.DirectoryEntry "LDAP://$Domain", $Username, $Password		
		}
    Try { # Find any issues connecting to the server.
            # We need to make sure that the connection is Encrypted.
            $LDAPDomain.AuthenticationType=$LDAPDomain.AuthenticationType -bor `
                                           [System.DirectoryServices.AuthenticationTypes]::Sealing
            $LDAPDomain.AuthenticationType=$LDAPDomain.AuthenticationType -bor `
                                           [System.DirectoryServices.AuthenticationTypes]::Secure
        } Catch {
            $ErrorMessage = $_.Exception.Message # Catch the error message.
			#write-host $ErrorMessage
        }
    
    # Error Message indicate Username/Password incorrect.
    if ($ErrorMessage -like "*username or password is incorrect*" -Or $ErrorMessage -like "*Logon failure*") {
        # Change Status Message.
        $AdmPasswordOutput.Text = "error"
        $PasswordExpiresOutput.Text = "n/a"
        $StatusBoxOutput.ForeColor = "Red"
        $StatusBoxOutput.Text = "Username/Password Incorrect!"
        $SearchButton.Enabled = $true # Enable Search button
        return
        }
    
    # Open LDAP query.
    $LDAPSearch = New-Object System.DirectoryServices.DirectorySearcher
    # Set filter. Search for the Computer.   
    $LDAPSearch.Filter = "(&(objectCategory=computer)(objectClass=computer)(cn=$ComputerName))" 
    $LDAPSearch.SearchScope = "Subtree"
    $ComputerDN = $LDAPSearch.FindOne().Properties.distinguishedname # Get the Computer Distinguished Name.

    if ([string]::IsNullOrEmpty($ComputerDN)) { # Check if its found nothing.
            # Change Status Message.
            $AdmPasswordOutput.Text = "n/a"
            $PasswordExpiresOutput.Text = "n/a"
            $StatusBoxOutput.ForeColor = "Red"
            $StatusBoxOutput.Text = "Computer Not Found in AD! Check the name ..."
            $SearchButton.Enabled = $true # Enable Search button
            return
        }

    $LDAPDomain.Path="LDAP://$ComputerDN"
    # Get the LAPS password for the computer account.
    $AdmPass = $LDAPDomain.Properties["ms-mcs-admpwd"]
    # Get the LAPS password expiry date for the computer account.
    $AdmPassExpire = $LDAPDomain.Properties["ms-Mcs-AdmPwdExpirationTime"]
    
    if (![string]::IsNullOrEmpty($AdmPassExpire)) { # If LAPS Password Expiry is not empty.
            # Convert to a readable date format.
            $AdmPassExpire = $LDAPDomain.ConvertLargeIntegerToInt64($LDAPDomain."ms-Mcs-AdmPwdExpirationTime"[0])
            $AdmPassExpire = [datetime]::FromFileTime($AdmPassExpire).ToString('G')
            $LAPSPassExpireExists = "True" 
        } else {
            $LAPSPassExpireExists = "False" # Empty.
        }
    
    if (![string]::IsNullOrEmpty($AdmPass)) { # If LAPS Password is not empty.
            $LAPSPassExists = "True" 
        } else { 
            $LAPSPassExists = "False" # Empty.            
        }
				
	if ($LAPSPassExists -eq "True") { # Display the password.
            $AdmPasswordOutput.BackColor = "DarkBlue"
            $AdmPasswordOutput.ForeColor = "White"
            $PasswordExpiresOutput.BackColor = "White"
			# Show Pass in GUI.
			$AdmPasswordOutput.Text = $AdmPass										
			# Show Date in GUI.
			$PasswordExpiresOutput.Text = $AdmPassExpire
            # Change Status Message.
            $StatusBoxOutput.Text = "LAPS Password retrieved successfully ..."
		} elseif ($LAPSPassExists -eq "False" -and $LAPSPassExpireExists -eq "False") {
            # LAPS password not set for this computer.
            $AdmPasswordOutput.Text = "not set"
            $PasswordExpiresOutput.Text = "n/a"
            # Change Status Message.
            $StatusBoxOutput.ForeColor = "Red"
            $StatusBoxOutput.Text = "LAPS Password Not Set for this Computer ..."
		} elseif ($LAPSPassExists -eq "False" -and $LAPSPassExpireExists -eq "True") {
            # LAPS passord exists but we cannot query it i.e. no rights to query.
            $AdmPasswordOutput.Text = "access denied"
            $PasswordExpiresOutput.Text = "n/a"
            # Change Status Message.
            $StatusBoxOutput.ForeColor = "Red"
            $StatusBoxOutput.Text = "Insufficient Rights to View this Password ..."
        }
    
    $SearchButton.Enabled = $true # Enable Search button
	} # <== SearchButtonClick
	
# ============================================================================================================
# ==== Script ================================================================================================
# ============================================================================================================

Main # Launch the GUI