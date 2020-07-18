# Method 1 - Using @{ }
$Hashtable = @{
    First = 'Connealy'
    Last = 'Sean'
    Age = 49
}

# Method 2 - Using .Net class for Hashtable
$Hashtable = New-Object System.Collections.Hashtable
$Hashtable['First'] = 'Connealy'
$Hashtable['Last'] = 'Sean'
$Hashtable['Age'] = 49

# Method 3 - Using HashTable PowerShell type accelerator
$Hashtable = [hashtable]::new()
$Hashtable['First'] = 'Connealy'
$Hashtable['Last'] = 'Sean'
$Hashtable['Age'] = 49

# Method 4 - Using ordered dictionary
$Hashtable = [System.Collections.Specialized.OrderedDictionary]::new()
$Hashtable['First'] = 'Connealy'
$Hashtable['Last'] = 'Sean'
$Hashtable['Age'] = 49

# Method 5 - Using strongly typed Dictionary
$Dictionary = New-Object 'System.Collections.Generic.Dictionary[String,String]'
$Dictionary['First'] = 'Connealy'
$Dictionary['Last'] = 'Sean'
$Dictionary['Age'] = 49

# Method 6 - Using Dictionary PowerShell Type Accelarator
$Dictionary = [System.Collections.Generic.Dictionary[string,int]]::new()
$Dictionary.id = 101 
$Dictionary.age = 49

# Method 7 - From PSObject by iterating properties
#            and adding key-value pairs
$Object = New-Object psobject -Property @{ 
    a = 1
    b = 2
}

$Hashtable = @{} # emtpy hashtable

# access the properties of [PSObject] and iterate them
$Object.psobject.properties.ForEach({ $Hashtable[$_.Name] = $_.Value })


# Method 8 - String to Hashtable using `ConvertFrom-StringData` cmdlet
@"
name=Connealy
age=49
skills=powershell
"@ | ConvertFrom-StringData


# Method 9 - From String using `-Match` operator
$Hashtable = @{}
@"
name=Connealy
age=49
skills=powershell
"@ -split [System.Environment]::NewLine | ForEach-Object { 
    if ($_ -match '^(.*)=(.*)'){ 
        $Hashtable[$matches[1]] = $matches[2]
    }
}

#3333333