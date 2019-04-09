#$sourceOU = "ou=SourceGPO,ou=6-Tests-GPO,dc=lab,dc=local"
#$targetOU = "ou=TargetGPO,ou=6-Tests-GPO,dc=lab,dc=local"

$MergeLogFile = "test"

#  $NewPrefix = "STG"

#region temp function - remove for PROD

function Browse-AD {
    param
    (
        [Parameter(Position = 1)]
        [string]$Title,
        [Parameter(Position = 2)]
        [string]$Instruction
    )

    # original inspiration: https://itmicah.wordpress.com/2013/10/29/active-directory-ou-picker-in-powershell/
    # author: Rene Horn the.rhorn@gmail.com
    <#
    Copyright (c) 2015, Rene Horn
    All rights reserved.
    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>
    $dc_hash = @{ }
    $selected_ou = $null

    Import-Module ActiveDirectory
    $forest = Get-ADForest
    [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    function Get-NodeInfo($sender, $dn_textbox) {
        $selected_node = $sender.Node
        $dn_textbox.Text = $selected_node.Name
    }

    function Add-ChildNodes($sender) {
        $expanded_node = $sender.Node

        if ($expanded_node.Name -eq "root") {
            return
        }

        $expanded_node.Nodes.Clear() | Out-Null

        $dc_hostname = $dc_hash[$($expanded_node.Name -replace '(OU=[^,]+,)*((DC=\w+,?)+)', '$2')]
        $child_OUs = Get-ADObject -Server $dc_hostname -Filter 'ObjectClass -eq "organizationalUnit" -or ObjectClass -eq "container"' -SearchScope OneLevel -SearchBase $expanded_node.Name
        if ($child_OUs -eq $null) {
            $sender.Cancel = $true
        }
        else {
            foreach ($ou in $child_OUs) {
                $ou_node = New-Object Windows.Forms.TreeNode
                $ou_node.Text = $ou.Name
                $ou_node.Name = $ou.DistinguishedName
                $ou_node.Nodes.Add('') | Out-Null
                $expanded_node.Nodes.Add($ou_node) | Out-Null
            }
        }
    }

    function Add-ForestNodes($forest, [ref]$dc_hash) {
        $ad_root_node = New-Object Windows.Forms.TreeNode
        $ad_root_node.Text = $forest.RootDomain
        $ad_root_node.Name = "root"
        $ad_root_node.Expand()

        $i = 1
        foreach ($ad_domain in $forest.Domains) {
            Write-Progress -Activity "Querying AD forest for domains and hostnames..." -Status $ad_domain -PercentComplete ($i++ / $forest.Domains.Count * 100)
            $dc = Get-ADDomainController -Server $ad_domain
            $dn = $dc.DefaultPartition
            $dc_hash.Value.Add($dn, $dc.Hostname)
            $dc_node = New-Object Windows.Forms.TreeNode
            $dc_node.Name = $dn
            $dc_node.Text = $dc.Domain
            $dc_node.Nodes.Add("") | Out-Null
            $ad_root_node.Nodes.Add($dc_node) | Out-Null
        }

        return $ad_root_node
    }

    $main_dlg_box = New-Object System.Windows.Forms.Form
    $main_dlg_box.ClientSize = New-Object System.Drawing.Size(400, 600)
    $main_dlg_box.MaximizeBox = $false
    $main_dlg_box.MinimizeBox = $false
    $main_dlg_box.FormBorderStyle = 'FixedSingle'
    $main_dlg_box.Text = $Title

    # widget size and location variables
    $ctrl_width_col = $main_dlg_box.ClientSize.Width / 20
    $ctrl_height_row = $main_dlg_box.ClientSize.Height / 15
    $max_ctrl_width = $main_dlg_box.ClientSize.Width - $ctrl_width_col * 2
    $max_ctrl_height = $main_dlg_box.ClientSize.Height - $ctrl_height_row
    $right_edge_x = $max_ctrl_width
    $left_edge_x = $ctrl_width_col
    $bottom_edge_y = $max_ctrl_height
    $top_edge_y = $ctrl_height_row

    # setup text box showing the distinguished name of the currently selected node
    $dn_text_box = New-Object System.Windows.Forms.TextBox
    # can not set the height for a single line text box, that's controlled by the font being used
    $dn_text_box.Width = (14 * $ctrl_width_col)
    $dn_text_box.Location = New-Object System.Drawing.Point($left_edge_x, ($bottom_edge_y - $dn_text_box.Height))
    $main_dlg_box.Controls.Add($dn_text_box)
    # /text box for dN

    # setup Ok button
    $ok_button = New-Object System.Windows.Forms.Button
    $ok_button.Size = New-Object System.Drawing.Size(($ctrl_width_col * 2), $dn_text_box.Height)
    $ok_button.Location = New-Object System.Drawing.Point(($right_edge_x - $ok_button.Width), ($bottom_edge_y - $ok_button.Height))
    $ok_button.Text = "Ok"
    $ok_button.DialogResult = 'OK'
    $main_dlg_box.Controls.Add($ok_button)
    # /Ok button

    # labelInstruction
    #
    $labelInstruction = New-Object 'System.Windows.Forms.Label'
    $labelInstruction.AutoSize = $True
    $labelInstruction.Location = '13, 13'
    $labelInstruction.Name = 'labelInstruction'
    $labelInstruction.Size = '47, 13'
    $labelInstruction.TabIndex = 0
    $labelInstruction.Text = $Instruction
    $main_dlg_box.Controls.Add($labelInstruction)
    # /labelInstruction

    # setup tree selector showing the domains
    $ad_tree_view = New-Object System.Windows.Forms.TreeView
    $ad_tree_view.Size = New-Object System.Drawing.Size($max_ctrl_width, ($max_ctrl_height - $dn_text_box.Height - $ctrl_height_row * 1.5))
    $ad_tree_view.Location = New-Object System.Drawing.Point($left_edge_x, $top_edge_y)
    $ad_tree_view.Nodes.Add($(Add-ForestNodes $forest ([ref]$dc_hash))) | Out-Null
    $ad_tree_view.Add_BeforeExpand( { Add-ChildNodes $_ })
    $ad_tree_view.Add_AfterSelect( { Get-NodeInfo $_ $dn_text_box })
    $main_dlg_box.Controls.Add($ad_tree_view)
    # /tree selector

    $main_dlg_box.ShowDialog() | Out-Null

    return $dn_text_box.Text
}

function Write-Log {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$MessageLog,
        [Parameter(Mandatory = $true)]
        [string]$LogfileName
    )

    Write-Host $MessageLog

}

function CheckOUExist {
    param
    (
        [Parameter(Mandatory = $true,
            Position = 1)]
        $OUToSeek
    )

    [string]$Path = $OUToSeek

    try {
        $ou_exists = [adsi]::Exists("LDAP://$Path")
    }
    catch {
        # If invalid format, error is thrown.
        Throw ("Supplied Path is invalid.`n$_")
    }

    if (-not $ou_exists) {
        $ou_exists = $false
    }
    else {
        Write-Debug "Path Exists:  $Path"
    }
    return $ou_exists
}
#endregion

#region Clone-LinkedGPO
function Clone-LinkedGPO {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$sourceOU,
        [Parameter(Mandatory = $true)]
        [string]$targetOU,
        [Parameter(Mandatory = $true)]
        [string]$NewPrefix
    )

    If ((!(CheckOUExist -OUToSeek $sourceOU)) -or (!(CheckOUExist -OUToSeek $targetOU))) {
        Write-Log "Source or target OU doesn't exist." -LogfileName $MergeLogFile
        return
    }

    $sourceSubOUs = Get-ADOrganizationalUnit -SearchBase $sourceOU -Filter * | select DistinguishedName

    $sourceSubOUsName = Get-ADOrganizationalUnit -SearchBase $sourceOU -Filter * | select Name
    $targetSubOUsName = Get-ADOrganizationalUnit -SearchBase $targetOU -Filter * | select Name

    #Validate same OU structure in $sourceOU and $targetOU
    $CompareOU = Compare-Object -ReferenceObject $sourceSubOUsName -DifferenceObject $targetSubOUsName -PassThru

    If ($CompareOU) {
        Write-Log -MessageLog "OU doesn't have the same structure" -LogfileName $MergeLogFile
        return
    }

    foreach ($sourceSubOU in $sourceSubOUs) {
        $SubOUsName = $sourceSubOU.DistinguishedName
        $source = $SubOUsName
        $target = $SubOUsName -replace $sourceOU, $targetOU
        Write-Log -Message "Processing $source to $target" -LogfileName $MergeLogFile
        $linked = (Get-GPInheritance -Target $source).GpoLinks
        $BI = (Get-GPInheritance -Target $source).GPOInheritanceBlocked
        If ($BI) {
            $BI = "Yes"
            Set-GPInheritance -Target $target -IsBlocked $BI
        }
        Else {
            $BI = "No"
        }
        foreach ($link in $linked) {
            $guid = $link.GpoId
            $order = $link.Order
            $enabled = $link.Enabled
            $enforced = $link.Enforced
            $displayname = $link.DisplayName
            $newGpoName = $NewPrefix + "-" + $displayname
            If ($enabled) { $enabled = "Yes" }
            else { $enabled = "No" }
            If ($enforced) { $enforced = "Yes" }
            else { $enforced = "No" }
            try {
                Write-Log -MessageLog "Linking $guid on $target ($enabled) in order $order" -LogfileName $MergeLogFile
                Copy-GPO -SourceGuid $guid -TargetName $newGpoName -CopyAcl -ErrorAction Stop
                $newguid = Get-GPO -Name $newGpoName | Select -ExpandProperty Id
                New-GPLink -Guid $newguid -Target $target -LinkEnabled $enabled -Order $order -Enforced $enforced -ErrorAction Stop
            }
            catch {
                Write-Log "Notification: $($_.Exception.Message)" -LogfileName $MergeLogFile
            }
        }
    }
}

#endregion

$sourceOU = Browse-AD -Title "Select source OU to clone GPO from" -Instruction "Select source OU to clone GPO from"
$targetOU = Browse-AD -Title "Select target OU to clone GPO to" -Instruction "Select target OU to clone GPO to"

[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")

$NewPrefix = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the prefix", "Enter the prefix")

if ((!($sourceOU)) -or (!($targetOU)) -or (!($NewPrefix))) {
    return
}

Clone-LinkedGPO -sourceOU $sourceOU -targetOU $targetOU -NewPrefix $NewPrefix