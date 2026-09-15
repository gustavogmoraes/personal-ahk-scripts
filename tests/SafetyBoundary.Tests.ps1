$ErrorActionPreference = 'Stop'
$source = Get-Content -Raw "$PSScriptRoot\..\src\WindowLayoutLauncher.ahk"
$forbidden = @('SetWindowsHookEx', 'LoadLibrary', 'OpenProcess', 'WriteProcessMemory', 'CreateRemoteThread')
foreach ($token in $forbidden) {
    if ($source -match [regex]::Escape($token)) {
        throw "Safety boundary violated: forbidden token $token"
    }
}
Write-Output 'Safety boundary tests passed.'
