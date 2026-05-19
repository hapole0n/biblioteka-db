# install.ps1 - Pelna instalacja bazy biblioteka na lokalnym XAMPP
param(
    [string]$MysqlPath = "C:\xampp\mysql\bin\mysql.exe",
    [string]$User      = "root",
    [string]$Password  = ""
)

$ErrorActionPreference = "Stop"
Write-Host "==> Instalacja bazy biblioteka..." -ForegroundColor Cyan

$migrationDir = Join-Path $PSScriptRoot "..\migrations"
$migrations = Get-ChildItem -Path $migrationDir -Filter "V*.sql" | Sort-Object Name

foreach ($file in $migrations) {
    Write-Host "  -> $($file.Name)" -ForegroundColor Yellow
    if ($Password) {
        Get-Content $file.FullName -Raw | & $MysqlPath -u $User "-p$Password"
    } else {
        Get-Content $file.FullName -Raw | & $MysqlPath -u $User
    }
    if ($LASTEXITCODE -ne 0) { throw "Migracja $($file.Name) nie powiodla sie" }
}

Write-Host "==> Instalacja zakonczona pomyslnie!" -ForegroundColor Green
Write-Host "==> Sprawdz: $MysqlPath -u root biblioteka -e 'SHOW TABLES;'" -ForegroundColor Gray
