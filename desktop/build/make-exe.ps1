# =====================================================================
#  LANTERNDEEP -> standalone Windows app (.exe)
#  No Node.js needed. Just an internet connection + PowerShell.
# =====================================================================
$ErrorActionPreference = 'Stop'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$ver  = '33.4.11'
$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$game = Join-Path $here '..\..\index.html'
$out  = Join-Path $here '..\..\Lanterndeep'
$zip  = Join-Path $env:TEMP "electron-v$ver-win32-x64.zip"
$url  = "https://github.com/electron/electron/releases/download/v$ver/electron-v$ver-win32-x64.zip"

function Say($t, $c='Gray'){ Write-Host "  $t" -ForegroundColor $c }

Write-Host ''
Write-Host '  ============================================' -ForegroundColor DarkYellow
Write-Host '   LANTERNDEEP - app builder' -ForegroundColor Yellow
Write-Host '  ============================================' -ForegroundColor DarkYellow
Write-Host ''

if (-not (Test-Path $game)) {
  Say 'index.html not found. Keep the repository structure intact.' 'Red'
  Write-Host ''; Read-Host '  Press Enter to close'; exit 1
}

# --- 1) Electron runtime ---
if (Test-Path $zip) {
  Say ("Electron is already downloaded, reusing it. ({0} MB)" -f [math]::Round((Get-Item $zip).Length/1MB)) 'DarkGray'
} else {
  Say 'Downloading Electron (~100 MB, 1-5 min depending on your connection)...' 'Cyan'
  $tmp = "$zip.part"
  Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
  Move-Item $tmp $zip -Force
  Say 'Download complete.' 'Green'
}

# --- 2) Unpack ---
Say 'Unpacking (this can take a minute)...' 'Cyan'
if (Test-Path $out) { Remove-Item $out -Recurse -Force }
try {
  New-Item -ItemType Directory -Path $out -Force | Out-Null
  Expand-Archive -Path $zip -DestinationPath $out -Force
} catch {
  Say 'Expand-Archive failed, trying .NET...' 'DarkGray'
  if (Test-Path $out) { Remove-Item $out -Recurse -Force }
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::ExtractToDirectory($zip, $out)
}
if (-not (Test-Path (Join-Path $out 'electron.exe'))) {
  Say 'The archive is not what we expected. Delete this file and try again:' 'Red'
  Say $zip 'DarkGray'
  Write-Host ''; Read-Host '  Press Enter to close'; exit 1
}

# --- 3) Drop the game in ---
Say 'Packaging the game...' 'Cyan'
$app = Join-Path $out 'resources\app'
New-Item -ItemType Directory -Path $app -Force | Out-Null
Copy-Item $game                            (Join-Path $app 'index.html') -Force
Copy-Item (Join-Path $here 'main.js')      $app -Force
Copy-Item (Join-Path $here 'package.json') $app -Force
Copy-Item (Join-Path $here 'icon.png')     $app -Force
Copy-Item (Join-Path $here 'icon.ico')     (Join-Path $out 'icon.ico') -Force

# --- 4) Rename ---
$exe = Join-Path $out 'Lanterndeep.exe'
Move-Item (Join-Path $out 'electron.exe') $exe -Force
Get-ChildItem (Join-Path $out 'locales') -Filter *.pak -EA SilentlyContinue |
  Where-Object { $_.Name -notin @('en-US.pak','en-GB.pak') } | Remove-Item -Force -EA SilentlyContinue

# --- 5) Desktop shortcut ---
try {
  $ws = New-Object -ComObject WScript.Shell
  $lnk = $ws.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Desktop')) 'Lanterndeep.lnk'))
  $lnk.TargetPath       = $exe
  $lnk.WorkingDirectory = $out
  $lnk.IconLocation     = (Join-Path $out 'icon.ico')
  $lnk.Description      = 'Lanterndeep - a cozy mining roguelite'
  $lnk.Save()
  Say 'Shortcut placed on the desktop.' 'Green'
} catch { Say 'Could not create the shortcut (not important).' 'DarkGray' }

$mb = [math]::Round((Get-ChildItem $out -Recurse -Force | Measure-Object Length -Sum).Sum/1MB)
Write-Host ''
Write-Host '  ============================================' -ForegroundColor DarkYellow
Say 'DONE!' 'Green'
Say $exe 'White'
Say "Folder size: $mb MB - you can move the whole folder anywhere." 'DarkGray'
Say 'Note: Windows may warn about an unknown publisher -> Run anyway.' 'DarkGray'
Write-Host '  ============================================' -ForegroundColor DarkYellow
Write-Host ''

$ans = Read-Host '  Launch the game now? (Y/n)'
if ($ans -eq '' -or $ans -match '^[yY]') { Start-Process $exe }
