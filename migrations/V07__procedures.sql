-- ============================================================================
-- V06__procedures.sql - 5 procedur skladowanych z transakcjami
-- WYMAGANIE: V09 musi byc juz zaladowane (Punkty_Lojalnosci, Rezerwacje)
-- ============================================================================
USE biblioteka;

DELIMITER //

CREATE PROCEDURE sp_wypozycz_ksiazke(
    IN  p_id_czytelnik INT,
    IN  p_id_egzemplarz INT,
    OUT p_id_wypozyczenia INT,
    OUT p_komunikat VARCHAR(255)
)
BEGIN
    DECLARE v_zajety INT;
    DECLARE v_status_loj VARCHAR(20);
    DECLARE v_id_wyp INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_id_wypozyczenia = NULL;
        SET p_komunikat = 'Blad bazy danych - operacja wycofana.';
    END;

    START TRANSACTION;
    SET v_status_loj = fn_status_lojalnosci(p_id_czytelnik);

    IF v_status_loj = 'Zablokowany' THEN
        SET p_komunikat = 'Czytelnik zablokowany - niezaplacone kary powyzej 50zl.';
        SET p_id_wypozyczenia = NULL;
        ROLLBACK;
    ELSE
        SELECT COUNT(*) INTO v_zajety
        FROM W_E we
        JOIN Wypozyczenia w ON w.id_wypozyczenie = we.id_wypozyczenie
        WHERE we.id_egzemplarz = p_id_egzemplarz AND w.data_zwrotu IS NULL;

        IF v_zajety > 0 THEN
            SET p_komunikat = 'Egzemplarz aktualnie wypozyczony.';
            SET p_id_wypozyczenia = NULL;
            ROLLBACK;
        ELSE
            INSERT INTO Wypozyczenia(id_czytelnik, data_wypozyczenia)
            VALUES (p_id_czytelnik, CURRENT_DATE);
            SET v_id_wyp = LAST_INSERT_ID();
            INSERT INTO W_E(id_wypozyczenie, id_egzemplarz) VALUES (v_id_wyp, p_id_egzemplarz);
            INSERT INTO W_S(id_wypozyczenie, id_status)
            VALUES (v_id_wyp, (SELECT id_status FROM Status WHERE nazwa_statusu='wypozyczone'));
            UPDATE Punkty_Lojalnosci SET punkty = punkty + 10 WHERE id_czytelnik = p_id_czytelnik;
            SET p_id_wypozyczenia = v_id_wyp;
            SET p_komunikat = CONCAT('OK. Status czytelnika: ', v_status_loj);
            COMMIT;
        END IF;
    END IF;
END//

CREATE PROCEDURE sp_zwroc_ksiazke(
    IN  p_id_wypozyczenia INT,
    OUT p_kwota_kary DECIMAL(8,2),
    OUT p_komunikat VARCHAR(255)
)
BEGIN
    DECLARE v_data_wyp DATE;
    DECLARE v_data_zwr DATE;
    DECLARE v_id_czyt INT;
    DECLARE v_kara DECIMAL(8,2);
    DECLARE v_dni_spoznienia INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_kwota_kary = NULL;
        SET p_komunikat = 'Blad - operacja wycofana.';
    END;

    START TRANSACTION;
    SAVEPOINT przed_zwrotem;

    SELECT data_wypozyczenia, data_zwrotu, id_czytelnik
    INTO v_data_wyp, v_data_zwr, v_id_czyt
    FROM Wypozyczenia WHERE id_wypozyczenie = p_id_wypozyczenia;

    IF v_data_zwr IS NOT NULL THEN
        SET p_komunikat = 'Wypozyczenie juz zwrocone.';
        SET p_kwota_kary = 0;
        ROLLBACK TO SAVEPOINT przed_zwrotem;
    ELSE
        UPDATE Wypozyczenia SET data_zwrotu = CURRENT_DATE
        WHERE id_wypozyczenie = p_id_wypozyczenia;
        SET v_kara = fn_oblicz_kare(v_data_wyp, CURRENT_DATE, 30);
        SET v_dni_spoznienia = fn_dni_przetrzymania(p_id_wypozyczenia);
        IF v_kara > 0 THEN
            INSERT INTO Kary(id_wypozyczenie, kwota, czy_oplacona)
            VALUES (p_id_wypozyczenia, v_kara, FALSE)
            ON DUPLICATE KEY UPDATE kwota = v_kara;
            UPDATE Punkty_Lojalnosci SET punkty = punkty - 5 WHERE id_czytelnik = v_id_czyt;
        ELSE
            UPDATE Punkty_Lojalnosci SET punkty = punkty + 5 WHERE id_czytelnik = v_id_czyt;
        END IF;
        INSERT INTO W_S(id_wypozyczenie, id_status)
        VALUES (p_id_wypozyczenia, (SELECT id_status FROM Status WHERE nazwa_statusu='zwrocone'));
        SET p_kwota_kary = v_kara;
        SET p_komunikat = CONCAT('Zwrot OK. Dni spoznienia: ', v_dni_spoznienia, ', kara: ', v_kara, ' zl.');
        COMMIT;
    END IF;
END//

CREATE PROCEDURE sp_zarezerwuj_ksiazke(
    IN  p_id_czytelnik INT,
    IN  p_id_ksiazka INT,
    OUT p_pozycja INT,
    OUT p_komunikat VARCHAR(255)
)
BEGIN
    DECLARE v_dostepne INT;
    DECLARE v_max_poz INT;
    SET v_dostepne = fn_dostepne_egzemplarze(p_id_ksiazka);
    IF v_dostepne > 0 THEN
        SET p_pozycja = 0;
        SET p_komunikat = 'Ksiazka dostepna od reki - rezerwacja niepotrzebna.';
    ELSE
        SELECT COALESCE(MAX(pozycja_kolejki),0)+1 INTO v_max_poz
        FROM Rezerwacje WHERE id_ksiazka = p_id_ksiazka AND status_rez='oczekuje';
        INSERT INTO Rezerwacje(id_czytelnik, id_ksiazka, pozycja_kolejki)
        VALUES (p_id_czytelnik, p_id_ksiazka, v_max_poz);
        SET p_pozycja = v_max_poz;
        SET p_komunikat = CONCAT('Rezerwacja przyjeta. Pozycja w kolejce: ', v_max_poz);
    END IF;
END//

CREATE PROCEDURE sp_raport_miesieczny(IN p_rok INT, IN p_miesiac INT)
BEGIN
    SELECT
        p_rok AS rok, p_miesiac AS miesiac,
        COUNT(DISTINCT w.id_wypozyczenie) AS liczba_wypozyczen,
        COUNT(DISTINCT w.id_czytelnik)    AS unikalni_czytelnicy,
        COALESCE(SUM(k.kwota),0)          AS suma_kar,
        COALESCE(SUM(CASE WHEN k.czy_oplacona THEN k.kwota ELSE 0 END),0) AS sciagnieto,
        COALESCE(SUM(CASE WHEN NOT k.czy_oplacona THEN k.kwota ELSE 0 END),0) AS zaleglosci,
        (SELECT kat.nazwa FROM Kategorie kat
         JOIN Ksiazki ks      ON ks.id_kategoria=kat.id_kategoria
         JOIN Egzemplarze e2  ON e2.id_ksiazka=ks.id_ksiazka
         JOIN W_E we2         ON we2.id_egzemplarz=e2.id_egzemplarz
         JOIN Wypozyczenia w2 ON w2.id_wypozyczenie=we2.id_wypozyczenie
         WHERE YEAR(w2.data_wypozyczenia)=p_rok AND MONTH(w2.data_wypozyczenia)=p_miesiac
         GROUP BY kat.id_kategoria ORDER BY COUNT(*) DESC LIMIT 1) AS top_kategoria
    FROM Wypozyczenia w
    LEFT JOIN Kary k ON k.id_wypozyczenie=w.id_wypozyczenie
    WHERE YEAR(w.data_wypozyczenia)=p_rok AND MONTH(w.data_wypozyczenia)=p_miesiac;
END//

CREATE PROCEDURE sp_top_czytelnicy(IN p_limit INT)
BEGIN
    SELECT c.id_czytelnik,
           fn_pelne_imie(c.id_czytelnik) AS czytelnik,
           COUNT(w.id_wypozyczenie)      AS wypozyczenia,
           fn_status_lojalnosci(c.id_czytelnik) AS status,
           COALESCE(pl.punkty,0)         AS punkty_loj
    FROM Czytelnicy c
    LEFT JOIN Wypozyczenia w       ON w.id_czytelnik = c.id_czytelnik
    LEFT JOIN Punkty_Lojalnosci pl ON pl.id_czytelnik = c.id_czytelnik
    GROUP BY c.id_czytelnik, pl.punkty
    ORDER BY wypozyczenia DESC, punkty_loj DESC
    LIMIT p_limit;
END//

DELIMITER ;
