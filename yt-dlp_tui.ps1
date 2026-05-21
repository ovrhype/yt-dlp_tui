$ErrorActionPreference = 'Stop'

$global:YtDlpShellRoot = $PSScriptRoot

. (Join-Path $PSScriptRoot 'config\ConfigManager.ps1')
. (Join-Path $PSScriptRoot 'core\YtDlpDetector.ps1')
. (Join-Path $PSScriptRoot 'core\OptionBuilder.ps1')
. (Join-Path $PSScriptRoot 'core\Downloader.ps1')
. (Join-Path $PSScriptRoot 'ui\Menu.ps1')


function Suspend-App {
    Read-Host 'Press Enter to continue' | Out-Null
}

function Invoke-DownloadFlow {
    param(
        [string]$ExecutablePath,
        [hashtable]$SelectionState,
        [pscustomobject]$Config
    )

    if (-not $ExecutablePath) {
        Write-Host ''
        Write-Host 'yt-dlp.exe was not found in PATH.' -ForegroundColor Red
        Suspend-App
        return
    }

    $url = Read-DownloadUrl
    if ([string]::IsNullOrWhiteSpace($url)) {
        Write-Host 'No link entered. Returning to menu.' -ForegroundColor Yellow
        Suspend-App
        return
    }

    $arguments = Get-YtDlpArguments -SelectionState $SelectionState
    Start-Download -ExecutablePath $ExecutablePath -SavePath $Config.savePath -Arguments $arguments -Url $url -SelectionState $SelectionState
    Suspend-App
}

$config = Get-Config
$selectionState = Get-DefaultSelectionState
$shouldExit = $false

while (-not $shouldExit) {
    $detection = Get-YtDlpDetails
    Show-Header -Version $detection.Version -ExecutablePath $detection.Path -SavePath $config.savePath
    Show-MainMenu -SelectionState $selectionState

    $choice = Read-MenuAction

    switch ($choice) {
        '1' {
            $selectionState.VideoQuality = 'Best'
        }
        '2' {
            $selectionState.VideoQuality = '1080p'
        }
        '3' {
            $selectionState.VideoQuality = 'AudioOnly'
        }
        '4' {
            $selectionState.LiveStream = $false
        }
        '5' {
            $selectionState.LiveStream = -not $selectionState.LiveStream
        }
        '6' {
            Invoke-DownloadFlow -ExecutablePath $detection.Path -SelectionState $selectionState -Config $config
        }
        '7' {
            $newPath = Read-SavePath
            if ([string]::IsNullOrWhiteSpace($newPath)) {
                Write-Host 'Path was not changed.' -ForegroundColor Yellow
                Suspend-App
                continue
            }

            $resolvedPath = Set-SavePath -Path $newPath
            $config = Set-ConfigValue -Key 'savePath' -Value $resolvedPath
            Write-Host "Save path updated to: $resolvedPath" -ForegroundColor Green
            Suspend-App
        }
        '8' {
            continue
        }
        '0' {
            $shouldExit = $true
        }
        default {
            Write-Host 'Unknown option. Choose one of the menu numbers.' -ForegroundColor Yellow
            Suspend-App
        }
    }
}