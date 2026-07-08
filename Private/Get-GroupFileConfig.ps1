function Get-GroupFileConfigDir {
    <#
    .SYNOPSIS
        Returns the OS-specific config directory path.
    #>
    [CmdletBinding()]
    param()

    if ($isWindows) {
        return Join-Path -Path $env:APPDATA -ChildPath "GroupFile"
    } else {
        return Join-Path -Path $HOME -ChildPath ".config/GroupFile"
    }
}

function Get-GroupFileConfig {
    <#
    .SYNOPSIS
        Loads the configuration file, creating a default one if it doesn't exist.
    #>
    [CmdletBinding()]
    param()
    
    $configDir = Get-GroupFileConfigDir
    $configPath = Join-Path -Path $configDir -ChildPath "GroupFile.config.json"

    if (-not (Test-Path -Path $configPath)) {
        Write-Verbose "Config not found. Creating default at: $configPath"
        
        if (-not (Test-Path -Path $configDir)) {
            New-Item -Path $configDir -ItemType Directory -Force | Out-Null
        }

        $defaultConfig = Get-DefaultConfig | ConvertTo-Json -Depth 5
        Set-Content -Path $configPath -Value $defaultConfig -Encoding UTF8
        
        Write-Warning "Default config created at: $configDir. Please edit it and run again."
        Invoke-Item -Path $configDir
        return $null
    }

    return Get-Content -Path $configPath -Raw | ConvertFrom-Json
}