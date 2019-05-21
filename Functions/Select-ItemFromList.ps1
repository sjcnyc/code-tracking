<# 
    .SYNOPSIS 
        Select-ItemFromList utility receives a collection of objects and will  
        display the list as either a numbered text list as a menu or in a list  
        box for selection. There is a switch to enable multiple item selection. 
    .DESCRIPTION 
        The utility takes a collection of objects and builds a list for displaying  
        the selections.  You can specify the property of to use for the display  
        list.  If no property is specified the ToString() method of the object will 
        be used.  Often this simply displays the object's type. 
    .PARAMETER  options 
        options is the collection of objects to be displayed. 
    .PARAMETER  displayProperty 
        displayProperty defines what property of the object to use in the list 
        for selection. 
    .PARAMETER  title 
        title defines the heading on the form used to for displaying the list box 
        or the text displayed before the menu listing.  The default is "Select Item" 
    .PARAMETER  mode 
        mode specifies whether to use a ListBox, CheckedListBox or a text listing to  
        display the options.  When using a menu format the items are prefixed with a  
        number to identify the options.   
            The options are: 
                Menu            A numbered text list 
                ListBox         A ListBox of the items, the behaviour can be modified 
                                with the selectMultiple switch. 
                CheckedListBox  A CheckedListBox of the items 
                 
                The default is ListBox 
    .PARAMETER  selectionMode 
        selectionMode controls how items will be selected.  This parameter is only 
        used by Menu and ListBox modes 
        Options are: 
            None 
            One 
            MultiSimple 
            MultiExtended 
    .EXAMPLE 
        Select-ItemFromList -options (Get-Process) -displayProperty ProcessName -mode ListBox -selectMultiple 
    .EXAMPLE 
        Select-ItemFromList -options (Get-Process) -displayProperty ProcessName -mode CheckedListBox 
    .EXAMPLE 
        Select-ItemFromList -options "One","Two","Three" -mode Menu -selectMultiple 
    .OUTPUTS 
        The objects from the input options that were selected are outputted to the 
        pipeline. 
#> 
function Select-ItemFromList 
{ 
[CmdletBinding()] 
PARAM  
( 
    [Parameter(Mandatory=$true)] 
    $options, 
    [string]$displayProperty, 
    [string]$title = 'Select Item', 
    [ValidateSet('Menu','ListBox','CheckedListBox')] 
    [string]$mode = 'ListBox', 
    [System.Windows.Forms.SelectionMode]$selectionMode = [System.Windows.Forms.SelectionMode]::One 
) 
    $script:selectedItem = $null 
    $selectMultiple = ($selectionMode -eq [System.Windows.Forms.SelectionMode]::MultiSimple -or $selectionMode -eq [System.Windows.Forms.SelectionMode]::MultiExtended) 
    [Windows.Forms.form]$form = new-object Windows.Forms.form 
     
    switch($mode.ToLower())  
    { 
        'checkedlistbox' 
        { 
            [System.Windows.Forms.CheckedListBox]$lstOptions = New-Object System.Windows.Forms.CheckedListBox  
            $lstOptions.CheckOnClick = $True 
        } 
        'listbox' 
        { 
            [System.Windows.Forms.ListBox]$lstOptions = New-Object System.Windows.Forms.ListBox 
            $lstOptions.SelectionMode  = $selectionMode 
        } 
    } 
     
    function processOK 
    { 
        $script:selectedItem = $null 
        if ($mode.ToLower() -eq 'checkedlistbox') 
        { 
            if ($lstOptions.CheckedIndices.Count -gt 0) 
            { 
                $script:selectedItem = @($options[$lstOptions.CheckedIndices[0]]) 
                for ($i = 1;$i -lt $lstOptions.CheckedIndices.Count;$i++) 
                { 
                    $script:selectedItem += $options[$lstOptions.CheckedIndices[$i]] 
                } 
            } 
        } 
        if ($mode.ToLower() -eq 'listbox') 
        { 
            if ($lstOptions.SelectedIndices.Count -gt 0) 
            { 
                $script:selectedItem = @($options[$lstOptions.SelectedIndices[0]]) 
                for ($i = 1;$i -lt $lstOptions.SelectedIndices.Count;$i++) 
                { 
                    $script:selectedItem += $options[$lstOptions.SelectedIndices[$i]] 
                } 
            } 
        } 
            $form.Close() 
    } 
 
    function processCancel 
    { 
        $script:selectedItem = $null 
        $form.Close() 
    } 
 
 
    function BuildMenu 
    { 
    PARAM  
    ( 
        [Parameter(Mandatory=$true)] 
        $options, 
        [string]$displayProperty, 
        [string]$title = 'Select Item' 
    ) 
        [int]$optionPrefix = 1 
        $selectMultiple = ($selectionMode -eq [System.Windows.Forms.SelectionMode]::MultiSimple -or $selectionMode -eq [System.Windows.Forms.SelectionMode]::MultiExtended) 
        [System.Text.StringBuilder]$sb = New-Object System.Text.StringBuilder 
        $sb.Append([Environment]::NewLine + $title + [Environment]::NewLine + [Environment]::NewLine) | Out-Null 
         
        foreach ($option in $options) 
        { 
            if ([String]::IsNullOrEmpty($displayProperty)) 
            { 
                $sb.Append(('{0,3}: {1}' -f $optionPrefix,$option) + [Environment]::NewLine) | Out-Null 
            } 
            else 
            { 
                $sb.Append(('{0,3}: {1}' -f $optionPrefix,$option.$displayProperty) + [Environment]::NewLine) | Out-Null 
            } 
            $optionPrefix++ 
        } 
        $sb.Append([Environment]::NewLine) | Out-Null 
        if ($selectMultiple) 
        { 
            $sb.Append('Make multiple selections as a comma delimited list' + [Environment]::NewLine) 
        } 
        $sb.Append([Environment]::NewLine + ('{0,3}: {1}' -f 0,'To cancel')) | Out-Null   
        return $sb.ToString() 
    } 
     
    function BuildForm 
    { 
    PARAM  
    ( 
        [Parameter(Mandatory=$true)] 
        $options, 
        [string]$displayProperty, 
        [string]$title = 'Select Item' 
    ) 
        $script:selectedItem = $null 
         
        $form.Size = new-object System.Drawing.Size @(235,250)    
        $form.text = $title   
         
        #Create the list box. 
         
        $lstOptions.Name = 'lstOptions' 
        $lstOptions.Width = 210 
        $lstOptions.Height = 175 
        $lstOptions.Location = New-Object System.Drawing.Size(5,5) 
        $lstOptions.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right 
             
        #Create the OK button 
        [System.Windows.Forms.Button]$btnOK = New-Object System.Windows.Forms.Button  
        $btnOK.Width=100 
        $btnOK.Location = New-Object System.Drawing.Size(110, 180) 
        $btnOK.Text = 'OK' 
        $btnOK.add_click({processOK}) 
        $btnOK.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right 
        $form.Controls.Add($lstOptions) 
        $form.Controls.Add($btnOK) 
         
        #Create the Cancel button 
        [System.Windows.Forms.Button]$btnCancel = New-Object System.Windows.Forms.Button  
        $btnCancel.Width=100 
        $btnCancel.Location = New-Object System.Drawing.Size(5, 180) 
        $btnCancel.Text = 'Cancel' 
        $btnCancel.add_click({processCancel}) 
        $btnCancel.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right 
         
        $form.Controls.Add($lstOptions) 
        $form.Controls.Add($btnOK) 
        $form.Controls.Add($btnCancel) 
         
        #Populate ListBox 
        foreach ($option in $options) 
        { 
            if ([String]::IsNullOrEmpty($displayProperty)) 
            { 
                $lstOptions.Items.Add($option) | Out-Null 
            } 
            else 
            { 
                $lstOptions.Items.Add($option.$displayProperty) | Out-Null 
            } 
        } 
        return $form 
    } 
     
    switch($mode.ToLower())  
    { 
        'menu' 
            { 
                [string]$menuText = BuildMenu -options $options -DisplayProperty $displayProperty -title $title 
                Write-Host $menuText 
                [string]$responseString = Read-Host 'Enter Selection' 
                if (-not [String]::IsNullOrEmpty($responseString)) 
                { 
                    $script:selectedItem = $null 
                    [int]$index = 0 
                    if ($selectMultiple) 
                    { 
                        $responses = $responseString.Split(',') 
                        foreach ($response in $responses) 
                        { 
                            $index = [int]$response 
                            if ($response -gt 0 -and $response -le $options.Count) 
                            { 
                                if ($script:selectedItem -eq $null) 
                                { 
                                    $script:selectedItem = @($options[$response-1]) 
                                } 
                                else 
                                { 
                                    $script:selectedItem += $options[$response-1] 
                                } 
                            } 
                        } 
                    } 
                    else 
                    { 
                        $index = [int]$responseString 
                        $script:selectedItem = @($options[$index-1]) 
                    } 
                     
                } 
            } 
        'checkedbistbox'  
            {  
                $fm = BuildForm -options $options -DisplayProperty $displayProperty -title $title 
                $fm.ShowDialog() | Out-Null 
            } 
        default  
            {  
                $fm = BuildForm -options $options -DisplayProperty $displayProperty -title $title 
                $fm.ShowDialog() | Out-Null 
            } 
    } 
    Write-Output $script:selectedItem 
} 