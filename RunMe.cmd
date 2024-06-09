cd /d "%~dp0"
PowerShell Set-ExecutionPolicy Unrestricted
PowerShell .\main.ps1
PowerShell Set-ExecutionPolicy Default
timeout 5 > NUL
