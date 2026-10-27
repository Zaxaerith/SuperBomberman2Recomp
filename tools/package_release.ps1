# Super Bomberman 2 Recomp - Official Release Packaging Script
param(
    [string]$Version = "0.1.0-preview"
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path "$PSScriptRoot\..").Path
$buildDir = Join-Path $projectRoot "build"
$stageName = "SuperBomberman2Recomp-windows-x64-v$Version"
$stageRoot = Join-Path $projectRoot "release-stage"
$stageDir = Join-Path $stageRoot $stageName
$distDir = Join-Path $projectRoot "dist"

Write-Host "=== Staging SuperBomberman2Recomp $Version ==="
if (Test-Path $stageDir) {
    Remove-Item -Recurse -Force $stageDir
}
New-Item -ItemType Directory -Path $stageDir -Force | Out-Null
if (-not (Test-Path $distDir)) {
    New-Item -ItemType Directory -Path $distDir -Force | Out-Null
}

# 1. Native x64 Binary (Release mode, test injection disabled)
$exeSrc = Join-Path $buildDir "SuperBomberman2SNESRecomp.exe"
if (-not (Test-Path $exeSrc)) {
    throw "Release executable not found: $exeSrc"
}
Copy-Item $exeSrc -Destination (Join-Path $stageDir "SuperBomberman2SNESRecomp.exe") -Force

# 2. Runtime DLLs
$sdl2Src = Join-Path $buildDir "SDL2.dll"
if (-not (Test-Path $sdl2Src)) {
    throw "SDL2.dll not found in $buildDir"
}
Copy-Item $sdl2Src -Destination (Join-Path $stageDir "SDL2.dll") -Force

$mingwDlls = @("libgcc_s_seh-1.dll", "libstdc++-6.dll", "libwinpthread-1.dll")
foreach ($dll in $mingwDlls) {
    $dllSrc = Join-Path $buildDir $dll
    if (Test-Path $dllSrc) {
        Copy-Item $dllSrc -Destination (Join-Path $stageDir $dll) -Force
    } else {
        $found = (Get-Command $dll -ErrorAction SilentlyContinue)
        if ($found) {
            Copy-Item $found.Source -Destination (Join-Path $stageDir $dll) -Force
        } else {
            throw "MinGW DLL not found: $dll"
        }
    }
}

# 3. recomp-ui GUI Assets (fonts and img)
$assetsSrc = Join-Path $buildDir "assets"
if (-not (Test-Path $assetsSrc)) {
    throw "GUI assets directory not found in $buildDir"
}
Copy-Item $assetsSrc -Destination $stageDir -Recurse -Force

# 4. Mod catalog placeholder
$modPackagesDir = Join-Path $stageDir "mods\preloaded\packages"
New-Item -ItemType Directory -Path $modPackagesDir -Force | Out-Null
Set-Content -Path (Join-Path $modPackagesDir ".gitkeep") -Value ""

# 5. Production Default Configurations
$cfgContent = @"
[General]
Autosave = 0
DisableFrameDelay = 0
SkipLauncher = 0

[Graphics]
WindowSize = Auto
Fullscreen = 0
WindowScale = 3
NewRenderer = 1
IgnoreAspectRatio = 0
NoSpriteLimits = 1
DisplayAspect = 4:3
LinearFiltering = 0
Shader = 
VSync = 1

[Sound]
EnableAudio = 1
Volume = 100
AudioFreq = 32000
AudioChannels = 2
AudioSamples = 512

[KeyMap]
Fullscreen = Alt+Return
Reset = Ctrl+r
Pause = Shift+p
PauseDimmed = p
Turbo = Tab
WindowBigger = Ctrl+Up
WindowSmaller = Ctrl+Down
VolumeUp = Keypad +
VolumeDown = Keypad -
DisplayPerf = f
ToggleRenderer = r
SaveStateMenu = F7
Rewind = F8
Load =      F1,     F2,     F3,     F4,     F5,     F6,     F7,     F8,     F9,     F10
Save = Shift+F1,Shift+F2,Shift+F3,Shift+F4,Shift+F5,Shift+F6,Shift+F7,Shift+F8,Shift+F9,Shift+F10

[GamepadMap]
EnableGamepad1 = true
EnableGamepad2 = true
EnableGamepad3 = true
EnableGamepad4 = true
GamepadDeadzone = 3276
Controls =   DpadUp, DpadDown, DpadLeft, DpadRight, Back, Start, B, A, Y, X, Lb, Rb
ControlsP2 = DpadUp, DpadDown, DpadLeft, DpadRight, Back, Start, B, A, Y, X, Lb, Rb
ControlsP3 = DpadUp, DpadDown, DpadLeft, DpadRight, Back, Start, B, A, Y, X, Lb, Rb
ControlsP4 = DpadUp, DpadDown, DpadLeft, DpadRight, Back, Start, B, A, Y, X, Lb, Rb

[Controller]
SourceP1 = 1
SourceP2 = 2
SourceP3 = 2
SourceP4 = 2

[Rewind]
Enabled = 0
Depth = 60
Interval = 6
"@
[System.IO.File]::WriteAllText((Join-Path $stageDir "config.ini"), $cfgContent)

$keybindsContent = @"
# SNES Controller Keybinds
# Edit values to customize. Restart the game to apply.
# Use SDL key names. Common: A B C ... Z, 0-9, F1-F12, Up Down Left Right,
# Return, Tab, Space, Left Shift, Right Shift, Left Ctrl, Right Ctrl,
# Backspace, Escape, Backslash. Use "None" to leave a button unbound.

[player1]
a       = X
b       = Z
x       = S
y       = A
l       = C
r       = V
start   = Return
select  = Right Shift
up      = Up
down    = Down
left    = Left
right   = Right

[player2]
a       = K
b       = J
x       = I
y       = U
l       = O
r       = P
start   = 1
select  = 2
up      = W
down    = S
left    = A
right   = D

[player3]
a       = Keypad 2
b       = Keypad 1
x       = Keypad 5
y       = Keypad 4
l       = Keypad 7
r       = Keypad 8
start   = Keypad Enter
select  = Keypad +
up      = Keypad 8
down    = Keypad 5
left    = Keypad 4
right   = Keypad 6

[player4]
a       = N
b       = B
x       = H
y       = G
l       = T
r       = Y
start   = 9
select  = 0
up      = I
down    = K
left    = J
right   = L
"@
[System.IO.File]::WriteAllText((Join-Path $stageDir "keybinds.ini"), $keybindsContent)

# 6. Documentation & Licenses
Copy-Item (Join-Path $projectRoot "README.md") -Destination (Join-Path $stageDir "README.md") -Force
Copy-Item (Join-Path $projectRoot "LICENSE") -Destination (Join-Path $stageDir "LICENSE") -Force
Copy-Item (Join-Path $projectRoot "THIRD_PARTY_LICENSES.md") -Destination (Join-Path $stageDir "THIRD_PARTY_LICENSES.md") -Force

Write-Host "=== Performing Strict Whitelist & Blacklist Audit ==="
$bannedExtensions = @(".sfc", ".smc", ".bin", ".rom", ".sav", ".srm", ".o", ".obj", ".ninja", ".c", ".h", ".cpp", ".ps1", ".sh", ".make")
$stagedFiles = Get-ChildItem -Path $stageDir -Recurse -File

$violations = @()
foreach ($item in $stagedFiles) {
    $ext = $item.Extension.ToLower()
    if ($bannedExtensions -contains $ext -and $item.Name -ne ".gitkeep") {
        $violations += "Forbidden extension ($ext): $($item.FullName)"
    }
    if ($item.Name -eq "rom.cfg" -or $item.Name -eq "config.local.ini") {
        $violations += "Forbidden cache or override file: $($item.FullName)"
    }
}

if ($violations.Count -gt 0) {
    throw "Packaging audit failed:`n" + ($violations -join "`n")
}

Write-Host "Staged files audit passed. File list:"
$stagedFiles | Select-Object Name, Length, @{Name="SHA256";Expression={(Get-FileHash $_.FullName -Algorithm SHA256).Hash}} | Format-Table -AutoSize

# 7. Create Zip Archive
$zipName = "$stageName.zip"
$zipPath = Join-Path $distDir $zipName
if (Test-Path $zipPath) {
    Remove-Item -Force $zipPath
}

Write-Host "Creating zip package: $zipPath"
Compress-Archive -Path $stageDir -DestinationPath $zipPath -CompressionLevel Optimal

$zipItem = Get-Item $zipPath
$zipHash = (Get-FileHash $zipPath -Algorithm SHA256).Hash

$shaFile = Join-Path $distDir "SHA256SUMS.txt"
Set-Content -Path $shaFile -Value "$zipHash  $zipName" -Encoding UTF8

Write-Host "=== Package Created Successfully ==="
Write-Host "Path:   $($zipItem.FullName)"
Write-Host "Size:   $($zipItem.Length) bytes ($([Math]::Round($zipItem.Length / 1MB, 2)) MB)"
Write-Host "SHA256: $zipHash"

# Clean up staging directory
Remove-Item -Recurse -Force $stageRoot -ErrorAction SilentlyContinue
