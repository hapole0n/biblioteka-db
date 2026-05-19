-- ============================================================================
-- tests.sql - testy widokow, triggerow i procedur
-- UWAGA: Niektore polecenia ponizej CELOWO koncza sie bledem - to dowod, ze triggery dzialaja!
-- ============================================================================
USE biblioteka;

-- ===== TEST 1: Odczyt widokow =====
SELECT * FROM v_czytelnicy_publiczni LIMIT 10;
SELECT * FROM v_kategorie_licznosc;
SELECT * FROM v_aktualne_wypozyczenia LIMIT 10;
SELECT * FROM v_kary_niezaplacone;
SELECT * FROM v_egzemplarze_dostepne LIMIT 10;
SELECT * FROM v_ksiazki_fantastyka;

-- ===== TEST 2: Updatable View z WITH CHECK OPTION =====
INSERT INTO v_ksiazki_fantastyka (tytul, id_kategoria) VALUES ('Nowy Wiedzmin', 2);
SELECT * FROM v_ksiazki_fantastyka;

-- ===== TEST 3: Trigger normalizacji autora =====
INSERT INTO Autorzy (imie, nazwisko) VALUES ('jan', 'KOWALSKI');
SELECT * FROM Autorzy WHERE nazwisko = 'Kowalski';

-- ===== TEST 4: Trigger auto-naliczania kary =====
DELETE FROM Kary WHERE id_wypozyczenie = 50;
INSERT INTO W_S (id_wypozyczenie, id_status)
VALUES (50, (SELECT id_status FROM Status WHERE nazwa_statusu = 'przetrzymane'));
SELECT * FROM Kary WHERE id_wypozyczenie = 50;

-- ===== TEST 5: Audyt usuniecia czytelnika =====
INSERT INTO Czytelnicy (imie, nazwisko, email) VALUES ('Test', 'DoUsuniecia', 'test.del@stud.pl');
SET @id_test = LAST_INSERT_ID();
DELETE FROM Czytelnicy WHERE id_czytelnik = @id_test;
SELECT * FROM Audyt_Czytelnicy ORDER BY id_audyt DESC LIMIT 1;

-- ===== TEST FUNKCJI =====
SELECT fn_oblicz_kare('2025-03-01','2025-05-15',30) AS test_kara;
SELECT fn_status_lojalnosci(1)         AS status_oleg;
SELECT fn_dostepne_egzemplarze(1)      AS dostepne_pan_tadeusz;
SELECT fn_pelne_imie(1)                AS pelne_imie;

-- ===== TEST PROCEDUR =====
CALL sp_top_czytelnicy(10);
CALL sp_raport_miesieczny(2025, 4);

SET @id_wyp = NULL; SET @msg = NULL;
CALL sp_wypozycz_ksiazke(6, 5, @id_wyp, @msg);
SELECT @id_wyp AS nowe_wyp, @msg AS komunikat;

SET @kara = NULL; SET @msg2 = NULL;
CALL sp_zwroc_ksiazke(8, @kara, @msg2);
SELECT @kara AS naliczona_kara, @msg2 AS komunikat;

SET @pozycja = NULL; SET @msg3 = NULL;
CALL sp_zarezerwuj_ksiazke(10, 1, @pozycja, @msg3);
SELECT @pozycja AS pozycja_w_kolejce, @msg3 AS komunikat;

-- ===== TEST WIDOKOW Z WINDOW FUNCTIONS =====
SELECT * FROM v_ranking_czytelnikow LIMIT 20;
SELECT * FROM v_top3_per_kategoria ORDER BY kategoria, pozycja;
SELECT * FROM v_czas_miedzy_wypozyczeniami WHERE dni_przerwy IS NOT NULL LIMIT 20;
SELECT * FROM v_kumulatywne_kary LIMIT 20;
SELECT * FROM v_udzial_autorow ORDER BY percentyl DESC LIMIT 15;

-- ===== TEST FULLTEXT =====
SELECT tytul,
       MATCH(tytul) AGAINST('Wiedzmin Pani' IN NATURAL LANGUAGE MODE) AS trafnosc
FROM Ksiazki
WHERE MATCH(tytul) AGAINST('Wiedzmin Pani' IN NATURAL LANGUAGE MODE)
ORDER BY trafnosc DESC LIMIT 10;

-- ===== TEST AUDIT LOG =====
SELECT tabela, operacja, id_rekordu,
       JSON_PRETTY(stary_stan) AS stary,
       JSON_PRETTY(nowy_stan)  AS nowy,
       data_operacji
FROM Log_Operacji ORDER BY id_log DESC LIMIT 10;

-- ===== SPRAWDZ EVENTY =====
SELECT EVENT_NAME, INTERVAL_VALUE, INTERVAL_FIELD, STATUS
FROM information_schema.EVENTS WHERE EVENT_SCHEMA = 'biblioteka';

-- ===== LISTA PROCEDUR I FUNKCJI =====
SELECT ROUTINE_NAME, ROUTINE_TYPE, DATA_TYPE
FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA = 'biblioteka'
ORDER BY ROUTINE_TYPE, ROUTINE_NAME;

-- ===== TESTY CELOWO ZWRACAJACE BLAD (dowoz dzialania triggerow) =====
-- Odkomentuj pojedynczo:
-- INSERT INTO Wypozyczenia (id_czytelnik, data_wypozyczenia, data_zwrotu) VALUES (1, '2025-05-10', '2025-05-01');
-- DELETE FROM Egzemplarze WHERE id_egzemplarz = 12;
-- DELETE FROM Kategorie WHERE id_kategoria = 1;
-- INSERT INTO Kary (id_wypozyczenie, kwota) VALUES (4, -10.00);
-- INSERT INTO v_ksiazki_fantastyka (tytul, id_kategoria) VALUES ('Test poezji', 4);
