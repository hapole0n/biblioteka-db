-- ============================================================================
-- verification.sql - 5 zaawansowanych zapytan weryfikujacych baze
-- ============================================================================
USE biblioteka;

-- ZAPYTANIE 1: Ile egzemplarzy aktualnie przetrzymuje kazdy czytelnik
SELECT c.id_czytelnik,
       CONCAT(c.imie,' ',c.nazwisko) AS czytelnik,
       COUNT(we.id_egzemplarz)       AS liczba_egzemplarzy
FROM Czytelnicy c
LEFT JOIN Wypozyczenia w ON w.id_czytelnik = c.id_czytelnik AND w.data_zwrotu IS NULL
LEFT JOIN W_E we         ON we.id_wypozyczenie = w.id_wypozyczenie
GROUP BY c.id_czytelnik, c.imie, c.nazwisko
ORDER BY liczba_egzemplarzy DESC
LIMIT 20;

-- ZAPYTANIE 2: Najpopularniejsze kategorie
SELECT kat.nazwa AS kategoria, COUNT(w.id_wypozyczenie) AS liczba_wypozyczen
FROM Kategorie kat
JOIN Ksiazki k     ON k.id_kategoria = kat.id_kategoria
JOIN Egzemplarze e ON e.id_ksiazka   = k.id_ksiazka
JOIN W_E we        ON we.id_egzemplarz = e.id_egzemplarz
JOIN Wypozyczenia w ON w.id_wypozyczenie = we.id_wypozyczenie
GROUP BY kat.id_kategoria, kat.nazwa
ORDER BY liczba_wypozyczen DESC;

-- ZAPYTANIE 3: Suma nieoplaconych kar per czytelnik
SELECT CONCAT(c.imie,' ',c.nazwisko) AS czytelnik,
       SUM(k.kwota) AS suma_dlugu, COUNT(k.id_kara) AS liczba_kar
FROM Czytelnicy c
JOIN Wypozyczenia w ON w.id_czytelnik = c.id_czytelnik
JOIN Kary k         ON k.id_wypozyczenie = w.id_wypozyczenie
WHERE k.czy_oplacona = FALSE
GROUP BY c.id_czytelnik, c.imie, c.nazwisko
HAVING SUM(k.kwota) > 0
ORDER BY suma_dlugu DESC;

-- ZAPYTANIE 4: Czytelnicy ponad srednia (PODZAPYTANIE SKORELOWANE)
SELECT c.id_czytelnik, CONCAT(c.imie,' ',c.nazwisko) AS czytelnik,
       (SELECT COUNT(*) FROM Wypozyczenia w WHERE w.id_czytelnik = c.id_czytelnik) AS liczba_wypozyczen
FROM Czytelnicy c
WHERE (SELECT COUNT(*) FROM Wypozyczenia w WHERE w.id_czytelnik = c.id_czytelnik) >
      (SELECT AVG(cnt) FROM (SELECT COUNT(*) AS cnt FROM Wypozyczenia GROUP BY id_czytelnik) AS s);

-- ZAPYTANIE 5: Ksiazki nigdy nie wypozyczone (NOT EXISTS)
SELECT k.id_ksiazka, k.tytul, kat.nazwa AS kategoria
FROM Ksiazki k
LEFT JOIN Kategorie kat ON kat.id_kategoria = k.id_kategoria
WHERE NOT EXISTS (
    SELECT 1 FROM Egzemplarze e
    JOIN W_E we ON we.id_egzemplarz = e.id_egzemplarz
    WHERE e.id_ksiazka = k.id_ksiazka
);
