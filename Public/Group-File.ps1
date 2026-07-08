function Group-File {
    <#
    .SYNOPSIS
        Groups files into directories based on extension rules defined in a JSON config.
    
    .DESCRIPTION
        Reads GroupFile.config.json from the user's config directory to map file 
        extensions to target directories. Files are moved to the first existing 
        allowed directory. If -Force is used, missing directories are created and 
        existing files are overwritten.
    
    .PARAMETER Path
        Target directory to process. Defaults to current directory.
    
    .PARAMETER Only
        Processes only rules containing at least one of the specified extensions.
    
    .PARAMETER Force
        Creates missing target directories and overwrites existing destination files.
    
    .PARAMETER Config
        Opens the directory containing the configuration file for editing.

    .NOTES
        On first run, the module creates a default config and opens it for editing.
        Run the command again to actually organize your files.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateScript({ Test-Path $_ -PathType Container })]
        [string]$Path = ".",

        [string[]]$Only,
        [switch]$Force,
        [switch]$OpenConfig
    )

    if ($OpenConfig) {
        $configDir = Get-GroupFileConfigDir
        if (-not (Test-Path -Path $configDir)) {
            New-Item -Path $configDir -ItemType Directory -Force | Out-Null
        }
        Invoke-Item -Path $configDir
        return
    }

    Write-Verbose "Starting file grouping in: $Path"

    # 1. Load config
    $config = Get-GroupFileConfig
    if ($null -eq $config) {
        return 
    }

    # 2. Gather files and directories
    $allFiles = Get-ChildItem -Path $Path -File
    $allDirs = @(Get-ChildItem -Path $Path -Directory | Where-Object { -not $_.Name.StartsWith('.') })

    if ($allFiles.Count -eq 0) {
        Write-Verbose "No files found in $Path. Exiting."
        return
    }

    # 3. Group files by extension
    $filesByExtension = Get-FilesGroupedByExtension -Files $allFiles

    # Normalize -Only parameter
    $normalizedOnly = if ($Only) { $Only | ForEach-Object { $_.ToLower() } } else { $null }

    # 4. Process rules
    foreach ($rule in $config.Rules) {
        $ruleExts = $rule.Extensions | ForEach-Object { $_.ToLower() }

        # Skip rule if -Only is used and doesn't match
        if ($normalizedOnly) {
            $hasMatch = $false
            foreach ($ext in $ruleExts) {
                if ($ext -in $normalizedOnly) { 
                    $hasMatch = $true
                    break 
                }
            }
            if (-not $hasMatch) { continue }
        }

        # Get target files for this rule
        $targetFiles = [System.Collections.Generic.List[object]]::new()
        foreach ($ext in $ruleExts) {
            if ($filesByExtension.ContainsKey($ext)) {
                $targetFiles.AddRange($filesByExtension[$ext])
            }
        }

        if ($targetFiles.Count -eq 0) { continue }

        # Find or create target directory
        $targetDir = Find-TargetDirectory -AllowedDirectories $rule.AllowedDirectories -AllDirectories $allDirs
        
        if (-not $targetDir) {
            $targetDir = New-TargetDirectoryIfNeeded -Path $Path -DefaultDirectory $rule.DefaultDirectory -Force:$Force -AllDirectories ([ref]$allDirs)
        }

        if (-not $targetDir) {
            Write-Warning "No target directory found for [$($rule.Extensions -join ', ')] and -Force is not specified. Skipping $($targetFiles.Count) files."
            continue
        }

        # Move files
        Write-Verbose "Processing $($targetFiles.Count) file(s) to '$($targetDir.Name)'."
        Move-FilesToDirectory -Files $targetFiles -TargetDirectory $targetDir -Force:$Force
    }

    Write-Verbose "Finish sort file(s)"
}