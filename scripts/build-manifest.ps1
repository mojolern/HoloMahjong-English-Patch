param(
    [string]$Version = '1.1.0'
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$payloadRoot = Join-Path $repoRoot 'update\payload'
$manifestPath = Join-Path $repoRoot 'update\manifest.json'
$baseUrl = 'https://raw.githubusercontent.com/mojolern/HoloMahjong-English-Patch/main/update/payload'

$files = Get-ChildItem -LiteralPath $payloadRoot -Recurse -File | Sort-Object FullName | ForEach-Object {
    $relative = $_.FullName.Substring($payloadRoot.Length + 1).Replace('\', '/')
    [ordered]@{
        path = $relative
        size = $_.Length
        sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        url = "$baseUrl/$relative"
    }
}

$manifest = [ordered]@{
    schema = 1
    version = $Version
    generated_utc = [DateTime]::UtcNow.ToString('o')
    files = @($files)
}
[System.IO.File]::WriteAllText(
    $manifestPath,
    ($manifest | ConvertTo-Json -Depth 6),
    [System.Text.UTF8Encoding]::new($false)
)
Write-Host "Built $manifestPath with $($files.Count) file(s)."
