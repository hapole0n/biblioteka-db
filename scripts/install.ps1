# install.ps1 - Pelna instalacja bazy biblioteka na lokalnym XAMPP
param(
    [string]$MysqlPath = "C:\xampp\mysql\bin\mysql.exe",
    [string]$HostName  = "127.0.0.1",
    [int]$Port         = 3306,
    [string]$User      = "root",
    [string]$Password  = ""
)

$ErrorActionPreference = "Stop"
Write-Host "==> Instalacja bazy biblioteka..." -ForegroundColor Cyan

if (($MysqlPath -match '[\\/:]') -and !(Test-Path $MysqlPath)) {
    throw "Nie znaleziono klienta MySQL: $MysqlPath. Podaj -MysqlPath albo dodaj mysql.exe do PATH."
}

function New-MysqlArgs {
    $args = @(
        "--default-character-set=utf8mb4",
        "-h", $HostName,
        "-P", $Port.ToString(),
        "-u", $User
    )
    if ($Password) {
        $args += "-p$Password"
    }
    return $args
}

$migrationDir = Join-Path $PSScriptRoot "..\migrations"
$migrations = Get-ChildItem -Path $migrationDir -Filter "V*.sql" | Sort-Object Name
$mysqlArgs = New-MysqlArgs

foreach ($file in $migrations) {
    Write-Host "  -> $($file.Name)" -ForegroundColor Yellow
    Get-Content $file.FullName -Raw | & $MysqlPath @mysqlArgs
    if ($LASTEXITCODE -ne 0) { throw "Migracja $($file.Name) nie powiodla sie" }
}

Write-Host "==> Instalacja zakonczona pomyslnie!" -ForegroundColor Green
Write-Host "==> Sprawdz: .\scripts\demo.ps1 -MysqlPath `"$MysqlPath`" -HostName $HostName -Port $Port -User $User" -ForegroundColor Gray
