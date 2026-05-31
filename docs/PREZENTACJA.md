# Prezentacja projektu Biblioteka

Ten plik to gotowy scenariusz pokazania projektu na zajeciach. Najlatwiej pokazac projekt z XAMPP albo Dockerem, a potem uruchomic `queries/demo.sql`.

## Przed zajeciami

1. Uruchom MySQL w XAMPP.
2. W terminalu przejdz do katalogu projektu.
3. Zainstaluj baze od zera:

```powershell
.\scripts\install.ps1
```

4. Sprawdz, czy demo dziala:

```powershell
.\scripts\demo.ps1
```

Jesli masz Docker i lokalny klient `mysql`, mozesz uzyc portu 3307:

```powershell
cd docker
docker compose up -d
cd ..
.\scripts\demo.ps1 -MysqlPath mysql -Port 3307 -Password root
```

## Plan wystapienia na 5-7 minut

1. Cel projektu:
   "Projekt przedstawia relacyjna baze danych dla biblioteki. Model obejmuje czytelnikow, ksiazki, autorow, egzemplarze, wypozyczenia, statusy, kary, rezerwacje oraz elementy audytu."

2. Model danych:
   "Baza ma 17 tabel. Relacje N:M sa rozbite tabelami laczacymi `K_A` dla ksiazek i autorow oraz `W_E` dla wypozyczen i egzemplarzy. Schemat jest w `docs/ER-diagram.md`."

3. Dane testowe:
   "W migracji `V02__seed.sql` sa przygotowane dane: czytelnicy, autorzy, ksiazki, egzemplarze, wypozyczenia, statusy i kary. Dzieki temu baza od razu nadaje sie do raportowania."

4. Logika biznesowa:
   "Triggery pilnuja poprawnosci dat, blokuja usuwanie wypozyczonych egzemplarzy, normalizuja imiona autorow i automatycznie naliczaja kare po zmianie statusu na `przetrzymane`."

5. Zaawansowany SQL:
   "Projekt zawiera widoki, funkcje UDF, procedury skladowane z transakcjami, window functions, FULLTEXT search oraz event scheduler."

6. Demo:
   "Teraz uruchamiam `scripts/demo.ps1`. Skrypt pokazuje liczbe obiektow, katalog ksiazek, aktualne wypozyczenia, kary, funkcje, procedury raportowe, ranking z window functions, FULLTEXT oraz triggery w transakcji testowej."

7. Podsumowanie:
   "Projekt skupia sie na modelu biblioteki, logice biznesowej, raportach i automatyzacji po stronie bazy, bez logowania na osobne profile uzytkownikow."

## Co pokazac na ekranie

1. `README.md` - krotki opis funkcji projektu.
2. `docs/ER-diagram.md` - diagram encji i relacji.
3. `migrations/V01__schema.sql` - tabele i klucze obce.
4. `migrations/V04__triggers.sql` - przyklady zabezpieczen.
5. `migrations/V07__procedures.sql` - procedury z transakcjami.
6. Terminal z wynikiem:

```powershell
.\scripts\demo.ps1
```

## Odpowiedzi na typowe pytania

**Dlaczego MySQL?**
Projekt korzysta z procedur, triggerow, event scheduler i FULLTEXT, czyli funkcji dobrze wspieranych przez MySQL 8.

**Gdzie sa relacje wiele-do-wielu?**
Ksiazka moze miec wielu autorow, dlatego jest tabela `K_A`. Jedno wypozyczenie moze obejmowac wiecej niz jeden egzemplarz, dlatego jest tabela `W_E`.

**Jak sprawdzasz poprawnosc?**
Migracje sa uruchamiane w GitHub Actions na MySQL 8. Dodatkowo sa zapytania w `queries/verification.sql` oraz scenariusz demonstracyjny `queries/demo.sql`.

**Co jest najbardziej zaawansowane?**
Procedury z transakcjami, automatyczny audit log w JSON, kolejka rezerwacji FIFO, window functions do rankingow oraz FULLTEXT search.
