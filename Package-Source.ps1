[CmdletBinding()]
param(
    [string]$OutputPath = (Join-Path $PSScriptRoot 'dist\window-layout-launcher-source.zip')
)

$ErrorActionPreference = 'Stop'
$items = @('src', 'defaults', 'tests', 'README.md', 'LICENSE', 'Run-WindowLayoutLauncher.ps1') |
    ForEach-Object { Join-Path $PSScriptRoot $_ }

$outputDirectory = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
Remove-Item -LiteralPath $OutputPath -Force -ErrorAction SilentlyContinue
Compress-Archive -Path $items -DestinationPath $OutputPath -CompressionLevel Optimal
Write-Output "Created source package: $OutputPath"
