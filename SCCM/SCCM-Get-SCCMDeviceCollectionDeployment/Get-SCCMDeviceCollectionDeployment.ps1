﻿function Get-SCCMDeviceCollectionDeployment
{
<#
	.SYNOPSIS
		Function to retrieve a Device targeted application(s)
	
	.DESCRIPTION
		Function to retrieve a Device targeted application(s).
		The function will first retrieve all the collection where the Device is member of and
		find deployment advertised to those.
	
	.PARAMETER Devicename
		Specifies the SamAccountName of the Device.
		The Device must be present in the SCCM CMDB
	
	.PARAMETER SiteCode
		Specifies the SCCM SiteCode
	
	.PARAMETER ComputerName
		Specifies the SCCM Server to query
	
	.PARAMETER Credential
		Specifies the credential to use to query the SCCM Server.
        Default will take the current user credentials
	
	.PARAMETER Purpose
		Specifies a specific deployment intent.
        Possible value: Available or Required.
        Default is Null (get all)
    .EXAMPLE
        Get-SCCMDeviceCollectionDeployment -DeviceName MTLLAP8500 -Credential $cred -Purpose Required
	
	.NOTES
        Francois-Xavier cat
        www.lazywinadmin.com
        @lazywinadm

		SMS_R_SYSTEM: https://msdn.microsoft.com/en-us/library/cc145392.aspx
		SMS_Collection: https://msdn.microsoft.com/en-us/library/hh948939.aspx
		SMS_DeploymentInfo: https://msdn.microsoft.com/en-us/library/hh948268.aspx
#>
	[CmdletBinding()]
	PARAM
	(
		[Parameter(Mandatory)]
		$DeviceName,
		
        [Parameter(Mandatory)]
		$SiteCode,
		
        [Parameter(Mandatory)]
		$ComputerName,
		
		[Alias('RunAs')]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[ValidateSet('Required', 'Available')]
		$Purpose
	)
	
	BEGIN
	{
		
		# Define default properties
		$Splatting = @{
			ComputerName = $ComputerName
			NameSpace = "root\SMS\Site_$SiteCode"
		}
		
		IF ($PSBoundParameters['Credential'])
		{
			$Splatting.Credential = $Credential
		}
		
		Switch ($Purpose)
		{
			"Required" { $DeploymentIntent = 0 }
			"Available" { $DeploymentIntent = 2 }
			default { $DeploymentIntent = "NA" }
		}

		Function Get-SCCMDeploymentIntentName
		{
	        	PARAM(
	        	[Parameter(Mandatory)]
	        	$DeploymentIntent
	        	)
            		PROCESS
	            	{
				if ($DeploymentIntent = 0) { Write-Output "Required" }
				if ($DeploymentIntent = 2) { Write-Output "Available" }
				if ($DeploymentIntent -ne 0 -and $DeploymentIntent -ne 2) { Write-Output "NA" }
			}
		} #Function Get-DeploymentIntentName
		
		function Get-SCCMDeploymentTypeName
		{
			<#
			https://msdn.microsoft.com/en-us/library/hh948731.aspx
			#>
			PARAM ($TypeID)
			switch ($TypeID)
			{
				1 { "Application" }
				2 { "Program" }
				3 { "MobileProgram" }
				4 { "Script" }
				5 { "SoftwareUpdate" }
				6 { "Baseline" }
				7 { "TaskSequence" }
				8 { "ContentDistribution" }
				9 { "DistributionPointGroup" }
				10{ "DistributionPointHealth" }
				11{ "ConfigurationPolicy" }
			}
		}
		
	}
	PROCESS
	{
		$Device = Get-WMIObject @Splatting -Query "Select * From SMS_R_SYSTEM WHERE Name='$DeviceName'"
		
		
		Get-WmiObject -Class sms_fullcollectionmembership @splatting -Filter "ResourceID = '$($Device.resourceid)'" | ForEach-Object {
			$Collections = Get-WmiObject @splatting -Query "Select * From SMS_Collection WHERE CollectionID='$($_.Collectionid)'"
			
			Foreach ($Collection in $collections)
			{
				IF ($DeploymentIntent -eq 'NA')
				{
					$Deployments = (Get-WmiObject @splatting -Query "Select * From SMS_DeploymentInfo WHERE CollectionID='$($Collection.CollectionID)'")
				}
				ELSE
				{
					$Deployments = (Get-WmiObject @splatting -Query "Select * From SMS_DeploymentInfo WHERE CollectionID='$($Collection.CollectionID)' AND DeploymentIntent='$DeploymentIntent'")
				}
				
				Foreach ($Deploy in $Deployments)
				{
					# Get the Deployment type
					$TypeName = Get-SCCMDeploymentTypeName -TypeID $Deploy.DeploymentTypeid
					if (-not $TypeName) { $TypeName = Get-SCCMDeploymentTypeName -TypeID $Deploy.DeploymentType }
					
					# Prepare output
					$Properties = @{
						DeviceName = $DeviceName
						ComputerName = $ComputerName
						CollectionName = $Deploy.CollectionName
						CollectionID = $Deploy.CollectionID
						DeploymentID = $Deploy.DeploymentID
						DeploymentName = $Deploy.DeploymentName
						DeploymentIntent = $deploy.DeploymentIntent
						DeploymentIntentName = (Get-SCCMDeploymentIntentName -DeploymentIntent $deploy.DeploymentIntent)
						DeploymentTypeName = $TypeName
						TargetName = $Deploy.TargetName
						TargetSubName = $Deploy.TargetSubname
						
					}
					
					#Output the current object
					New-Object -TypeName PSObject -prop $Properties
					
					# Reset TypeName
					$TypeName=""
				}
			}
		}
	}
}
