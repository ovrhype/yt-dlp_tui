function Get-DefaultSelectionState {
    return @{
        VideoQuality = 'Best'
        LiveStream   = $false
    }
}

function Get-VideoQualityLabel {
    param(
        [Parameter(Mandatory = $true)]
        [string]$VideoQuality
    )

    switch ($VideoQuality) {
        'Best' { return 'Best' }
        '1080p' { return '1080p' }
        'AudioOnly' { return 'Audio only' }
        default { return 'Best' }
    }
}

function Get-YtDlpArguments {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$SelectionState
    )

    $arguments = [System.Collections.Generic.List[string]]::new()

    switch ($SelectionState.VideoQuality) {
        'Best' {
            $arguments.Add('-f')
            $arguments.Add('bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best')
        }
        '1080p' {
            $arguments.Add('-f')
            $arguments.Add('bv*[height<=1080]+ba')
        }
        'AudioOnly' {
            $arguments.Add('--extract-audio')
        }
    }

    if ($SelectionState.LiveStream) {
        $arguments.Add('--live-from-start')
    }

    return , $arguments.ToArray()
}

function Get-SelectionSummary {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$SelectionState
    )

    $liveStreamLabel = if ($SelectionState.LiveStream) { 'Yes' } else { 'No' }
    return "Video quality: $(Get-VideoQualityLabel -VideoQuality $SelectionState.VideoQuality) | Live Stream: $liveStreamLabel"
}