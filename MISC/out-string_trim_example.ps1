[pscustomobject]@{
    First = 'Sean'
    Last = 'Conealy'
    ExtraInfo = (@(1,3,5,6) | Out-String).Trim()
    State = 'NY'
    IPs = (@('111.222.11.22','55.12.89.125','125.48.2.1','145.23.15.89','123.12.1.0') | Out-String).Trim()
} #| Out-GridView -PassThru #Export-Csv -notype 'd:\temp\Random.csv'