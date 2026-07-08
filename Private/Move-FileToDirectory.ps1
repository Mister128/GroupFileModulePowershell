function Move-FilesToDirectory {
    <#
    .SYNOPSIS
        Moves files to target directory with overwrite handling.
    
    .PARAMETER Files
        List of files to move.
    
    .PARAMETER TargetDirectory
        Destination directory.
    
    .PARAMETER Force
        Switch to overwrite existing files.
    #>
    param(
        [Parameter(Mandatory)]
        [System.Collections.Generic.List[object]]$Files,
        
        [Parameter(Mandatory)]
        [System.IO.DirectoryInfo]$TargetDirectory,
        
        [switch]$Force
    )

    foreach ($file in $Files) {
        $destinationPath = Join-Path -Path $TargetDirectory.FullName -ChildPath $file.Name

        if (Test-Path -LiteralPath $destinationPath) {
            if ($Force) {
                Write-Verbose "Overwriting: $destinationPath"
                Move-Item -LiteralPath $file.FullName -Destination $destinationPath -Force
            } else {
                Write-Verbose "Skipping (exists): $destinationPath"
            }
        } else {
            Move-Item -LiteralPath $file.FullName -Destination $destinationPath
        }
    }
}