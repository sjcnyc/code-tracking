
# import the input csv file
$input_csv = Import-Csv .\attribute_mod_1.csv
<#
>> $input_csv[0] : 
userID          : D.ADVMS.01
displayName     : Wisdom Batts
givenName       : Wisdom
sn              : Batts
mail            : Wisdom.Batts@test.com
co              : United States
telephoneNumber : +1 404 555 1212
#>

# get the headers
$headers = $input_csv | Get-Member -MemberType NoteProperty | foreach {$_.name} 

<#
$headers>>
co
displayName
givenName
mail
sn
telephoneNumber
userID
#>


foreach ( $row in $input_csv)
    {
    #hashtable initialization
    $hashTable = @{}
    foreach ($header in $headers)
        {
        #Creating a hashtable that will hold the attribute value for each user against each attribute
        $hashTable.$header = $row.$header

        }
        <#
        Once the Loop2 is exected, We will get a hashtable of this format.
        $hashTable >>
        Name                           Value                                                                                                                                                                                                    
        ----                           -----                                                                                                                                                                                                    
        displayName                    Franny Pitts                                                                                                                                                                                             
        mail                           Franny.Pitts@test.com                                                                                                                                                                                    
        telephoneNumber                +1 201 555 1212                                                                                                                                                                                          
        givenName                      Franny                                                                                                                                                                                                   
        userID                         D.ADVMS.02                                                                                                                                                                                               
        co                             United States                                                                                                                                                                                            
        sn                             Pitts      
        ###########
        The loop has taken each attribute ( $header) and created a key for the hashtable, and used the same header to extract the corresponding value for each row.
        #>
    
    # The control jumps from the inner loop and reaches here.
    
    try
        {
        Set-ADUser -Identity $row.userID -Server $domain -Replace $hashTable
        }
    catch
        {
        # Write a exception handler, or log it using the $error variable properties.
        # More information on using the $error variable in future posts.
        }
    #$domain >> use the domain name where the user is located. If you don't know, we can use more sophisticated methods to first query the GC and then get the domain information.

    }
        
