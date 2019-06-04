Add-Type -AssemblyName System.Web
class ADUser {
	
    [String]$City;
    [String]$FullName;
    [String]$Company;
    [String]$Country;
    [String]$Department;
    [String]$Description;
    [String]$EmailAddress;
    [String]$EmployeeID;
    [Int]$EmployeeNumber;
    [Bool]$Enabled;
    [String]$Firstname;
    [String]$HomeDirectory;
    [String]$Manager;
    [Array]$MemberOf;
    [String]$OfficePhone;
    [String]$SamAccountName;
    [String]$LastName;
    [String]$Title;
    [String]$ObjectGuid;
	
	ADUser([String]$SAMAccountName)
	{
		$this._getADUser($SAMAccountName)
	}
	
	# Method: Get User Information
	hidden [void] _getADUser([String]$SAMAccountName)
	{
		$User = $NUll
		Try{
			$User = Get-ADUser $SAMAccountName -properties * -ErrorAction Stop
		}
		Catch{
			Throw "No ADUser matches that SAMAccountName"
		}
		
        [String]$this.City               = $User.city 
        [String]$this.FullName           = $User.cn
        [String]$this.Company            = $User.company
        [String]$this.Country            = $User.country
        [String]$this.Department         = $User.department
        [String]$this.Description        = $User.description
        [String]$this.EmailAddress       = $User.emailaddress
        [String]$this.EmployeeID         = $User.EmployeeID
        [String]$this.OfficePhone        = $User.OfficePhone
        [String]$this.SamAccountName     = $User.SamAccountName
        [String]$this.LastName           = $User.Surname
        [String]$this.Title              = $User.Title
        [String]$this.ObjectGuid         = $User.ObjectGuid
        [String]$this.Firstname          = $User.givenname
        [String]$this.HomeDirectory      = $User.HomeDirectory 
        [String]$this.Manager            = $User.Manager 
        [Int]$this.EmployeeNumber        = $User.EmployeeNumber
        [Bool]$this.Enabled              = $User.Enabled 
        [Array]$this.MemberOf            = $User.MemberOf

	}
	
	# Method: Enable ADUser
	[String] Enable([System.Management.Automation.PSCredential]$Credential)
	{
		Try
		{
			Enable-ADAccount -Identity $this.SAMAccountName -Credential $Credential -ErrorAction Stop
			Return $Null
		}
		Catch
		{
			Throw "Unable to Enable User : $($_.exception.message)"
		}
	}

	# Method: Disable ADUser
	[String] Disable([System.Management.Automation.PSCredential]$Credential)
	{
		Try
		{
			Disable-ADAccount -Identity $this.SAMAccountName -Credential $Credential -ErrorAction Stop
			Return $Null
		}
		Catch
		{
			Throw "Unable to Disable User : $($_.exception.message)"
		}
	}
	
	# Method: Set Password
	[String] SetPassword([String]$Password,[System.Management.Automation.PSCredential]$Credential)
	{
		Try
		{
			Set-ADAccountPassword -Identity $this.SAMAccountName -Credential $Credential -Reset -NewPassword $Password -ErrorAction Stop
			Return $Null
		}
		Catch
		{
			Throw "Unable to Set Password : $($_.exception.message)"
		}
	}
	
	# Method: Move OU
	[String] MoveOU([String]$NewOU,[System.Management.Automation.PSCredential]$Credential)
	{
		Try
		{
			Move-ADObject -TargetPath $NewOU -Identity $this.ObjectGuid -Credential $Credential -Confirm:$False -ErrorAction Stop
			Return $Null
		}
		Catch
		{
			Throw "Unable to Change OUs : $($_.exception.message)"
		}
	}
	
	# Method: Set Description
	[String] SetDescription([String]$Description,[System.Management.Automation.PSCredential]$Credential)
	{
		Try
		{
            Set-ADUser $this.SamAccountName -Description $Description -Credential $Credential -Confirm:$False -ErrorAction Stop
            Return $Null
		}
		Catch
		{
			Throw "Unable to set the description : $($_.exception.message)"
		}
	}
	
	# Method: Set Company
	[String] SetCompany([String]$Company,[System.Management.Automation.PSCredential]$Credential)
	{
		Try
		{
            Set-ADUser $this.SamAccountName -Company $Company -Credential $Credential -Confirm:$False -ErrorAction Stop
            Return $Null
		}
		Catch
		{
			Throw "Unable to set the company : $($_.exception.message)"
		}
	}
	
	# Method: Clear Account Expiration Date
	[String] ClearExpiration([System.Management.Automation.PSCredential]$Credential)
	{
		Try
		{
			Clear-ADAccountExpiration -Identity $this.SamAccountName -Credential $Credential -Confirm:$False -ErrorAction Stop
			Return $Null
		}
		Catch
		{
			Throw "Unable to clear expiration date : $($_.exception.message)"
		}
	}
	
	# Method: Add To AD Group
	[String] AddToGroup([String]$GroupName,[System.Management.Automation.PSCredential]$Credential)
	{
		Try
		{
			Add-ADGroupMember -Identity $GroupName -Members $this.SamAccountName -Confirm:$False -Credential $Credential -ErrorAction Stop
			Return $Null
		}
		Catch
		{
			Throw "Unable to add to specified group : $($_.exception.message)"
		}
	}
	
	# Method: Get Group Memberships
	[Array] GetGroupMemberships()
	{
		Try
		{
			$Memberships = Get-ADPrincipalGroupMembership $this.SamAccountName -ErrorAction Stop
			Return $Memberships
		}
		Catch
		{
			Throw "Unable to get group memberships : $($_.exception.message)"
		}
	}
	
	# Method: Remove From Groups
	[String] RemoveFromGroup([Array]$Groups,[System.Management.Automation.PSCredential]$Credential)
	{
        [Array]$RemovedGroups = @()
        [Array]$FailedGroups = @()
        ForEach($Group in $Groups){
		    Try
		    {
                $Splat = @{
                    'Identity'    = $Group
                    'Members'     = $this.SamAccountName
                    'Credential'  = $Credential
                    'ErrorAction' = 'Stop'
                }
                Remove-ADGroupMember @Splat -Confirm:$False
			    $RemovedGroups += $Group
		    }
		    Catch
		    {
			    $FailedGroups += $Group 
		    }
        }
        If(($FailedGroups | Measure-Object).count -eq 0){
            Return $Null
        }
        Else{
            Return $FailedGroups -join ','
        }
	}
}

#Create New AD User Object
Try{
    $User = [ADUser]::new('SAMACCOUNTNAME')
    Write-Host "User Object Created" -ForegroundColor Green
}
Catch{
    Write-Host $($_.exception.message) -ForegroundColor Red
}

#Disable User Account
Try{
    $User.Disable($ADMCredential)
    Write-Host "Disable AD User Account : SUCCESS" -ForegroundColor Green
}
Catch{
    Write-Host "Disable AD User Account : FAILURE" -ForegroundColor Red
}

#Reset User Password
Try{
    $NewPassword = ConvertTo-SecureString -String ([System.Web.Security.Membership]::GeneratePassword(16,6)) -AsPlainText -Force
    $User.SetPassword($NewPassword,$ADMCredential)
    Write-Host "Reset AD User Password : SUCCESS" -ForegroundColor Green 
}
Catch{
    Write-Host "Reset AD User Password : FAILURE" -ForegroundColor Red
}

#Move User OU
Try{
    $DisabledUserOU = 'OU=Disabled Accounts,DC=place,DC=contoso,DC=com'
    $User.MoveOU($DisabledUserOU,$ADMCredential)
    Write-Host "Move AD User To Disabled OU : SUCCESS" -ForegroundColor Green
}
Catch{
    Write-Host "Move AD User To Disabled OU                   : FAILURE" -ForegroundColor Red
}

#Set AD Description
Try{
    Write-host "Please Enter the 'leave date'" -ForegroundColor Yellow
    $Date = Read-Host
    $Description = "Left the Firm " + $Date + " reset pw " + "by $ENV:USERNAME"
    $User.SetDescription($Desription,$ADMCredential)
    Write-Host "Set AD User Description : SUCCESS" -ForegroundColor Green 
}
Catch{
    Write-Host "Set AD User Description                       : FAILURE" -ForegroundColor Red
}

#Set AD Company
Try{
    $User.SetCompany('No Longer With the Firm',$ADMCredential)
    Write-Host "Set AD User Company Field : SUCCESS" -ForegroundColor Green 
}
Catch{
    Write-Host "Set AD User Company Field                     : FAILURE" -ForegroundColor Red
}

#Clear AD Expiration
Try{
    $User.ClearExpiration($ADMCredential)
    Write-Host "Remove AD User Expiration Date : SUCCESS" -ForegroundColor Green 
}
Catch{
    Write-Host "Remove AD User Expiration Date : FAILURE" -ForegroundColor Red
}

#Add to Group
Try{
    $User.AddToGroup($Group,$ADMCredential)
    Write-Host "Add User to $GroupName Group  : SUCCESS" -ForegroundColor Green
}
Catch{
    If($_.exception.message -like '*The specified account name is already a member of the group*' -or $_.exception.message -like '*Either the specified user account is already a member of the specified group*')
    {
        Write-host "User is already a member of the $GroupName Group" -ForegroundColor Yellow
    }
    Else{
        Write-Host $_.exception.message
        Write-Host "Add User to $GroupName Group  : FAILURE" -ForegroundColor Red
    }
}

#Get Group Memberships
$Groups = $NULL
Try{
    $Groups = $User.GetGroupMemberships()
    Write-Host "Gather Group Memberships                      : SUCCESS" -ForegroundColor Green
}
Catch{
    Write-Host "Gather Group Memberships                      : FAILURE" -ForegroundColor Red
}

#Remove From Groups
Try{
    $User.RemoveFromGroup($Groups,$ADMCredential)
    Write-Host "Remove User from Unneeded Groups : SUCCESS" -ForegroundColor Green
}
Catch{
    $FailedGroups = $_.exception.message -split ','
    Foreach($Group in $FailedGroups){
        Write-Host "Failed to remove User from $Group" -ForegroundColor Red
    }
}