<#
.SYNOPSIS
    Recursively reads files from given directories that match specified file extensions,
    excluding files located in folders whose names contain any of the specified exclude patterns.
#>

[CmdletBinding()]
param(
    # ⬇⬇⬇ 1) Autoriser plusieurs dossiers
    [Parameter(Mandatory = $true, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('Path')]
    [ValidateScript({ 
        if (-not (Test-Path -Path $_ -PathType Container)) {
            throw "Directory '$_' does not exist."
        }
        $true
    })]
    [string[]]$Directory,   # ⬅⬅⬅ passé en [string[]]

    [Parameter(Mandatory = $true)]
    [string[]]$Extensions,

    [Parameter(Mandatory = $false)]
    [string[]]$ExcludeFolderPattern = @()
)

function Write-FileDetails {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$FileInfo
    )

    Write-Output $FileInfo.Name
    Write-Output "-----------------------------------------"
    Write-Output $FileInfo.FullName
    Write-Output "-----------------------------------------"

    try {
        $content = Get-Content -Path $FileInfo.FullName -Raw -ErrorAction Stop
        Write-Output $content
    }
    catch {
        Write-Output "Error reading file content: $($_.Exception.Message)"
    }

    Write-Output "========================"
}

# ⬇⬇⬇ 2) Ici, -Path accepte $Directory comme tableau sans autre changement
Get-ChildItem -Path $Directory -Recurse -File |
    Where-Object {
        $exclude = $false
        foreach ($pattern in $ExcludeFolderPattern) {
            if ($_.DirectoryName.Contains($pattern)) {  # case-sensitive comme dans tes commentaires
                $exclude = $true
                break
            }
        }
        -not $exclude
    } |
    Where-Object { $Extensions -contains $_.Extension } |  # -contains est insensible à la casse
    ForEach-Object { Write-FileDetails -FileInfo $_ }
