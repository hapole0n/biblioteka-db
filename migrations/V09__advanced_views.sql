-- ============================================================================
-- V09__advanced_views.sql - 5 widokow z funkcjami okiennymi
-- ============================================================================
USE biblioteka;

CREATE OR REPLACE VIEW v_ranking_czytelnikow AS
SELECT c.id_czytelnik,
       fn_pelne_imie(c.id_czytelnik) AS czytelnik,
       COUNT(w.id_wypozyczenie) AS wypozyczenia,
       ROW_NUMBER() OVER (ORDER BY COUNT(w.id_wypozyczenie) DESC, c.id_czytelnik) AS pozycja,
       RANK()       OVER (ORDER BY COUNT(w.id_wypozyczenie) DESC) AS ranking,
       DENSE_RANK() OVER (ORDER BY COUNT(w.id_wypozyczenie) DESC) AS ranking_gesty,
       NTILE(4)     OVER (ORDER BY COUNT(w.id_wypozyczenie) DESC) AS kwartyl
FROM Czytelnicy c
LEFT JOIN Wypozyczenia w ON w.id_czytelnik = c.id_czytelnik
GROUP BY c.id_czytelnik;

CREATE OR REPLACE VIEW v_top3_per_kategoria AS
WITH popularnosc AS (
    SELECT kat.id_kategoria, kat.nazwa AS kategoria,
           k.id_ksiazka, k.tytul,
           COUNT(w.id_wypozyczenie) AS liczba_wyp,
           RANK() OVER (PARTITION BY kat.id_kategoria
                        ORDER BY COUNT(w.id_wypozyczenie) DESC) AS pozycja
    FROM Kategorie kat
    JOIN Ksiazki k          ON k.id_kategoria = kat.id_kategoria
    LEFT JOIN Egzemplarze e ON e.id_ksiazka   = k.id_ksiazka
    LEFT JOIN W_E we        ON we.id_egzemplarz = e.id_egzemplarz
    LEFT JOIN Wypozyczenia w ON w.id_wypozyczenie = we.id_wypozyczenie
    GROUP BY kat.id_kategoria, kat.nazwa, k.id_ksiazka, k.tytul
)
SELECT * FROM popularnosc WHERE pozycja <= 3;

CREATE OR REPLACE VIEW v_czas_miedzy_wypozyczeniami AS
SELECT c.id_czytelnik,
       fn_pelne_imie(c.id_czytelnik) AS czytelnik,
       w.id_wypozyczenie, w.data_wypozyczenia,
       LAG(w.data_wypozyczenia) OVER (PARTITION BY c.id_czytelnik ORDER BY w.data_wypozyczenia) AS poprzednie_wyp,
       DATEDIFF(w.data_wypozyczenia,
                LAG(w.data_wypozyczenia) OVER (PARTITION BY c.id_czytelnik ORDER BY w.data_wypozyczenia)) AS dni_przerwy
FROM Czytelnicy c
JOIN Wypozyczenia w ON w.id_czytelnik = c.id_czytelnik;

CREATE OR REPLACE VIEW v_kumulatywne_kary AS
SELECT w.data_wypozyczenia,
       fn_pelne_imie(w.id_czytelnik) AS czytelnik,
       k.kwota,
       SUM(k.kwota) OVER (PARTITION BY w.id_czytelnik
                          ORDER BY w.data_wypozyczenia
                          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS kary_narastajaco,
       AVG(k.kwota) OVER (PARTITION BY w.id_czytelnik) AS srednia_kara_czytelnika
FROM Kary k
JOIN Wypozyczenia w ON w.id_wypozyczenie = k.id_wypozyczenie;

CREATE OR REPLACE VIEW v_udzial_autorow AS
SELECT a.id_autor, CONCAT(a.imie,' ',a.nazwisko) AS autor,
       COUNT(w.id_wypozyczenie) AS wypozyczen,
       ROUND(PERCENT_RANK() OVER (ORDER BY COUNT(w.id_wypozyczenie)) * 100, 2) AS percentyl
FROM Autorzy a
LEFT JOIN K_A ka         ON ka.id_autor = a.id_autor
LEFT JOIN Ksiazki k      ON k.id_ksiazka = ka.id_ksiazka
LEFT JOIN Egzemplarze e  ON e.id_ksiazka = k.id_ksiazka
LEFT JOIN W_E we         ON we.id_egzemplarz = e.id_egzemplarz
LEFT JOIN Wypozyczenia w ON w.id_wypozyczenie = we.id_wypozyczenie
GROUP BY a.id_autor, a.imie, a.nazwisko;
