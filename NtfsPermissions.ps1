function GetFolderList
{
[CmdletBinding()]

    param(
        [string]$BasePath,
        [int]$MaxRecurseLevel,
        [int]$CurrentRecurseLevel = 1
    )

    $FolderList = @()
    $BasePath = (Resolve-Path -Path $BasePath).ProviderPath

    foreach ( $item in @(Get-ChildItem -Path $BasePath | Where-Object -FilterScript { $_.PSIsContainer -eq $true }) ){
        if ($CurrentRecurseLevel -eq $MaxRecurseLevel){
            $item.FullName
            $FolderList += $item.FullName
        }
        elseif($CurrentRecurseLevel -lt $MaxRecurseLevel){
            $item.FullName
            $FolderList += $item.FullName
            GetFolderList -BasePath $item.PSPath -MaxRecurseLevel $MaxRecurseLevel -CurrentRecurseLevel ($CurrentRecurseLevel + 1)
        }
    }

}




function Get-NtfsPermissions{
    [CmdletBinding()]

    param(
        [string]$Path,
        [string[]]$Filter = @('NT AUTHORITY','Administrators','BUILTIN','APPLICATION PACKAGE AUTHORITY','NT SERVICE','CREATOR OWNER','IIS APPPOOL'),
        [int]$MaxRecurse = 3
    )


#    $ItemPath = Get-ChildItem -Path $Path -Recurse | Where-Object -FilterScript { $_.PSIsContainer -eq $true } | Select-Object -ExpandProperty FullName
    $folders = GetFolderList -BasePath $Path -MaxRecurseLevel $MaxRecurse

    foreach ($Item in $folders){
        $Acl = Get-Acl -Path $Item    
        $Permissions = $Acl.Access | Add-Member -Name "Path" -MemberType NoteProperty -Value $Item -PassThru

        foreach ($Permission in $Permissions){
            $FilterMatched = $false

            foreach ($f in $Filter){
                if ($Permission.IdentityReference -match $f){
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

Get-NtfsPermissions -Path V:\ -MaxRecurse 2 | Select-Object -Property Path,IdentityReference,FileSystemRights
#GetFolderList -BasePath C:\Users -MaxRecurseLevel 3 -Verbose