# Change $mail to your email address
$mail="sean.connealy.peak@sonymusic.com"



# Set the path to your copy of EWS Managed API 
$dllpath = "C:\Program Files\Microsoft\Exchange\Web Services\2.2\Microsoft.Exchange.WebServices.dll"
# Load the Assemply 
[void][Reflection.Assembly]::LoadFile($dllpath) 
# Create a new Exchange service object 
$service = new-object Microsoft.Exchange.WebServices.Data.ExchangeService 
# Autodiscover using the mail address set above, using the logged on user's credentials 
$service.AutodiscoverUrl($mail, "Avatar5223")
# The Pagesize is used to split the EWS requests up into easily digestable parts for large folders 
$pagesize = 100 
# Offset keeps track of how for we are along a large folder. Set to 0 initially. 
$offset = 0 
# Create a property set that will allow us to pull out the message headers, as they aren't returned by default 
$propertySet=new-object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.ItemSchema]::InternetMessageHeaders) 
# Do/while loop for paging through the folder 
do 
{ 
    # Set what we want to retrieve from the folder 
    $view = New-Object Microsoft.Exchange.WebServices.Data.ItemView($pagesize,$offset)
    # Retrieve the data from the folder 
    $findResults = $service.FindItems([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Inbox,$view) 
    # The For Each loop goes through the items in the results one by one 
    foreach ($item in $findResults.Items)
    { 
    # Output the results - first of all the From, Subject, References and Message ID 
        "From: $($item.From.Name)"
        "Subject: $($item.Subject)" 
        "References: $($item.References)" 
        "InternetMessageID: $($item.InternetMessageID)" 
        "InternetMessageHeaders" 
    # Load the headers using the property set defined above 
        $item.Load($propertySet) 
    # Display the headers - using a little foreach loop, displaying them in the normal format 
        $item.InternetMessageHeaders|foreach{"$($_.Name): $($_.Value)"} 
        "" 
    
    } 
    # Set the offset to it's current value plus the page size 
    $offset+=$pagesize 
} while ($findResults.MoreAvailable) # Do/While loop will continue when more results are available

New-Object System.Management.Automation.PSCredential