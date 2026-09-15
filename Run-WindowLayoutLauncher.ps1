[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$runtime = Join-Path $env:LOCALAPPDATA 'Programs\AutoHotkey\v2\AutoHotkey64.exe'
$scriptPath = Join-Path $PSScriptRoot 'src\WindowLayoutLauncher.ahk'

if (-not (Test-Path -LiteralPath $runtime)) {
    throw "AutoHotkey v2 was not found at $runtime. Install AutoHotkey.AutoHotkey with winget first."
}

Start-Process -FilePath $runtime -ArgumentList ('"{0}"' -f $scriptPath)
