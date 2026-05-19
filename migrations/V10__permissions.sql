-- ============================================================================
-- V10__permissions.sql - Role i prawa dostepu
-- ============================================================================
USE biblioteka;

-- 1. ADMIN BAZY (pelne prawa)
CREATE USER IF NOT EXISTS 'admin_biblioteka'@'localhost'
    IDENTIFIED BY 'AdminPass2025!';
GRANT ALL PRIVILEGES ON biblioteka.* TO 'admin_biblioteka'@'localhost' WITH GRANT OPTION;

-- 2. BIBLIOTEKARZ (CRUD na danych, brak DDL)
CREATE USER IF NOT EXISTS 'bibliotekarz'@'localhost'
    IDENTIFIED BY 'Bibliotekarz2025!';
GRANT SELECT, INSERT, UPDATE, DELETE ON biblioteka.Czytelnicy   TO 'bibliotekarz'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON biblioteka.Wypozyczenia TO 'bibliotekarz'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON biblioteka.W_E          TO 'bibliotekarz'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON biblioteka.W_S          TO 'bibliotekarz'@'localhost';
GRANT SELECT, INSERT, UPDATE         ON biblioteka.Kary         TO 'bibliotekarz'@'localhost';
GRANT SELECT, INSERT                 ON biblioteka.Rezerwacje   TO 'bibliotekarz'@'localhost';
GRANT SELECT                         ON biblioteka.Ksiazki      TO 'bibliotekarz'@'localhost';
GRANT SELECT                         ON biblioteka.Egzemplarze  TO 'bibliotekarz'@'localhost';
GRANT SELECT                         ON biblioteka.Autorzy      TO 'bibliotekarz'@'localhost';
GRANT EXECUTE ON PROCEDURE biblioteka.sp_wypozycz_ksiazke    TO 'bibliotekarz'@'localhost';
GRANT EXECUTE ON PROCEDURE biblioteka.sp_zwroc_ksiazke       TO 'bibliotekarz'@'localhost';
GRANT EXECUTE ON PROCEDURE biblioteka.sp_zarezerwuj_ksiazke  TO 'bibliotekarz'@'localhost';
GRANT EXECUTE ON PROCEDURE biblioteka.sp_top_czytelnicy      TO 'bibliotekarz'@'localhost';

-- 3. CZYTELNIK (tylko publiczne widoki, BRAK dostepu do danych osobowych)
CREATE USER IF NOT EXISTS 'czytelnik'@'localhost'
    IDENTIFIED BY 'Czytelnik2025!';
GRANT SELECT ON biblioteka.v_czytelnicy_publiczni   TO 'czytelnik'@'localhost';
GRANT SELECT ON biblioteka.v_ksiazki_pelne          TO 'czytelnik'@'localhost';
GRANT SELECT ON biblioteka.v_kategorie_licznosc     TO 'czytelnik'@'localhost';
GRANT SELECT ON biblioteka.v_egzemplarze_dostepne   TO 'czytelnik'@'localhost';
GRANT SELECT ON biblioteka.v_top3_per_kategoria     TO 'czytelnik'@'localhost';

-- 4. ANALITYK (read-only na wszystko, dla raportow)
CREATE USER IF NOT EXISTS 'analityk'@'localhost'
    IDENTIFIED BY 'Analityk2025!';
GRANT SELECT ON biblioteka.* TO 'analityk'@'localhost';

FLUSH PRIVILEGES;

-- Lista uzytkownikow z ich uprawnieniami
SELECT User, Host FROM mysql.user
WHERE User IN ('admin_biblioteka','bibliotekarz','czytelnik','analityk');
