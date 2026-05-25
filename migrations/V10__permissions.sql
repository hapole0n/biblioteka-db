-- ============================================================================
-- V10__permissions.sql - Role i prawa dostepu
-- ============================================================================
USE biblioteka;

-- ===== ROLE BAZODANOWE =====
CREATE ROLE IF NOT EXISTS
    'rola_admin_biblioteka'@'%',
    'rola_bibliotekarz'@'%',
    'rola_czytelnik'@'%',
    'rola_analityk'@'%';

-- 1. ADMIN BAZY (pelne prawa)
GRANT ALL PRIVILEGES ON biblioteka.* TO 'rola_admin_biblioteka'@'%' WITH GRANT OPTION;

-- 2. BIBLIOTEKARZ (CRUD na danych, brak DDL)
GRANT SELECT, INSERT, UPDATE, DELETE ON biblioteka.Czytelnicy   TO 'rola_bibliotekarz'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON biblioteka.Wypozyczenia TO 'rola_bibliotekarz'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON biblioteka.W_E          TO 'rola_bibliotekarz'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON biblioteka.W_S          TO 'rola_bibliotekarz'@'%';
GRANT SELECT, INSERT, UPDATE         ON biblioteka.Kary         TO 'rola_bibliotekarz'@'%';
GRANT SELECT, INSERT                 ON biblioteka.Rezerwacje   TO 'rola_bibliotekarz'@'%';
GRANT SELECT                         ON biblioteka.Ksiazki      TO 'rola_bibliotekarz'@'%';
GRANT SELECT                         ON biblioteka.Egzemplarze  TO 'rola_bibliotekarz'@'%';
GRANT SELECT                         ON biblioteka.Autorzy      TO 'rola_bibliotekarz'@'%';
GRANT EXECUTE ON PROCEDURE biblioteka.sp_wypozycz_ksiazke       TO 'rola_bibliotekarz'@'%';
GRANT EXECUTE ON PROCEDURE biblioteka.sp_zwroc_ksiazke          TO 'rola_bibliotekarz'@'%';
GRANT EXECUTE ON PROCEDURE biblioteka.sp_zarezerwuj_ksiazke     TO 'rola_bibliotekarz'@'%';
GRANT EXECUTE ON PROCEDURE biblioteka.sp_top_czytelnicy         TO 'rola_bibliotekarz'@'%';

-- 3. CZYTELNIK (tylko publiczne widoki, brak dostepu do danych wrazliwych)
GRANT SELECT ON biblioteka.v_czytelnicy_publiczni TO 'rola_czytelnik'@'%';
GRANT SELECT ON biblioteka.v_ksiazki_pelne        TO 'rola_czytelnik'@'%';
GRANT SELECT ON biblioteka.v_kategorie_licznosc   TO 'rola_czytelnik'@'%';
GRANT SELECT ON biblioteka.v_egzemplarze_dostepne TO 'rola_czytelnik'@'%';
GRANT SELECT ON biblioteka.v_top3_per_kategoria   TO 'rola_czytelnik'@'%';

-- 4. ANALITYK (read-only na wszystko, dla raportow)
GRANT SELECT ON biblioteka.* TO 'rola_analityk'@'%';

-- ===== UZYTKOWNICY DEMONSTRACYJNI =====
CREATE USER IF NOT EXISTS 'admin_biblioteka'@'localhost'
    IDENTIFIED BY 'AdminPass2025!';
CREATE USER IF NOT EXISTS 'admin_biblioteka'@'%'
    IDENTIFIED BY 'AdminPass2025!';

CREATE USER IF NOT EXISTS 'bibliotekarz'@'localhost'
    IDENTIFIED BY 'Bibliotekarz2025!';
CREATE USER IF NOT EXISTS 'bibliotekarz'@'%'
    IDENTIFIED BY 'Bibliotekarz2025!';

CREATE USER IF NOT EXISTS 'czytelnik'@'localhost'
    IDENTIFIED BY 'Czytelnik2025!';
CREATE USER IF NOT EXISTS 'czytelnik'@'%'
    IDENTIFIED BY 'Czytelnik2025!';

CREATE USER IF NOT EXISTS 'analityk'@'localhost'
    IDENTIFIED BY 'Analityk2025!';
CREATE USER IF NOT EXISTS 'analityk'@'%'
    IDENTIFIED BY 'Analityk2025!';

GRANT 'rola_admin_biblioteka'@'%' TO 'admin_biblioteka'@'localhost', 'admin_biblioteka'@'%';
GRANT 'rola_bibliotekarz'@'%'    TO 'bibliotekarz'@'localhost',      'bibliotekarz'@'%';
GRANT 'rola_czytelnik'@'%'       TO 'czytelnik'@'localhost',         'czytelnik'@'%';
GRANT 'rola_analityk'@'%'        TO 'analityk'@'localhost',          'analityk'@'%';

SET DEFAULT ROLE 'rola_admin_biblioteka'@'%' TO 'admin_biblioteka'@'localhost', 'admin_biblioteka'@'%';
SET DEFAULT ROLE 'rola_bibliotekarz'@'%'    TO 'bibliotekarz'@'localhost',      'bibliotekarz'@'%';
SET DEFAULT ROLE 'rola_czytelnik'@'%'       TO 'czytelnik'@'localhost',         'czytelnik'@'%';
SET DEFAULT ROLE 'rola_analityk'@'%'        TO 'analityk'@'localhost',          'analityk'@'%';

FLUSH PRIVILEGES;

-- Lista uzytkownikow i rol do szybkiej weryfikacji
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
