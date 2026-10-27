param(
    [Parameter(Mandatory=$true)]
    [string]$ScriptPath,
    [string]$DumpDir = "D:\Project\GameRecomp\SuperBomberman2Recomp\dumps",
    [hashtable]$EnvVars = @{},
    [int]$TimeoutSec = 45
)

$ErrorActionPreference = "Stop"

$projectRoot = "D:\Project\GameRecomp\SuperBomberman2Recomp"
$buildExe = "$projectRoot\build\SuperBomberman2SNESRecomp.exe"
$buildDll = "$projectRoot\build\SDL2.dll"
$romPath = "$projectRoot\Super Bomberman 2 (USA).sfc"

if (!(Test-Path $buildExe)) {
    throw "Executable not found at $buildExe"
}

$stage = "C:\MYAPPLY\_sb2_run"
New-Item -ItemType Directory -Path $stage -Force | Out-Null
Copy-Item $buildExe "$stage\SuperBomberman2SNESRecomp.exe" -Force
Copy-Item $buildDll "$stage\SDL2.dll" -Force

if (!(Test-Path $DumpDir)) {
    New-Item -ItemType Directory -Path $DumpDir -Force | Out-Null
}

$prevDumpDir = $env:SNESRECOMP_DUMP_DIR
$env:SNESRECOMP_DUMP_DIR = $DumpDir

foreach ($k in $EnvVars.Keys) {
    [System.Environment]::SetEnvironmentVariable($k, $EnvVars[$k])
}

$origDir = Get-Location
try {
    Set-Location $stage
    $cmd = "SuperBomberman2SNESRecomp.exe --rom `"$romPath`" --script `"$ScriptPath`" --no-launcher"
    cmd.exe /c "$cmd"
} finally {
    Set-Location $origDir
    $env:SNESRECOMP_DUMP_DIR = $prevDumpDir
    foreach ($k in $EnvVars.Keys) {
        [System.Environment]::SetEnvironmentVariable($k, $null)
    }
    Remove-Item -Recurse -Force $stage -ErrorAction SilentlyContinue
}
