<#
    .SYNOPSIS
    Import VHD to AWS isnstance

    .DESCRIPTION
    Import VHD to AWS instance, and create policy and role groups

    .NOTES
    vmimport role & policy are now created.  semvmimportimages bucket created
    To upload a new VHD to instance, just config and run everything below the
    upload to bucket #region
#>

$awsinfo = @{
    AccessKey = "AKIAIOFHP6KIVJTHFZHA"
    SecretKey = "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"
    Region    = "us-east-1"
}

$importPolicyDocument = @"
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Sid":"",
         "Effect":"Allow",
         "Principal":{
            "Service":"vmie.amazonaws.com"
         },
         "Action":"sts:AssumeRole",
         "Condition":{
            "StringEquals":{
               "sts:ExternalId":"vmimport"
            }
         }
      }
   ]
}
"@

New-IAMRole -RoleName vmimport -AssumeRolePolicyDocument $importPolicyDocument @awsinfo

$bucketName = "smevmimportimages"

$rolePolicyDocument = @"
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "s3:ListBucket",
            "s3:GetBucketLocation"
         ],
         "Resource":[
            "arn:aws:s3:::$bucketName"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:GetObject"
         ],
         "Resource":[
            "arn:aws:s3:::$bucketName/*"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "ec2:ModifySnapshotAttribute",
            "ec2:CopySnapshot",
            "ec2:RegisterImage",
            "ec2:Describe*"
         ],
         "Resource":"*"
      }
   ]
}
"@

Write-IAMRolePolicy -RoleName vmimport -PolicyName vmimport -PolicyDocument $rolePolicyDocument @awsinfo

#region upload to bucket
Write-S3Object -BucketName $bucketName -File '\\storage\tempvhdshare$\PAW_TIER0.vhd' @awsinfo

$windowsContainer = New-Object Amazon.EC2.Model.ImageDiskContainer
$windowsContainer.Format = "VHD"

$userBucket = New-Object Amazon.EC2.Model.UserBucket
$userBucket.S3Bucket = $bucketName
$userBucket.S3Key = "PAW_TIER0.vhd"
$windowsContainer.UserBucket = $userBucket

$params = @{
    "ClientToken" = "PAW_TIER0.vhd_" + (Get-Date)
    "Description" = "PAW_TIER0 image import"
    "Platform"    = "Windows"
    "LicenseType" = "BYOL"
}

Import-EC2Image -DiskContainer $windowsContainer @params
#endregion upload to bucket