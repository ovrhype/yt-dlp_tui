# yt-dlp TUI

Simple PowerShell app for Windows Terminal that wraps `yt-dlp.exe` with a small interactive menu.

When you use the `Enter link and download` action with a playlist URL, the app inspects the playlist, shows the video titles, and lets you choose which items to download.

## Run

```powershell
pwsh -ExecutionPolicy Bypass -File .\yt-dlp_tui.ps1
```

`yt-dlp.exe` must be available in PATH.