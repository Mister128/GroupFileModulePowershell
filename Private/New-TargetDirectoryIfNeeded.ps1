function New-TargetDirectoryIfNeeded {
    <#
    .SYNOPSIS
        Creates target directory if -Force is specified and directory doesn't exist.
    
    .PARAMETER Path
        Base path where directory should be created.
    
    .PARAMETER DefaultDirectory
        Name of the directory to create.
    
    .PARAMETER Force
        Switch to enable directory creation.
    
    .PARAMETER AllDirectories
        Reference to the array of existing directories (will be updated).
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        
        [Parameter(Mandatory)]
        [string]$DefaultDirectory,
        
        [switch]$Force,
        
        [Parameter(Mandatory)]
        [ref]$AllDirectories
    )

    if ($Force) {
        $newDirPath = Join-Path -Path $Path -ChildPath $DefaultDirectory
        Write-Verbose "Directory not found. Creating: $newDirPath"
        
        if ($PSCmdlet.ShouldProcess($newDirPath, "Create directory")) {
            $newDir = New-Item -Path $newDirPath -ItemType Directory -Force
            $AllDirectories.Value += $newDir
            return $newDir
        }
    }
    return $null
}