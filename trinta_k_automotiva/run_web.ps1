$ErrorActionPreference = 'Stop'

# Use the Windows short path to avoid native hook failures with spaces.
$fileSystem = New-Object -ComObject Scripting.FileSystemObject
$projectPath = $fileSystem.GetFolder($PSScriptRoot).ShortPath
$sdkPath = Join-Path (Split-Path $projectPath -Parent) 'flutter\bin\flutter.bat'
$env:FLUTTER_SUPPRESS_ANALYTICS = 'true'
$env:DART_SUPPRESS_ANALYTICS = 'true'

Push-Location -LiteralPath $projectPath
try {
    Write-Host 'Abra http://localhost:7357 no navegador habitual (sem modo anonimo).'
    & $sdkPath run -d web-server --web-hostname=localhost --web-port=7357
    $runExitCode = $LASTEXITCODE
} finally {
    Pop-Location
}
exit $runExitCode
