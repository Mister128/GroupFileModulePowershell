function Find-TargetDirectory {
    param(
        [Parameter(Mandatory)]
        [string[]]$AllowedDirectories,
        
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [System.IO.DirectoryInfo[]]$AllDirectories
    )

    if ($null -eq $AllDirectories -or $AllDirectories.Count -eq 0) {
        return $null
    }

    foreach ($dirName in $AllowedDirectories) {
        $match = $AllDirectories | Where-Object Name -eq $dirName
        if ($match) {
            return $match[0]
        }
    }
    return $null
}