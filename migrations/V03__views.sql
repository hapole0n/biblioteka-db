-- ============================================================================
-- V03__views.sql - 8 widokow podstawowych (proste + zlozone + aktualizowalny)
-- ============================================================================
USE biblioteka;

CREATE OR REPLACE VIEW v_czytelnicy_publiczni AS
SELECT id_czytelnik, imie, nazwisko FROM Czytelnicy;

CREATE OR REPLACE VIEW v_ksiazki_fantastyka AS
SELECT id_ksiazka, tytul, id_kategoria
FROM Ksiazki
WHERE id_kategoria IN (2, 3)
WITH CHECK OPTION;

CREATE OR REPLACE VIEW v_kategorie_licznosc AS
SELECT kat.id_kategoria, kat.nazwa, COUNT(k.id_ksiazka) AS liczba_ksiazek
FROM Kategorie kat
LEFT JOIN Ksiazki k ON k.id_kategoria = kat.id_kategoria
GROUP BY kat.id_kategoria, kat.nazwa;

CREATE OR REPLACE VIEW v_ksiazki_pelne AS
SELECT k.id_ksiazka, k.tytul, kat.nazwa AS kategoria,
       GROUP_CONCAT(DISTINCT CONCAT(a.imie,' ',a.nazwisko) SEPARATOR ', ') AS autorzy,
       COUNT(DISTINCT e.id_egzemplarz) AS liczba_egzemplarzy
FROM Ksiazki k
LEFT JOIN Kategorie kat ON kat.id_kategoria = k.id_kategoria
LEFT JOIN K_A ka        ON ka.id_ksiazka    = k.id_ksiazka
LEFT JOIN Autorzy a     ON a.id_autor       = ka.id_autor
LEFT JOIN Egzemplarze e ON e.id_ksiazka     = k.id_ksiazka
GROUP BY k.id_ksiazka, k.tytul, kat.nazwa;

CREATE OR REPLACE VIEW v_aktualne_wypozyczenia AS
SELECT w.id_wypozyczenie,
       CONCAT(c.imie,' ',c.nazwisko) AS czytelnik,
       w.data_wypozyczenia,
       DATEDIFF(CURRENT_DATE, w.data_wypozyczenia) AS dni_od_wypozyczenia,
       k.tytul, e.numer_inwentarzowy
FROM Wypozyczenia w
JOIN Czytelnicy c  ON c.id_czytelnik = w.id_czytelnik
JOIN W_E we        ON we.id_wypozyczenie = w.id_wypozyczenie
JOIN Egzemplarze e ON e.id_egzemplarz = we.id_egzemplarz
JOIN Ksiazki k     ON k.id_ksiazka = e.id_ksiazka
WHERE w.data_zwrotu IS NULL;

CREATE OR REPLACE VIEW v_kary_niezaplacone AS
SELECT k.id_kara, CONCAT(c.imie,' ',c.nazwisko) AS czytelnik,
       c.email, k.kwota, w.data_wypozyczenia, w.data_zwrotu
FROM Kary k
JOIN Wypozyczenia w ON w.id_wypozyczenie = k.id_wypozyczenie
JOIN Czytelnicy c   ON c.id_czytelnik = w.id_czytelnik
WHERE k.czy_oplacona = FALSE;

CREATE OR REPLACE VIEW v_historia_statusow AS
SELECT ws.id_ws, w.id_wypozyczenie,
       CONCAT(c.imie,' ',c.nazwisko) AS czytelnik,
       s.nazwa_statusu, ws.data_zmiany
FROM W_S ws
JOIN Wypozyczenia w ON w.id_wypozyczenie = ws.id_wypozyczenie
JOIN Status s       ON s.id_status = ws.id_status
JOIN Czytelnicy c   ON c.id_czytelnik = w.id_czytelnik
ORDER BY w.id_wypozyczenie, ws.data_zmiany;

CREATE OR REPLACE VIEW v_egzemplarze_dostepne AS
SELECT e.id_egzemplarz, e.numer_inwentarzowy, k.tytul,
       wyd.nazwa AS wydawnictwo
FROM Egzemplarze e
JOIN Ksiazki k        ON k.id_ksiazka = e.id_ksiazka
LEFT JOIN Wydawnictwa wyd ON wyd.id_wydawnictwo = e.id_wydawnictwo
WHERE NOT EXISTS (
    SELECT 1 FROM W_E we
    JOIN Wypozyczenia w ON w.id_wypozyczenie = we.id_wypozyczenie
    WHERE we.id_egzemplarz = e.id_egzemplarz AND w.data_zwrotu IS NULL
);
