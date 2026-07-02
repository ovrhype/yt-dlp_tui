function Get-CheckMark {
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Selected
    )

    if ($Selected) {
        return '[x]'
    }

    return '[ ]'
}

function Show-Header {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Version,

        [AllowNull()]
        [string]$ExecutablePath,

        [Parameter(Mandatory = $true)]
        [string]$SavePath
    )

    Clear-Host
    Write-Host 'yt-dlp TUI' -ForegroundColor Cyan
    Write-Host '-------------' -ForegroundColor Cyan
    Write-Host "yt-dlp version: $Version"
    Write-Host "yt-dlp path: $(if ($ExecutablePath) { $ExecutablePath } else { 'not found in PATH' })"
    Write-Host "Save path: $SavePath"
    Write-Host ''
}

function Show-MainMenu {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$SelectionState
    )

    Write-Host 'Video quality'
    Write-Host "1. $(Get-CheckMark -Selected ($SelectionState.VideoQuality -eq 'Best')) Best"
    Write-Host "2. $(Get-CheckMark -Selected ($SelectionState.VideoQuality -eq '1080p')) 1080p"
    Write-Host "3. $(Get-CheckMark -Selected ($SelectionState.VideoQuality -eq 'AudioOnly')) Audio only"
    Write-Host "4. $(Get-CheckMark -Selected ($SelectionState.VideoQuality -eq 'AudioOnlyMp3')) Audio only (MP3 format)"
    Write-Host ''
    Write-Host 'Download live stream from start'
    Write-Host "5. $(Get-CheckMark -Selected (-not $SelectionState.LiveStream)) No"
    Write-Host "6. $(Get-CheckMark -Selected $SelectionState.LiveStream) Yes"
    Write-Host ''
    Write-Host "Current selection: $(Get-SelectionSummary -SelectionState $SelectionState)" -ForegroundColor DarkCyan
    Write-Host ''
    Write-Host '7. Enter link and download'
    Write-Host '8. Change save path'
    Write-Host '9. Refresh screen'
    Write-Host '0. Exit'
    Write-Host ''
}

function Read-MenuAction {
    Read-Host 'Choose an option'
}

function Read-DownloadUrl {
    Write-Host ''
    return (Read-Host 'Enter video URL')
}

function Show-PlaylistEntries {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Entries,

        [AllowNull()]
        [string]$PlaylistTitle
    )

    Write-Host ''
    if ([string]::IsNullOrWhiteSpace($PlaylistTitle)) {
        Write-Host 'Playlist detected.' -ForegroundColor Cyan
    }
    else {
        Write-Host "Playlist detected: $PlaylistTitle" -ForegroundColor Cyan
    }

    Write-Host 'Choose what to download from this playlist:'
    foreach ($entry in $Entries) {
        Write-Host ("{0}. {1}" -f $entry.Index, $entry.Title)
    }
    Write-Host ''
}

function Read-PlaylistItemSelection {
    Write-Host 'Press Enter to download all items.' -ForegroundColor DarkCyan
    Write-Host 'Type 0 to cancel this download.' -ForegroundColor DarkCyan
    return (Read-Host 'Enter playlist items (example: 1,3-5)')
}

function Read-SavePath {
    Write-Host ''
    return (Read-Host 'Enter a folder path')
}