-- ============================================================================
-- V04__triggers.sql - 8 triggerow biznesowych
-- ============================================================================
USE biblioteka;

DELIMITER //

CREATE TRIGGER trg_wyp_check_daty_ins
BEFORE INSERT ON Wypozyczenia
FOR EACH ROW
BEGIN
    IF NEW.data_zwrotu IS NOT NULL AND NEW.data_zwrotu < NEW.data_wypozyczenia THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Data zwrotu nie moze byc wczesniejsza niz data wypozyczenia.';
    END IF;
END//

CREATE TRIGGER trg_wyp_check_daty_upd
BEFORE UPDATE ON Wypozyczenia
FOR EACH ROW
BEGIN
    IF NEW.data_zwrotu IS NOT NULL AND NEW.data_zwrotu < NEW.data_wypozyczenia THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Data zwrotu nie moze byc wczesniejsza niz data wypozyczenia.';
    END IF;
END//

CREATE TRIGGER trg_ws_naliczanie_kary
AFTER INSERT ON W_S
FOR EACH ROW
BEGIN
    DECLARE v_nazwa VARCHAR(30);
    DECLARE v_istnieje INT;
    SELECT nazwa_statusu INTO v_nazwa FROM Status WHERE id_status = NEW.id_status;
    IF v_nazwa = 'przetrzymane' THEN
        SELECT COUNT(*) INTO v_istnieje FROM Kary WHERE id_wypozyczenie = NEW.id_wypozyczenie;
        IF v_istnieje = 0 THEN
            INSERT INTO Kary (id_wypozyczenie, kwota, czy_oplacona)
            VALUES (NEW.id_wypozyczenie, 20.00, FALSE);
        END IF;
    END IF;
END//

CREATE TRIGGER trg_czyt_audyt_del
AFTER DELETE ON Czytelnicy
FOR EACH ROW
BEGIN
    INSERT INTO Audyt_Czytelnicy (id_czytelnik, imie, nazwisko, email, usuniety_przez)
    VALUES (OLD.id_czytelnik, OLD.imie, OLD.nazwisko, OLD.email, CURRENT_USER());
END//

CREATE TRIGGER trg_kary_check_kwota
BEFORE INSERT ON Kary
FOR EACH ROW
BEGIN
    IF NEW.kwota < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Kwota kary nie moze byc ujemna.';
    END IF;
END//

CREATE TRIGGER trg_egz_blokada_del
BEFORE DELETE ON Egzemplarze
FOR EACH ROW
BEGIN
    DECLARE v_active INT;
    SELECT COUNT(*) INTO v_active
    FROM W_E we JOIN Wypozyczenia w ON w.id_wypozyczenie = we.id_wypozyczenie
    WHERE we.id_egzemplarz = OLD.id_egzemplarz AND w.data_zwrotu IS NULL;
    IF v_active > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nie mozna usunac egzemplarza, ktory jest aktualnie wypozyczony.';
    END IF;
END//

CREATE TRIGGER trg_autor_norm_ins
BEFORE INSERT ON Autorzy
FOR EACH ROW
BEGIN
    SET NEW.imie     = CONCAT(UPPER(SUBSTRING(NEW.imie,1,1)),     LOWER(SUBSTRING(NEW.imie,2)));
    SET NEW.nazwisko = CONCAT(UPPER(SUBSTRING(NEW.nazwisko,1,1)), LOWER(SUBSTRING(NEW.nazwisko,2)));
END//

CREATE TRIGGER trg_kat_blokada_del
BEFORE DELETE ON Kategorie
FOR EACH ROW
BEGIN
    DECLARE v_cnt INT;
    SELECT COUNT(*) INTO v_cnt FROM Ksiazki WHERE id_kategoria = OLD.id_kategoria;
    IF v_cnt > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nie mozna usunac kategorii, do ktorej przypisane sa ksiazki.';
    END IF;
END//

DELIMITER ;
