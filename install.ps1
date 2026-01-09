# Hive Code Bootstrap Installer for Windows
# Usage: irm https://raw.githubusercontent.com/fanning/hive-hiveskill/master/install.ps1 | iex

Write-Host ""
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "  Hive Code Bootstrap Installer" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ""

# Set install location
$InstallPath = "$env:USERPROFILE\cc.bat"
$SessionsDir = "$env:USERPROFILE\.claude-sessions"
$LogsDir = "$SessionsDir\logs"
$SessionsFile = "$SessionsDir\sessions.json"

# Create directories
if (-not (Test-Path $SessionsDir)) {
    New-Item -ItemType Directory -Path $SessionsDir -Force | Out-Null
}
if (-not (Test-Path $LogsDir)) {
    New-Item -ItemType Directory -Path $LogsDir -Force | Out-Null
}

# Initialize sessions.json if needed
if (-not (Test-Path $SessionsFile)) {
    '{"version":"1.0","lastUpdated":"","sessions":[]}' | Out-File -FilePath $SessionsFile -Encoding UTF8
}

# Download the bootstrap script
$ScriptUrl = "https://raw.githubusercontent.com/fanning/hive-hiveskill/master/cc.bat"

Write-Host "Downloading Hive Code bootstrap script..."

try {
    Invoke-WebRequest -Uri $ScriptUrl -OutFile $InstallPath -UseBasicParsing

    Write-Host ""
    Write-Host "===================================================" -ForegroundColor Green
    Write-Host "  Installation complete!" -ForegroundColor Green
    Write-Host "===================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Command: cc"
    Write-Host "  Location: $InstallPath"
    Write-Host ""
    Write-Host "  Quick start:"
    Write-Host "    cc -h              Show help"
    Write-Host '    cc "Project"       Start named session'
    Write-Host "    cc -r              Restore a session"
    Write-Host ""

    # Add to PATH if not already there
    $UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($UserPath -notlike "*$env:USERPROFILE*") {
        Write-Host "  Note: Add $env:USERPROFILE to your PATH to run 'cc' from anywhere" -ForegroundColor Yellow
    }

    Write-Host "===================================================" -ForegroundColor Green
}
catch {
    Write-Host "Failed to download: $_" -ForegroundColor Red
    exit 1
}
