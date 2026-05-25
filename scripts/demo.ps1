# demo.ps1 - uruchamia krotki scenariusz prezentacji bazy Biblioteka
param(
    [string]$MysqlPath = "C:\xampp\mysql\bin\mysql.exe",
    [string]$HostName  = "127.0.0.1",
    [int]$Port         = 3306,
    [string]$User      = "root",
    [string]$Password  = ""
)

$ErrorActionPreference = "Stop"

$demoFile = Join-Path $PSScriptRoot "..\queries\demo.sql"
if (!(Test-Path $demoFile)) {
    throw "Nie znaleziono pliku demo: $demoFile"
}

if (($MysqlPath -match '[\\/:]') -and !(Test-Path $MysqlPath)) {
    throw "Nie znaleziono klienta MySQL: $MysqlPath. Podaj -MysqlPath albo dodaj mysql.exe do PATH."
}

$mysqlArgs = @(
    "--default-character-set=utf8mb4",
    "--table",
    "-h", $HostName,
    "-P", $Port.ToString(),
    "-u", $User
)

if ($Password) {
    $mysqlArgs += "-p$Password"
}

Write-Host "==> Demo Biblioteka: $demoFile" -ForegroundColor Cyan
Get-Content $demoFile -Raw | & $MysqlPath @mysqlArgs

if ($LASTEXITCODE -ne 0) {
    throw "Demo SQL zakonczylo sie bledem."
}

Write-Host "==> Demo zakonczone pomyslnie." -ForegroundColor Green
