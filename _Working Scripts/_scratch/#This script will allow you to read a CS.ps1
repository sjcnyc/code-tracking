#This script will allow you to read a CSV file and modify all attributes in an AD account using the LDAP attribute name only.
# 1. The Manager field can only be the DN
# 2. This will overwrite information with null values if the cell is blank
# 3. The CSV file allows for LDAP parameters only (streetaddress,l,st,postalcode,c)
# 4. The employeeNumber field was used as the Primary Key for each employee

#Special Thanks to cduff who did most of the work and took the time to educate.

# Import AD Module
Import-Module ActiveDirectory

Write-Host 'Modifying AD Accounts.......' -NoNewline -ForegroundColor Red

# Import CSV into variable $users
$users = Import-Csv -Path C:\bin\UpdateADUsers.csv

#This Loop goes through each line in the CSV file
ForEach ($user in $users) {
  #Create an empty hash table to store non-blank values
  $replace = @{ }
  #Create an empty array to store blank values
  $clear = @()

  #This stores all headers in the $property variable
  ForEach ($property in ($user | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)) {
    #Trim() removes the leading and trailing blank spaces because an invisible space
    #will cause a false positive.  If there is a value for that field in the CSV file
    #add it to $options.  If the cell is blank then add the property value to $clear
    ## -->  check this $property.Remove("SamAccountName")
    If ($user."$property".Trim()) {
      #Specifies how the data is stored in the hash (cell header / cell data) ie. (st / Nevada or City / Las Vegas)
      $replace[$property] = $user."$property".Trim()
    }
    #This stores all blank cell headers in the $clear array
    Else {
      $clear += $property
    }
  }
  #Create an empty hash table to store the values of fields that are being replaced
  $options = @{ }
  #Sets the options variable to the headers of the cells that have values
  $options['Replace'] = $replace


  If ($clear) {
    #This stores all blank cell headers in the $clear array in the form the -clear attribute
    #will understand (value1, value2, value3)
    $options['Clear'] = $clear
    #This runs the Set-ADUser command when there is/are blank(s) in the row
    Get-ADUser -Filter "employeeNumber -eq '$($user.employeeNumber)'" |
    Set-ADUser -Replace $replace -clear $clear
  }
  else {
    #This runs the Set-ADUser command when there is no value in $clear (so there are no blank values in the row)
    Get-ADUser -Filter "employeeNumber -eq '$($user.employeeNumber)'" |
    Set-ADUser -Replace $replace
  }

  #Displays all variables as it loops thru so show the info.
  #Feel Free to comment out if you dont want to see it
  $options
  $clear
  $replace
}
Write-Host 'Completed!' -ForegroundColor Green