function Get-NtfsPermsTest2{
    [CmdletBinding()]

    param(
        [string]$Path,
        [string[]]$Filter = @('NT AUTHORITY','Administrators','BUILTIN','APPLICATION PACKAGE AUTHORITY','NT SERVICE','CREATOR OWNER')
    )


    $ItemPath = Get-ChildItem -Path $Path -Recurse | Where-Object -FilterScript { $_.PSIsContainer -eq $true } | Select-Object -ExpandProperty FullName

    foreach ($Item in $ItemPath){    
        $Acl = Get-Acl -Path $Item    
        $Permissions = $Acl.Access | Add-Member -Name "Path" -MemberType NoteProperty -Value $Item -PassThru

        foreach ($Permission in $Permissions){
            $un = $Permission.IdentityReference.ToString()
            $FilterMatched = $false
            foreach ($f in $Filter){

                if ($un -match $f){
                    $FilterMatched = $true
                    Write-Verbose "Pattern matched - $f"
                    Break
                }
            }

            if ($FilterMatched -eq $false){
                Write-Output $Permission
            }

        }
    }              
}

Get-NtfsPermsTest2 -Path Z:\ | Select-Object -Property Path,IdentityReference,FileSystemRights