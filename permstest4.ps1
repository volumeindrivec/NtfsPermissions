function Get-NtfsPermsTest4{
  [CmdletBinding()]

  param(
    [string[]]$Filter = @('NT AUTHORITY*','Administrators*','BUILTIN*','NT SERVICE*')
  )


  $ItemPath = Get-ChildItem -Path C:\ | Where-Object -FilterScript { $_.PSIsContainer -eq $true } | Select-Object -ExpandProperty FullName
  
  $Permissions = @()
  
  foreach ($Item in $ItemPath){
    $Acl = Get-Acl -Path $Item
    $Access = $Acl.Access
    foreach($accessItem in $Access) {
      $found = $false
      $idx = 0
      while(($found -eq $false) -and ($idx -lt $Filter.Length)) {
        if($($accessItem.IdentityReference.ToString()) -like $($Filter[$idx])) {
          $found = $true
        }
        $idx++
      }
      if($found -eq $false) {
        $Permissions += $accessItem | Add-Member -Name "Path" -MemberType NoteProperty -Value $Item -PassThru 
      }
    }
  }
  
  Write-Output $Permissions | Select-Object -Property Path,IdentityReference,FileSystemRights
}

Get-NtfsPermsTest4