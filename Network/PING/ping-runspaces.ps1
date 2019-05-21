Function Get-SuperPing{
  Param([Parameter(ValueFromPipeline=$true,Mandatory=$true)][System.Collections.ArrayList]$ping)

  Begin{
    $runSpacePool = [RunSpaceFactory]::CreateRunspacePool(1, 25)
    $runSpacePool.Open()

    $jobs = @()
    $data = @()
  }

  Process{
    ForEach($p in $ping)
         {
         $flags= @{'computername' = "$p" ; 'count' = '3'}
         $pipeline = [powershell]::Create().AddCommand('Test-Connection')
         Foreach($f in $flags.keys)
                 {
                 $pipeline.AddParameter($f, $flags.$f) | Out-Null
                 }

         $pipeline.RunSpacePool = $runSpacePool
         $status = $pipeline.BeginInvoke()

         $job = '' | Select-Object Status, Pipeline
         $job.Status = $status
         $job.Pipeline = $pipeline
         $jobs += $job
         }
  }

  End{        
    While (@($jobs | Where-Object {$_.Status-ne $Null}).count -gt 0){
        ForEach ($job in $jobs){
            If($job.Status.IsCompleted -eq $True){
                $data += $job.Pipeline.EndInvoke($job.Status)
                $job.Pipeline.Dispose()
                $job.Status= $Null
                $job.Pipeline= $Null
            }
        }
    }
    Return $data
  }
}