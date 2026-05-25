# Biblioteka - System Zarzadzania Biblioteka

[![SQL Validation](https://github.com/hapole0n/biblioteka-db/actions/workflows/ci.yml/badge.svg)](https://github.com/hapole0n/biblioteka-db/actions)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-blue.svg)](https://www.mysql.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> Projekt zaliczeniowy z przedmiotu **Relacyjne bazy danych i jezyk SQL**
> Studia II stopnia, IZIwE, rok akademicki 2025/2026

## Zespol

| Imie i nazwisko        | Grupa  |
|------------------------|--------|
| Oleh Kropyva           | 1.1.2  |
| Illia Lipsha           | 1.1.2  |
| Mateusz Tomasz Niziuk  | 1.1.2  |
| Maciej Kowalczy        | 1.1.2  |

## Co zawiera projekt

- **17 tabel** (13 podstawowych + 4 zaawansowane: rezerwacje, lojalnosc, audit log, statystyki)
- **13 widokow** (8 podstawowych + 5 z window functions)
- **13 triggerow** (8 podstawowych + 4 audit + 1 kolejka FIFO)
- **5 procedur skladowanych** z transakcjami i SAVEPOINT
- **5 funkcji UDF** (oblicz kare, status lojalnosci, dostepnosc, ...)
- **2 zaplanowane eventy** (codzienne sprawdzanie przetrzymanych)
- **FULLTEXT search** po tytulach z rankingiem trafnosci
- **Generyczny audit log** w formacie JSON
- **4 role bazodanowe** (Admin, Bibliotekarz, Czytelnik, Analityk)
- **CI/CD** przez GitHub Actions
- **Docker Compose** alternatywa dla XAMPP

## Szybki start

### Opcja A: Docker (zalecane)

```bash
cd docker
docker compose up -d
# MySQL: localhost:3307, phpMyAdmin: http://localhost:8080
```

Logowanie do MySQL w Dockerze:

```bash
docker compose exec mysql mysql -uroot -proot biblioteka
```

Jesli chcesz postawic baze od zera po zmianach:

```bash
docker compose down -v
docker compose up -d
```

### Opcja B: Lokalny XAMPP

```powershell
.\scripts\install.ps1
```

### Opcja C: Recznie w IntelliJ

1. Otworz `biblioteka-full.sql` w IntelliJ.
2. Podlacz Data Source do `localhost:3306`.
3. Uruchom caly plik: `Ctrl+A` -> `Ctrl+Enter`.

## Demo na zajeciach

Po instalacji bazy uruchom gotowy scenariusz prezentacyjny:

```powershell
.\scripts\demo.ps1
```

Skrypt pokazuje:
- liczbe tabel, widokow, triggerow, procedur, funkcji i eventow,
- katalog ksiazek z autorami,
- aktualne wypozyczenia i nieoplacone kary,
- funkcje UDF i procedury raportowe,
- window functions, FULLTEXT search, triggery i role bazodanowe.

Przy Dockerze i lokalnym kliencie `mysql`:

```powershell
.\scripts\demo.ps1 -MysqlPath mysql -Port 3307 -Password root
```

Pelny plan prezentacji jest w [docs/PREZENTACJA.md](docs/PREZENTACJA.md).

## Konta demonstracyjne

Migracja `V10__permissions.sql` tworzy prawdziwe role MySQL i przypisuje je do kont:

| Konto | Haslo | Rola |
|-------|-------|------|
| `admin_biblioteka` | `AdminPass2025!` | `rola_admin_biblioteka` |
| `bibliotekarz` | `Bibliotekarz2025!` | `rola_bibliotekarz` |
| `czytelnik` | `Czytelnik2025!` | `rola_czytelnik` |
| `analityk` | `Analityk2025!` | `rola_analityk` |

## Diagram ERD

Patrz: [docs/ER-diagram.md](docs/ER-diagram.md)

## Przykladowe zapytania

```sql
-- Top 10 czytelnikow
CALL sp_top_czytelnicy(10);

-- Raport za kwiecien 2025
CALL sp_raport_miesieczny(2025, 4);

-- Wypozyczenie z walidacja
CALL sp_wypozycz_ksiazke(6, 5, @id_wyp, @msg);
SELECT @id_wyp, @msg;
```

## Przydatne skrypty

```powershell
.\scripts\install.ps1    # instalacja migracji na lokalnym MySQL/XAMPP
.\scripts\demo.ps1       # gotowe demo dla prowadzacego
.\scripts\backup.ps1     # backup z procedurami, triggerami i eventami
.\scripts\reset.ps1      # reset bazy i ponowna instalacja
```

Skrypty `install.ps1`, `demo.ps1` i `reset.ps1` przyjmuja parametry `-MysqlPath`, `-HostName`, `-Port`, `-User` i `-Password`. `backup.ps1` ma analogiczny zestaw z `-DumpPath` zamiast `-MysqlPath`, wiec mozna ich uzyc rowniez z MySQL-em poza XAMPP.

## Struktura

```text
biblioteka-db/
|-- migrations/          # SQL w wersjach V01__, V02__, ...
|-- queries/             # Przykladowe zapytania, testy i demo
|-- scripts/             # PowerShell automatyzacja
|-- docker/              # docker-compose
|-- docs/                # Dokumentacja i diagramy
+-- .github/workflows/   # CI/CD
```

## License

MIT - patrz [LICENSE](LICENSE)
