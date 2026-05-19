# backup.ps1 - Backup bazy do timestampowego pliku .sql
param(
    [string]$DumpPath = "C:\xampp\mysql\bin\mysqldump.exe",
    [string]$User     = "root",
    [string]$Password = "",
    [string]$OutDir   = "$PSScriptRoot\..\backups"
)

if (!(Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$file  = Join-Path $OutDir "biblioteka-$stamp.sql"

Write-Host "==> Backup -> $file" -ForegroundColor Cyan
if ($Password) {
    & $DumpPath -u $User "-p$Password" --routines --triggers --events biblioteka | Out-File -FilePath $file -Encoding utf8
} else {
    & $DumpPath -u $User --routines --triggers --events biblioteka | Out-File -FilePath $file -Encoding utf8
}
$size = ((Get-Item $file).Length / 1KB).ToString('N0')
Write-Host "==> Gotowe ($size KB)" -ForegroundColor Green
