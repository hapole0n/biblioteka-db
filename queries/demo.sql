-- ============================================================================
-- demo.sql - bezpieczny scenariusz prezentacji projektu Biblioteka
-- Uruchom po instalacji migracji. Skrypt pokazuje najwazniejsze elementy bazy.
-- ============================================================================
USE biblioteka;

SELECT '0. Kontrola obiektow w bazie' AS etap;
SELECT
    (SELECT COUNT(*) FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = 'biblioteka' AND TABLE_TYPE = 'BASE TABLE') AS tabele,
    (SELECT COUNT(*) FROM information_schema.VIEWS
        WHERE TABLE_SCHEMA = 'biblioteka') AS widoki,
    (SELECT COUNT(*) FROM information_schema.TRIGGERS
        WHERE TRIGGER_SCHEMA = 'biblioteka') AS triggery,
    (SELECT COUNT(*) FROM information_schema.ROUTINES
        WHERE ROUTINE_SCHEMA = 'biblioteka' AND ROUTINE_TYPE = 'PROCEDURE') AS procedury,
    (SELECT COUNT(*) FROM information_schema.ROUTINES
        WHERE ROUTINE_SCHEMA = 'biblioteka' AND ROUTINE_TYPE = 'FUNCTION') AS funkcje,
    (SELECT COUNT(*) FROM information_schema.EVENTS
        WHERE EVENT_SCHEMA = 'biblioteka') AS eventy;

SELECT '1. Katalog ksiazek z autorami i liczba egzemplarzy' AS etap;
SELECT id_ksiazka, tytul, kategoria, autorzy, liczba_egzemplarzy
FROM v_ksiazki_pelne
ORDER BY liczba_egzemplarzy DESC, tytul
LIMIT 10;

SELECT '2. Aktualne wypozyczenia i kontrola terminow' AS etap;
SELECT id_wypozyczenie, czytelnik, data_wypozyczenia, dni_od_wypozyczenia, tytul
FROM v_aktualne_wypozyczenia
ORDER BY dni_od_wypozyczenia DESC
LIMIT 10;

SELECT '3. Nieoplacone kary' AS etap;
SELECT czytelnik, email, kwota, data_wypozyczenia
FROM v_kary_niezaplacone
ORDER BY kwota DESC
LIMIT 10;

SELECT '4. Funkcje UDF: dostepnosc, status i naliczanie kary' AS etap;
SELECT
    fn_dostepne_egzemplarze(1) AS dostepne_pan_tadeusz,
    fn_status_lojalnosci(1) AS status_czytelnika_1,
    fn_oblicz_kare('2025-03-01', CURRENT_DATE, 30) AS przykladowa_kara;

SELECT '5. Procedury raportowe' AS etap;
CALL sp_top_czytelnicy(5);
CALL sp_raport_miesieczny(2025, 4);

SELECT '6. Widoki z window functions' AS etap;
SELECT czytelnik, wypozyczenia, pozycja, ranking, ranking_gesty, kwartyl
FROM v_ranking_czytelnikow
ORDER BY pozycja
LIMIT 10;

SELECT kategoria, tytul, liczba_wyp, pozycja
FROM v_top3_per_kategoria
ORDER BY kategoria, pozycja, tytul
LIMIT 15;

SELECT '7. FULLTEXT search po tytulach' AS etap;
SELECT tytul,
       ROUND(MATCH(tytul) AGAINST('Wiedzmin Pani' IN NATURAL LANGUAGE MODE), 3) AS trafnosc
FROM Ksiazki
WHERE MATCH(tytul) AGAINST('Wiedzmin Pani' IN NATURAL LANGUAGE MODE)
ORDER BY trafnosc DESC
LIMIT 10;

SELECT '8. Trigger normalizacji autora w transakcji testowej' AS etap;
START TRANSACTION;
INSERT INTO Autorzy (imie, nazwisko) VALUES ('jan', 'NOWAK');
SELECT id_autor, imie, nazwisko
FROM Autorzy
WHERE id_autor = LAST_INSERT_ID();
ROLLBACK;

SELECT '9. Trigger automatycznego naliczania kary w transakcji testowej' AS etap;
START TRANSACTION;
SET @status_przetrzymane = (
    SELECT id_status FROM Status WHERE nazwa_statusu = 'przetrzymane'
);
DELETE FROM Kary WHERE id_wypozyczenie = 55;
INSERT INTO W_S (id_wypozyczenie, id_status)
VALUES (55, @status_przetrzymane);
SELECT id_wypozyczenie, kwota, czy_oplacona
FROM Kary
WHERE id_wypozyczenie = 55;
ROLLBACK;

SELECT '10. Event scheduler i role bazodanowe' AS etap;
SELECT EVENT_NAME, INTERVAL_VALUE, INTERVAL_FIELD, STATUS
FROM information_schema.EVENTS
WHERE EVENT_SCHEMA = 'biblioteka'
ORDER BY EVENT_NAME;

SELECT User, Host, is_role
FROM mysql.user
WHERE User IN (
    'admin_biblioteka', 'bibliotekarz', 'czytelnik', 'analityk',
    'rola_admin_biblioteka', 'rola_bibliotekarz', 'rola_czytelnik', 'rola_analityk'
)
ORDER BY is_role DESC, User, Host;

SELECT FROM_USER AS rola, FROM_HOST AS rola_host, TO_USER AS uzytkownik, TO_HOST AS user_host
FROM mysql.role_edges
WHERE TO_USER IN ('admin_biblioteka', 'bibliotekarz', 'czytelnik', 'analityk')
ORDER BY rola, uzytkownik, user_host;
