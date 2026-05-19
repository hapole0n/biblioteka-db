# reset.ps1 - DROP DATABASE i ponowna instalacja
param(
    [string]$MysqlPath = "C:\xampp\mysql\bin\mysql.exe",
    [string]$User      = "root",
    [string]$Password  = ""
)

Write-Host "==> UWAGA: Usuniecie wszystkich danych w bazie 'biblioteka'!" -ForegroundColor Red
$confirm = Read-Host "Wpisz 'TAK' aby kontynuowac"
if ($confirm -ne "TAK") { Write-Host "Anulowano."; exit 0 }

if ($Password) {
    & $MysqlPath -u $User "-p$Password" -e "DROP DATABASE IF EXISTS biblioteka;"
} else {
    & $MysqlPath -u $User -e "DROP DATABASE IF EXISTS biblioteka;"
}

& "$PSScriptRoot\install.ps1" -MysqlPath $MysqlPath -User $User -Password $Password
