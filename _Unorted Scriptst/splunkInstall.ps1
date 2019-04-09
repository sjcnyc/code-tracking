

$msiFile = "\\storage\ifs$\infra\data\Production_Shares\WWInfra\goldimages\ServerAgentInstaller_Dec_2017\Splunk\splunkforwarder-6.5.2-67571ef4b87d-x64-release.msi"
$SplunkRegionIP = "162.49.82.36:8089"
Start-Process -FilePath $msiFile -Wait -Verbose -ArgumentList "/quiet AGREETOLICENSE=Yes DEPLOYMENT_SERVER=$SplunkRegionIP /Liwem! C:\temp\splunk-install.log"