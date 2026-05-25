# reset.ps1 - DROP DATABASE i ponowna instalacja
param(
    [string]$MysqlPath = "C:\xampp\mysql\bin\mysql.exe",
    [string]$HostName  = "127.0.0.1",
    [int]$Port         = 3306,
    [string]$User      = "root",
    [string]$Password  = ""
)

$ErrorActionPreference = "Stop"

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

Write-Host "==> UWAGA: Usuniecie wszystkich danych w bazie 'biblioteka'!" -ForegroundColor Red
$confirm = Read-Host "Wpisz 'TAK' aby kontynuowac"
if ($confirm -ne "TAK") { Write-Host "Anulowano."; exit 0 }

$mysqlArgs = New-MysqlArgs
& $MysqlPath @mysqlArgs -e "DROP DATABASE IF EXISTS biblioteka;"
if ($LASTEXITCODE -ne 0) { throw "DROP DATABASE nie powiodl sie." }

& "$PSScriptRoot\install.ps1" -MysqlPath $MysqlPath -HostName $HostName -Port $Port -User $User -Password $Password
