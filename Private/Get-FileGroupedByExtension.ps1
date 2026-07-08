function Get-FilesGroupedByExtension {
    <#
    .SYNOPSIS
        Groups files by their extensions.
    
    .PARAMETER Files
        Array of FileInfo objects to group.
    #>
    param(
        [Parameter(Mandatory)]
        [System.IO.FileInfo[]]$Files
    )

    $filesByExtension = @{}
    
    foreach ($file in $Files) {
        $ext = $file.Extension.ToLower()
        
        if (-not $filesByExtension.ContainsKey($ext)) {
            $filesByExtension[$ext] = [System.Collections.Generic.List[object]]::new()
        }
        
        $filesByExtension[$ext].Add($file)
    }

    return $filesByExtension
}