function Get-YtDlpCommand {
    $commands = @('yt-dlp.exe', 'yt-dlp')

    foreach ($commandName in $commands) {
        $command = Get-Command $commandName -ErrorAction SilentlyContinue
        if ($command) {
            return $command
        }
    }

    return $null
}

function Get-YtDlpDetails {
    $command = Get-YtDlpCommand
    if (-not $command) {
        return [pscustomobject]@{
            Path = $null
            Version = 'not detected'
        }
    }

    try {
        $version = (& $command.Source --version 2>$null | Select-Object -First 1).Trim()
        if ([string]::IsNullOrWhiteSpace($version)) {
            $version = 'detected, version unavailable'
        }
    }
    catch {
        $version = 'detected, version unavailable'
    }

    return [pscustomobject]@{
        Path = $command.Source
        Version = $version
    }
}