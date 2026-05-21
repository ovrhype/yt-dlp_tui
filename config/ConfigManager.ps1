function Get-AppRoot {
    if ($global:YtDlpShellRoot) {
        return $global:YtDlpShellRoot
    }

    return (Split-Path -Parent $PSScriptRoot)
}

function Get-ConfigPath {
    Join-Path (Get-AppRoot) 'config.json'
}

function Initialize-ConfigFile {
    $configPath = Get-ConfigPath
    if (Test-Path -LiteralPath $configPath) {
        return
    }

    $defaultConfig = [pscustomobject]@{
        savePath = [Environment]::GetFolderPath('MyVideos')
    }

    $defaultConfig | ConvertTo-Json | Set-Content -LiteralPath $configPath -Encoding UTF8
}

function Get-Config {
    Initialize-ConfigFile

    $configPath = Get-ConfigPath
    try {
        $config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
    }
    catch {
        throw "Failed to read config file at '$configPath'. Fix the JSON and try again."
    }

    if (-not $config.savePath) {
        $config | Add-Member -NotePropertyName 'savePath' -NotePropertyValue ([Environment]::GetFolderPath('MyVideos'))
        $config | ConvertTo-Json | Set-Content -LiteralPath $configPath -Encoding UTF8
    }

    return $config
}

function Set-ConfigValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Key,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Value
    )

    $configPath = Get-ConfigPath
    $config = Get-Config

    if ($config.PSObject.Properties.Name -contains $Key) {
        $config.$Key = $Value
    }
    else {
        $config | Add-Member -NotePropertyName $Key -NotePropertyValue $Value
    }

    $config | ConvertTo-Json | Set-Content -LiteralPath $configPath -Encoding UTF8
    return $config
}

function Set-SavePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolvedPath = [Environment]::ExpandEnvironmentVariables($Path.Trim())

    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        New-Item -ItemType Directory -Path $resolvedPath -Force | Out-Null
    }

    return (Resolve-Path -LiteralPath $resolvedPath).Path
}