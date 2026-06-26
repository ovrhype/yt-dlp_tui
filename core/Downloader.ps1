function Get-DownloadTargetDetails {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExecutablePath,

        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    $probeArguments = @(
        '--flat-playlist'
        '--dump-single-json'
        '--skip-download'
        '--quiet'
        '--no-warnings'
        '--'
        $Url
    )

    $rawOutput = & $ExecutablePath @probeArguments 2>&1
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        $errorText = ($rawOutput | Out-String).Trim()
        if ([string]::IsNullOrWhiteSpace($errorText)) {
            $errorText = 'yt-dlp did not return metadata for the provided URL.'
        }

        throw "Failed to inspect URL. $errorText"
    }

    $jsonText = ($rawOutput | Out-String).Trim()
    if ([string]::IsNullOrWhiteSpace($jsonText)) {
        throw 'yt-dlp returned empty metadata for the provided URL.'
    }

    try {
        $metadata = $jsonText | ConvertFrom-Json -Depth 100
    }
    catch {
        throw 'yt-dlp returned unreadable metadata for the provided URL.'
    }

    $entries = @($metadata.entries | Where-Object { $_ -ne $null })
    $isPlaylist = $metadata._type -eq 'playlist' -or $entries.Count -gt 0

    $playlistEntries = @()
    if ($isPlaylist) {
        for ($index = 0; $index -lt $entries.Count; $index++) {
            $entry = $entries[$index]
            $title = $entry.title

            if ([string]::IsNullOrWhiteSpace($title)) {
                $title = $entry.id
            }

            if ([string]::IsNullOrWhiteSpace($title)) {
                $title = "Video $($index + 1)"
            }

            $playlistEntries += [pscustomobject]@{
                Index = $index + 1
                Title = $title
            }
        }
    }

    return [pscustomobject]@{
        IsPlaylist = $isPlaylist
        Entries    = $playlistEntries
        Title      = $metadata.title
    }
}

function ConvertTo-PlaylistItemsArgument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Selection,

        [Parameter(Mandatory = $true)]
        [int]$MaxIndex
    )

    $normalizedSelection = ($Selection -replace '\s+', '')
    if ([string]::IsNullOrWhiteSpace($normalizedSelection)) {
        return $null
    }

    if ($normalizedSelection -notmatch '^[0-9,-]+$') {
        throw 'Use only numbers, commas, and hyphens. Example: 1,3-5'
    }

    $segments = $normalizedSelection.Split(',', [System.StringSplitOptions]::RemoveEmptyEntries)
    if ($segments.Count -eq 0) {
        throw 'Enter at least one playlist item number.'
    }

    foreach ($segment in $segments) {
        if ($segment -match '^\d+$') {
            $itemIndex = [int]$segment
            if ($itemIndex -lt 1 -or $itemIndex -gt $MaxIndex) {
                throw "Playlist item $itemIndex is out of range. Valid range: 1-$MaxIndex"
            }

            continue
        }

        if ($segment -match '^(\d+)-(\d+)$') {
            $startIndex = [int]$Matches[1]
            $endIndex = [int]$Matches[2]

            if ($startIndex -gt $endIndex) {
                throw "Invalid range '$segment'. Start must be less than or equal to end."
            }

            if ($startIndex -lt 1 -or $endIndex -gt $MaxIndex) {
                throw "Playlist range '$segment' is out of range. Valid range: 1-$MaxIndex"
            }

            continue
        }

        throw "Invalid playlist selection segment '$segment'."
    }

    return $segments -join ','
}

function Start-Download {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExecutablePath,

        [Parameter(Mandatory = $true)]
        [string]$SavePath,

        [Parameter(Mandatory = $false)]
        [string[]]$Arguments = @(),

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string]$PlaylistItems,

        [Parameter(Mandatory = $true)]
        [string]$Url,

        [Parameter(Mandatory = $true)]
        [hashtable]$SelectionState
    )

    $commandArguments = [System.Collections.Generic.List[string]]::new()
    $commandArguments.Add('-P')
    $commandArguments.Add($SavePath)

    foreach ($argument in $Arguments) {
        $commandArguments.Add($argument)
    }

    if (-not [string]::IsNullOrWhiteSpace($PlaylistItems)) {
        $commandArguments.Add('--playlist-items')
        $commandArguments.Add($PlaylistItems)
    }

    $commandArguments.Add('--')
    $commandArguments.Add($Url)

    Write-Host ''
    Write-Host 'Starting download...' -ForegroundColor Green
    Write-Host "Mode: $(Get-SelectionSummary -SelectionState $SelectionState)"
    Write-Host ''

    & $ExecutablePath @commandArguments
    $exitCode = $LASTEXITCODE

    Write-Host ''
    if ($exitCode -eq 0) {
        Write-Host 'Download completed.' -ForegroundColor Green
    }
    else {
        Write-Host "yt-dlp exited with code $exitCode." -ForegroundColor Red
    }
}