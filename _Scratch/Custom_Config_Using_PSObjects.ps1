$RepoSyncServer = "Repo-001"

$customConfig = @(
  [PSCustomObject]@{
    FolderName   = "Repo_sync"
    ComputerName = $RepoSyncServer
  },
  [PSCustomObject]@{
    FolderName   = "Audit_Logged_Users"
    ComputerName = "SomeADClient"
  }
)


$customConfig