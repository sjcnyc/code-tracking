$Groups = @"
T2_STD_NA_USA_GBL_AzureVDI_Cognizant_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_Cognizant_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_Contractor_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_Contractor_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_DAG_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_DAG_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_DataMart_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_DataMart_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_DSC_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_DSC_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_EY_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_EY_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_FRA_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_FRA_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_General_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_General_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_GRP_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_GRP_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_GSA_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_GSA_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_Hyperion_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_Hyperion_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_Infra_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_Infra_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_Itopia_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_Itopia_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_ITT_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_ITT_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_KPMG_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_KPMG_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_Orchard_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_Orchard_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_RDC_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_RDC_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_RGL_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_RGL_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_Scuba_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_Scuba_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_SomLivre_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_SomLivre_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_TCS_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_TCS_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_UltaRecords_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_UltaRecords_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_Vantage_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_Vantage_G_SrvRDU
T2_STD_NA_USA_GBL_AzureVDI_WWI_G_SrvAdm
T2_STD_NA_USA_GBL_AzureVDI_WWI_G_SrvRDU
"@ -split [environment]::NewLine

foreach ($Group in $Groups) {

  $newADGroupSplat = @{
    Path          = "OU=USA,OU=NA,OU=SrvAccess,OU=Groups,OU=GBL,OU=USA,OU=NA,OU=ADM,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
    GroupCategory = 'Security'
    #GroupScope    = 'Global'
    Description   = 'Owner: Kim Lee'
    PassThru      = $true
    Verbose       = $true
    Name          = $Group
  }

  New-ADGroup @newADGroupSplat
}


#T2_STD_NA_USA_GBL_AzureVDI_<above subOU>_G_SrvAdm
#T2_STD_NA_USA_GBL_AzureVDI_<above subOU>_G_SrvRDU


#"Cognizant","Contractor","DAG","DataMart","DSC","EY","FRA","General","GRP","GSA","Hyperion","Infra","Itopia","ITT","KPMG","Orchard","RDC","RGL","Scuba","SomLivre","TCS","UltaRecords","Vantage","WWI"