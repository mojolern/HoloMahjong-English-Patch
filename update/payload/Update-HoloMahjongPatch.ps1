param(
    [switch]$Launch,
    [string]$GameDirectory = $PSScriptRoot,
    [string]$ManifestUrl = 'https://raw.githubusercontent.com/mojolern/HoloMahjong-English-Patch/main/update/manifest.json'
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$userAgent = 'HoloMahjong-English-Patch-Updater'

function Get-Sha256([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Invoke-Download([string]$Uri, [string]$Destination) {
    $parsed = [Uri]$Uri
    if ($parsed.IsFile) {
        Copy-Item -LiteralPath $parsed.LocalPath -Destination $Destination -Force
        return
    }
    $lastError = $null
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        try {
            Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile $Destination -UserAgent $userAgent -TimeoutSec 30
            return
        } catch {
            $lastError = $_
            if ($attempt -lt 3) { Start-Sleep -Seconds $attempt }
        }
    }
    throw $lastError
}

function Start-Game([string]$Root) {
    $launcher = Join-Path $Root 'HoloMahjongLauncher.exe'
    $game = Join-Path $Root 'HoloMahjong.exe'
    if (Test-Path -LiteralPath $launcher -PathType Leaf) {
        Start-Process -FilePath $launcher -WorkingDirectory $Root
    } elseif (Test-Path -LiteralPath $game -PathType Leaf) {
        Start-Process -FilePath $game -WorkingDirectory $Root
    } else {
        throw "HoloMahjong.exe was not found in $Root"
    }
}

$gameRoot = [System.IO.Path]::GetFullPath($GameDirectory)
$gameExe = Join-Path $gameRoot 'HoloMahjong.exe'
if (-not (Test-Path -LiteralPath $gameExe -PathType Leaf)) {
    throw "Place this updater beside HoloMahjong.exe. Current folder: $gameRoot"
}

$running = Get-Process -Name 'HoloMahjong' -ErrorAction SilentlyContinue
if ($running) {
    throw 'HoloMahjong is running. Close the game before updating.'
}

$manifestTemp = Join-Path ([System.IO.Path]::GetTempPath()) ("HoloMahjongPatch-manifest-{0}.json" -f [guid]::NewGuid())
$updated = 0
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Host 'Checking for HoloMahjong English Patch updates...'
    Invoke-Download -Uri $ManifestUrl -Destination $manifestTemp
    $manifest = Get-Content -Raw -LiteralPath $manifestTemp | ConvertFrom-Json
    if ($manifest.schema -ne 1) { throw "Unsupported manifest schema: $($manifest.schema)" }

    foreach ($file in $manifest.files) {
        $relative = [string]$file.path
        if ([System.IO.Path]::IsPathRooted($relative) -or $relative -match '(^|[\\/])\.\.([\\/]|$)') {
            throw "Unsafe path in update manifest: $relative"
        }
        $target = [System.IO.Path]::GetFullPath((Join-Path $gameRoot $relative))
        if (-not $target.StartsWith($gameRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Update path escapes the game folder: $relative"
        }
        $expected = ([string]$file.sha256).ToLowerInvariant()
        if ((Test-Path -LiteralPath $target -PathType Leaf) -and (Get-Sha256 $target) -eq $expected) {
            continue
        }

        $directory = Split-Path -Parent $target
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
        $temp = "$target.download-$([guid]::NewGuid().ToString('N')).tmp"
        try {
            Invoke-Download -Uri ([string]$file.url) -Destination $temp
            $actual = Get-Sha256 $temp
            if ($actual -ne $expected) {
                throw "Hash verification failed for $relative. Expected $expected, received $actual."
            }
            Move-Item -LiteralPath $temp -Destination $target -Force
            $updated++
            Write-Host "Updated: $relative"
        } finally {
            if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force }
        }
    }

    [System.IO.File]::WriteAllText(
        (Join-Path $gameRoot '.holomahjong-english-patch-version'),
        ([string]$manifest.version),
        [System.Text.UTF8Encoding]::new($false)
    )
    if ($updated -eq 0) {
        Write-Host "Patch $($manifest.version) is already up to date."
    } else {
        Write-Host "Patch updated to $($manifest.version) ($updated file(s) changed)."
    }
} catch {
    Write-Warning "Update check failed: $($_.Exception.Message)"
    if (-not $Launch) { throw }
    Write-Warning 'Launching the installed patch without updating.'
} finally {
    if (Test-Path -LiteralPath $manifestTemp) { Remove-Item -LiteralPath $manifestTemp -Force }
}

if ($Launch) { Start-Game -Root $gameRoot }
