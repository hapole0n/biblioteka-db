-- ============================================================================
-- V05__functions.sql - 5 funkcji skalarnych (UDF)
-- ============================================================================
USE biblioteka;

DELIMITER //

CREATE FUNCTION fn_oblicz_kare(data_wyp DATE, data_zwr DATE, dni_norma INT)
RETURNS DECIMAL(8,2)
DETERMINISTIC
BEGIN
    DECLARE dni_calkowite INT;
    DECLARE dni_spoznienia INT;
    DECLARE kara DECIMAL(8,2);
    SET dni_calkowite = DATEDIFF(COALESCE(data_zwr, CURRENT_DATE), data_wyp);
    SET dni_spoznienia = GREATEST(dni_calkowite - dni_norma, 0);
    SET kara = LEAST(dni_spoznienia * 1.50, 100.00);
    RETURN kara;
END//

CREATE FUNCTION fn_dostepne_egzemplarze(p_id_ksiazka INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE cnt INT;
    SELECT COUNT(*) INTO cnt
    FROM Egzemplarze e
    WHERE e.id_ksiazka = p_id_ksiazka
      AND NOT EXISTS (
          SELECT 1 FROM W_E we
          JOIN Wypozyczenia w ON w.id_wypozyczenie = we.id_wypozyczenie
          WHERE we.id_egzemplarz = e.id_egzemplarz AND w.data_zwrotu IS NULL
      );
    RETURN cnt;
END//

CREATE FUNCTION fn_status_lojalnosci(p_id_czytelnik INT)
RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    DECLARE liczba_wyp INT;
    DECLARE niezaplacone DECIMAL(8,2);
    SELECT COUNT(*) INTO liczba_wyp
    FROM Wypozyczenia WHERE id_czytelnik = p_id_czytelnik;
    SELECT COALESCE(SUM(k.kwota),0) INTO niezaplacone
    FROM Kary k JOIN Wypozyczenia w ON w.id_wypozyczenie = k.id_wypozyczenie
    WHERE w.id_czytelnik = p_id_czytelnik AND k.czy_oplacona = FALSE;
    IF niezaplacone > 50 THEN RETURN 'Zablokowany';
    ELSEIF liczba_wyp >= 20 THEN RETURN 'VIP';
    ELSEIF liczba_wyp >= 10 THEN RETURN 'Premium';
    ELSEIF liczba_wyp >= 3  THEN RETURN 'Standard';
    ELSE RETURN 'Nowy';
    END IF;
END//

CREATE FUNCTION fn_pelne_imie(p_id_czytelnik INT)
RETURNS VARCHAR(101)
READS SQL DATA
BEGIN
    DECLARE wynik VARCHAR(101);
    SELECT CONCAT(imie,' ',nazwisko) INTO wynik
    FROM Czytelnicy WHERE id_czytelnik = p_id_czytelnik;
    RETURN COALESCE(wynik,'Nieznany');
END//

CREATE FUNCTION fn_dni_przetrzymania(p_id_wyp INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE dni INT;
    SELECT GREATEST(
        DATEDIFF(COALESCE(data_zwrotu, CURRENT_DATE), data_wypozyczenia) - 30, 0
    ) INTO dni
    FROM Wypozyczenia WHERE id_wypozyczenie = p_id_wyp;
    RETURN COALESCE(dni,0);
END//

DELIMITER ;
