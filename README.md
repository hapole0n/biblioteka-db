# Biblioteka — System Zarzadzania Biblioteka

[![SQL Validation](https://github.com/hapole0n/biblioteka-db/actions/workflows/ci.yml/badge.svg)](https://github.com/hapole0n/biblioteka-db/actions)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-blue.svg)](https://www.mysql.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> Projekt zaliczeniowy z przedmiotu **Relacyjne bazy danych i jezyk SQL**
> Studia II stopnia, IZIwE, rok akademicki 2025/2026

## Zespol

| Imie i nazwisko        | Grupa  |
|------------------------|--------|
| Oleh Kropyva           | 1.1.2  |
| Ihor Paukov            | 1.1.2  |
| Mateusz Tomasz Niziuk  | 1.1.2  | 
| Maciej Kowalczy        | 1.1.2  | 

## Co zawiera projekt

- **17 tabel** (12 podstawowych + 5 zaawansowanych: audyt, rezerwacje, lojalnosc, statystyki)
- **13 widokow** (8 podstawowych + 5 z window functions)
- **13 triggerow** (8 podstawowych + 4 audit + 1 kolejka FIFO)
- **5 procedur skladowanych** z transakcjami i SAVEPOINT
- **5 funkcji UDF** (oblicz kare, status lojalnosci, dostepnosc, ...)
- **2 zaplanowane eventy** (codzienne sprawdzanie przetrzymanych)
- **FULLTEXT search** po tytulach z rankingiem trafnosci
- **Rekurencyjne CTE** (saga Wiedzmina, graf polecen czytelniczych)
- **Generyczny audit log** w formacie JSON
- **4 role bazodanowe** (Admin, Bibliotekarz, Czytelnik, Analityk)
- **CI/CD** przez GitHub Actions
- **Docker Compose** alternatywa dla XAMPP

## Szybki start

### Opcja A: Docker (zalecane)
```bash
cd docker
docker-compose up -d
# MySQL: localhost:3307, phpMyAdmin: http://localhost:8080
```

### Opcja B: Lokalny XAMPP
```powershell
.\scripts\install.ps1
```

### Opcja C: Recznie w IntelliJ
1. Otworz `biblioteka-full.sql` w IntelliJ
2. Podlacz Data Source do `localhost:3306`
3. `Ctrl+A` -> `Ctrl+Enter`

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

## Struktura

```
biblioteka-db/
|-- migrations/          # SQL w wersjach V01__, V02__, ...
|-- queries/             # Przykladowe zapytania
|-- scripts/             # PowerShell automatyzacja
|-- docker/              # docker-compose
|-- docs/                # Dokumentacja i diagramy
+-- .github/workflows/   # CI/CD
```

## License

MIT - patrz [LICENSE](LICENSE)
