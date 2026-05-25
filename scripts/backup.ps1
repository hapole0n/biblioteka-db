# backup.ps1 - Backup bazy do timestampowego pliku .sql
param(
    [string]$DumpPath = "C:\xampp\mysql\bin\mysqldump.exe",
    [string]$HostName = "127.0.0.1",
    [int]$Port        = 3306,
    [string]$User     = "root",
    [string]$Password = "",
    [string]$OutDir   = "$PSScriptRoot\..\backups"
)

$ErrorActionPreference = "Stop"

if (($DumpPath -match '[\\/:]') -and !(Test-Path $DumpPath)) {
    throw "Nie znaleziono mysqldump: $DumpPath. Podaj -DumpPath albo dodaj mysqldump.exe do PATH."
}

function New-DumpArgs {
    $args = @(
        "--default-character-set=utf8mb4",
        "-h", $HostName,
        "-P", $Port.ToString(),
        "-u", $User,
        "--routines",
        "--triggers",
        "--events",
        "biblioteka"
    )
    if ($Password) {
        $args = @(
            "--default-character-set=utf8mb4",
            "-h", $HostName,
            "-P", $Port.ToString(),
            "-u", $User,
            "-p$Password",
            "--routines",
            "--triggers",
            "--events",
            "biblioteka"
        )
    }
    return $args
}

if (!(Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$file  = Join-Path $OutDir "biblioteka-$stamp.sql"

Write-Host "==> Backup -> $file" -ForegroundColor Cyan
$dumpArgs = New-DumpArgs
& $DumpPath @dumpArgs | Out-File -FilePath $file -Encoding utf8
if ($LASTEXITCODE -ne 0) { throw "Backup bazy nie powiodl sie." }

$size = ((Get-Item $file).Length / 1KB).ToString('N0')
Write-Host "==> Gotowe ($size KB)" -ForegroundColor Green
