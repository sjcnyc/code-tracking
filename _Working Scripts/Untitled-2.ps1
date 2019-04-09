Get-Content C:\temp\sean_test.json |
  convertfrom-json | select -ExpandProperty items |
  Export-CSV C:\Temp\Sean_test.csv -NoTypeInformation


Get-Content C:\temp\sean_test.json |
  convertfrom-json | Select-Object items
