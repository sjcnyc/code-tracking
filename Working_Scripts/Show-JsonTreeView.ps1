function Show-JsonTreeView {

    param (
        [Parameter(Mandatory)]
        $Json
    )

    function Show-jsonTreeView_psf {

        #----------------------------------------------
        #region Import the Assemblies
        #----------------------------------------------
        [void][reflection.assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
        [void][reflection.assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
        #endregion Import Assemblies

        #----------------------------------------------
        #region Generated Form Objects
        #----------------------------------------------
        [System.Windows.Forms.Application]::EnableVisualStyles()
        $formJSONTreeView = New-Object 'System.Windows.Forms.Form'
        $treeview1 = New-Object 'System.Windows.Forms.TreeView'
        $InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
        #endregion Generated Form Objects

        #----------------------------------------------
        # User Generated Script
        #----------------------------------------------
	
        function Add-JsonToTreeview {
		
            ########################################################################################
            #                                                                                      #
            #    The MIT License                                                                   #
            #                                                                                      #
            #    Copyright (c) 2019 Matt Oestreich. http://mattoestreich.com                       #
            #                                                                                      #
            #    Permission is hereby granted, free of charge, to any person obtaining a copy      #
            #    of this software and associated documentation files (the "Software"), to deal     #
            #    in the Software without restriction, including without limitation the rights      #
            #    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell         #
            #    copies of the Software, and to permit persons to whom the Software is             #
            #    furnished to do so, subject to the following conditions:                          #
            #                                                                                      #
            #    The above copyright notice, accreditation to Matt Oestreich, and this permission  #
            #    notice shall be included in all copies or substantial portions of the Software.   #
            #                                                                                      #
            #    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR        #
            #    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,          #
            #    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE       #
            #    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER            #
            #    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,     #
            #    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN         #
            #    THE SOFTWARE.                                                                     #
            #                                                                                      #
            ########################################################################################
		
            <#
                    .SYNOPSIS
                    Add JSON to TreeView
		
                    .DESCRIPTION
                    Add JSON to TreeView (System.Windows.Forms.TreeView) Component
		
                    .PARAMETER Json
                    JSON data (`-Json` can be a `[String]` or converted JSON string (aka `[PsCustomObject]`) converted using `ConvertFrom-Json`). See examples for more details.
		
                    .PARAMETER TreeView
                    The TreeView (System.Windows.Forms.TreeView) that you want to add JSON to
		
                    .PARAMETER ParentNode
                    This is here for recursion - you will most likely not need to use this Parameter
                    9.99 times out of 10.00 you wil not need to use this Parameter
		
                    .EXAMPLE
                    PS C:\> $SomeTreeView = [System.Windows.Forms.TreeView]::new()
                    PS C:\> $myJsonString = '{ "Root": [{ "Child1": "Value1" }, { "Child2": "Value2" }, { "Child3": "Value3" }] }'
                    PS C:\> $myJsonConverted = $myJsonString | ConvertFrom-Json
                    PS C:\> Add-JsonToTreeview -Json $myJsonConverted -TreeView $SomeTreeView
	
                    .EXAMPLE
                    PS C:\> $SomeTreeView = [System.Windows.Forms.TreeView]::new()
                    PS C:\> $myJsonString = '{ "Root": [{ "Child1": "Value1" }, { "Child2": "Value2" }, { "Child3": "Value3" }] }'
                    PS C:\> Add-JsonToTreeview -Json $myJsonString -TreeView $SomeTreeView
		
                    .NOTES
                    Matt Oestreich | http://mattoestreich.com | https://github.com/oze4
            #>
		
            param (
                [Parameter(Mandatory)]
                $Json,
			
                [Parameter(Mandatory)]
                [Windows.Forms.TreeView]$TreeView,
			
                [Parameter()]
                [Windows.Forms.TreeNode]$ParentNode
            )
		
            begin {
                function New-TreeViewNode {
                    param (
                        [Parameter(Mandatory)]
                        [string]$Value
                    )
                    $NewNode = [Windows.Forms.TreeNode]::new($Value)
                    $NewNode.Name = $Value
                    return $NewNode
                }
			
                function Add-ObjectToTreeView {
                    param (
                        [Parameter(Mandatory)]
                        [System.Object[]]$Object,
					
                        [Parameter()]
                        [Windows.Forms.TreeNode]$AddToNode,
					
                        [Parameter(Mandatory)]
                        [Windows.Forms.TreeView]$TargetTreeView
                    )
                    $counter = 1
                    foreach ($objectProp in $Object) {
                        if ((($objectProp | Get-Member -Type NoteProperty).Count) -gt 1) {
                            $objectProp = "{ `"$($counter)`": $($objectProp | ConvertTo-Json) }" | ConvertFrom-Json
                            $counter++
                        }
                        Add-JsonToTreeview -Json $objectProp -ParentNode $AddToNode -TreeView $TargetTreeView
                    }
                }
			
                function Find-ParentNode {
                    param (
                        [Parameter(Mandatory)]
                        [Windows.Forms.TreeView]$TreeView,
					
                        [Parameter(Mandatory)]
                        [AllowNull()]
                        [Windows.Forms.TreeNode]$TreeNode
                    )
                    $parent = $TreeView
                    if ($TreeNode) {
                        $parent = $TreeNode
                    }
                    return $parent
                }
            }
            process {
                switch ($Json.GetType().Name) {
                    'PsCustomObject' {
                        foreach ($jsonProperty in $Json.PsObject.Properties) {
                            $node = New-TreeViewNode -Value $jsonProperty.Name
                            (Find-ParentNode -TreeView $TreeView -TreeNode $ParentNode).Nodes.Add($node)
                            if ($jsonProperty.GetType().Name -eq 'Object[]') {
                                Add-ObjectToTreeView -Object $jsonProperty -AddToNode $node -TargetTreeView $TreeView
                            } else {
                                Add-JsonToTreeview -Json $jsonProperty.Value -ParentNode $node -TreeView $TreeView
                            }
                        }
                    }
				
                    'Object[]' {
                        Add-ObjectToTreeView -Object $Json -AddToNode $ParentNode -TargetTreeView $TreeView
                    }
				
                    'String' {
                        try {
                            Add-JsonToTreeview -Json ($Json | ConvertFrom-Json) -ParentNode $ParentNode -TreeView $TreeView
                        } catch {
                            (Find-ParentNode -TreeView $TreeView -TreeNode $ParentNode).Nodes.Add((New-TreeViewNode -Value $Json))
                        }
                    }
                }
			
                if ($Json -is [ValueType]) {
                    try {
                        (Find-ParentNode -TreeView $TreeView -TreeNode $ParentNode).Nodes.Add((New-TreeViewNode -Value $Json.ToString()))
                    } catch {
                    }
                }
            }
        }
	
	
	
        $formJSONTreeView_Load={
            Add-JsonToTreeview -Json $Json -TreeView $treeview1
        }
	
        # --End User Generated Script--
        #----------------------------------------------
        #region Generated Events
        #----------------------------------------------
	
        $Form_StateCorrection_Load=
        {
            #Correct the initial state of the form to prevent the .Net maximized form issue
            $formJSONTreeView.WindowState = $InitialFormWindowState
        }
	
        $Form_Cleanup_FormClosed=
        {
            #Remove all event handlers from the controls
            try
            {
                $formJSONTreeView.remove_Load($formJSONTreeView_Load)
                $formJSONTreeView.remove_Load($Form_StateCorrection_Load)
                $formJSONTreeView.remove_FormClosed($Form_Cleanup_FormClosed)
            }
            catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
        }
        #endregion Generated Events

        #----------------------------------------------
        #region Generated Form Code
        #----------------------------------------------
        $formJSONTreeView.SuspendLayout()
        #
        # formJSONTreeView
        #
        $formJSONTreeView.Controls.Add($treeview1)
        $formJSONTreeView.AutoScaleDimensions = '6, 13'
        $formJSONTreeView.AutoScaleMode = 'Font'
        $formJSONTreeView.ClientSize = '440, 606'
        $formJSONTreeView.MaximizeBox = $False
        $formJSONTreeView.MinimizeBox = $False
        $formJSONTreeView.Name = 'formJSONTreeView'
        $formJSONTreeView.Text = 'JSON TreeView'
        $formJSONTreeView.add_Load($formJSONTreeView_Load)
        #
        # treeview1
        #
        $treeview1.Location = '12, 12'
        $treeview1.Name = 'treeview1'
        $treeview1.Size = '416, 582'
        $treeview1.TabIndex = 0
        $formJSONTreeView.ResumeLayout()
        #endregion Generated Form Code

        #----------------------------------------------

        #Save the initial state of the form
        $InitialFormWindowState = $formJSONTreeView.WindowState
        #Init the OnLoad event to correct the initial state of the form
        $formJSONTreeView.add_Load($Form_StateCorrection_Load)
        #Clean up the control events
        $formJSONTreeView.add_FormClosed($Form_Cleanup_FormClosed)
        #Show the Form
        return $formJSONTreeView.ShowDialog()

    } #End Function

    #Call the form
    Show-jsonTreeView_psf | Out-Null
}