function Start-Download {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExecutablePath,

        [Parameter(Mandatory = $true)]
        [string]$SavePath,

        [Parameter(Mandatory = $false)]
        [string[]]$Arguments = @(),

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