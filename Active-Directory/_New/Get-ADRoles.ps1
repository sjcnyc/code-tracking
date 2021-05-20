Get-QADUser -Identity "admsconnea-1" -Service me.sonymusic.com -SecurityMask Dacl -PipelineVariable usr |
    Get-QADPermission -UseExtendedMatch -Inherited -SchemaDefault -Allow | ForEach-Object -Process {

    [PSCustomObject]@{

        # 'User'              = $usr.samaccountname
        'TargetObject'      = $_.TargetObject
        'Account'           = $_.Account
        'TransitiveAccount' = $_.TransitiveAccount
        'AccountName'       = $_.AccountName
        'AccessControlType' = $_.AccessControlType
        'Rights'            = $_.Rights
        'RightsDisplay'     = $_.RightsDisplay
        'Source'            = $_.Source
        'ExtendedRight'     = $_.ExtendedRight
        'ValidatedWrite'    = $_.ValidatedWrite
        'Property'          = $_.Property
        'PropertySet'       = $_.PropertySet
        'ApplyTo'           = $_.ApplyTo
        'ApplyToDisplay'    = $_.ApplyToDisplay
        'ApplyToType'       = $_.ApplyTo
        'ChildType'         = $_.ChildType
    }
}