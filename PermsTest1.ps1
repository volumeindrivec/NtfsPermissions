function Get-PermsTest1{
    [CmdletBinding()]
    param()

    $ItemPath = Get-ChildItem -Path C:\ | Where-Object -FilterScript { $_.PSIsContainer -eq $true } | Select-Object -ExpandProperty FullName

    foreach ($Item in $ItemPath){
    
        $Acl = Get-Acl -Path $Item
        $Permissions = $Acl.Access | Add-Member -Name "Path" -MemberType NoteProperty -Value $Item -PassThru

        foreach ($Permission in $Permissions){
            $un = $Permission.IdentityReference.ToString()
            if( ($un -like "*NT AUTHORITY*") -or 
                ($un -like "*APPLICATION*")
            ){
                Write-Verbose "Pattern matched -- $un"
            }
            else{
                Write-Output $Permission | Select-Object -Property Path,IdentityReference,FileSystemRights             
            }
        }


    }        
}

Get-PermsTest1 -Verbose 