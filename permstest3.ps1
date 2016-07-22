function Get-NtfsPermsTest3{
  [CmdletBinding()]

  param(
    [string[]]$Filter = @('NT AUTHORITY','Administrators','BUILTIN')
  )


  $ItemPath = Get-ChildItem -Path C:\Users | Where-Object -FilterScript { $_.PSIsContainer -eq $true } | Select-Object -ExpandProperty FullName
  
  foreach ($Item in $ItemPath){
      $Acl = Get-Acl -Path $Item
      $Permissions = @()
      $Access = $Acl.Access
      foreach($accessItem in $Access) {
        foreach($filterItem in $Filter) {
          if($accessItem.IdentityReference -notmatch $filterItem) {
            $Permissions += $accessItem | Add-Member -Name "Path" -MemberType NoteProperty -Value $Item -PassThru -Force
          }
        }        
      }        
      Write-Output $Permissions | Select-Object -Property Path,IdentityReference,FileSystemRights
  }
}

Get-NtfsPermsTest3 -Verbose 