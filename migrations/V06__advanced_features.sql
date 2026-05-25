-- ============================================================================
-- V06__advanced_features.sql - tabele subsystemow + audit log + FULLTEXT + kolejka
-- WAZNE: ten plik MUSI byc zaladowany PRZED V07 (procedury),
-- bo procedury uzywaja tabel Punkty_Lojalnosci oraz Rezerwacje.
-- ============================================================================
USE biblioteka;

-- ===== TABELE SUBSYSTEMOW =====
CREATE TABLE IF NOT EXISTS Rezerwacje (
    id_rezerwacji    INT AUTO_INCREMENT PRIMARY KEY,
    id_czytelnik     INT NOT NULL,
    id_ksiazka       INT NOT NULL,
    data_rezerwacji  DATETIME DEFAULT CURRENT_TIMESTAMP,
    status_rez       ENUM('oczekuje','zrealizowana','anulowana') DEFAULT 'oczekuje',
    pozycja_kolejki  INT,
    FOREIGN KEY (id_czytelnik) REFERENCES Czytelnicy(id_czytelnik) ON DELETE CASCADE,
    FOREIGN KEY (id_ksiazka)   REFERENCES Ksiazki(id_ksiazka)     ON DELETE CASCADE,
    INDEX idx_rez_status (id_ksiazka, status_rez, pozycja_kolejki)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Punkty_Lojalnosci (
    id_czytelnik    INT PRIMARY KEY,
    punkty          INT NOT NULL DEFAULT 0,
    poziom          ENUM('Nowy','Standard','Premium','VIP') DEFAULT 'Nowy',
    data_aktualizacji DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_czytelnik) REFERENCES Czytelnicy(id_czytelnik) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Log_Operacji (
    id_log         BIGINT AUTO_INCREMENT PRIMARY KEY,
    tabela         VARCHAR(64) NOT NULL,
    operacja       ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    id_rekordu     VARCHAR(64),
    stary_stan     JSON,
    nowy_stan      JSON,
    uzytkownik     VARCHAR(100),
    data_operacji  DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_log_tabela (tabela, data_operacji)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Statystyki_Dzienne (
    data_dnia              DATE PRIMARY KEY,
    liczba_wypozyczen      INT DEFAULT 0,
    liczba_zwrotow         INT DEFAULT 0,
    liczba_nowych_kar      INT DEFAULT 0,
    suma_kar_naliczonych   DECIMAL(10,2) DEFAULT 0,
    aktywni_czytelnicy     INT DEFAULT 0
) ENGINE=InnoDB;

-- Inicjalizacja punktow lojalnosci dla istniejacych czytelnikow
INSERT INTO Punkty_Lojalnosci (id_czytelnik, punkty)
SELECT id_czytelnik, 0 FROM Czytelnicy
ON DUPLICATE KEY UPDATE punkty = punkty;

-- ===== FULLTEXT INDEX =====
ALTER TABLE Ksiazki ADD FULLTEXT KEY ft_tytul (tytul);

-- ===== INDEKSY POKRYWAJACE =====
CREATE INDEX idx_wyp_czyt_data ON Wypozyczenia(id_czytelnik, data_wypozyczenia, data_zwrotu);
CREATE INDEX idx_kary_oplacona ON Kary(czy_oplacona, kwota);
CREATE INDEX idx_egz_ksiazka   ON Egzemplarze(id_ksiazka, id_wydawnictwo);

-- ===== TRIGGERY AUDIT LOG =====
DELIMITER //

CREATE TRIGGER trg_audit_wyp_ins
AFTER INSERT ON Wypozyczenia
FOR EACH ROW
INSERT INTO Log_Operacji(tabela, operacja, id_rekordu, nowy_stan, uzytkownik)
VALUES ('Wypozyczenia','INSERT', NEW.id_wypozyczenie,
        JSON_OBJECT('id', NEW.id_wypozyczenie,
                    'id_czytelnik', NEW.id_czytelnik,
                    'data_wyp', NEW.data_wypozyczenia,
                    'data_zwr', NEW.data_zwrotu),
        CURRENT_USER())//

CREATE TRIGGER trg_audit_wyp_upd
AFTER UPDATE ON Wypozyczenia
FOR EACH ROW
INSERT INTO Log_Operacji(tabela, operacja, id_rekordu, stary_stan, nowy_stan, uzytkownik)
VALUES ('Wypozyczenia','UPDATE', NEW.id_wypozyczenie,
        JSON_OBJECT('data_zwr', OLD.data_zwrotu),
        JSON_OBJECT('data_zwr', NEW.data_zwrotu),
        CURRENT_USER())//

CREATE TRIGGER trg_audit_kary_ins
AFTER INSERT ON Kary
FOR EACH ROW
INSERT INTO Log_Operacji(tabela, operacja, id_rekordu, nowy_stan, uzytkownik)
VALUES ('Kary','INSERT', NEW.id_kara,
        JSON_OBJECT('id_wyp', NEW.id_wypozyczenie,
                    'kwota', NEW.kwota,
                    'oplacona', NEW.czy_oplacona),
        CURRENT_USER())//

CREATE TRIGGER trg_audit_kary_upd
AFTER UPDATE ON Kary
FOR EACH ROW
INSERT INTO Log_Operacji(tabela, operacja, id_rekordu, stary_stan, nowy_stan, uzytkownik)
VALUES ('Kary','UPDATE', NEW.id_kara,
        JSON_OBJECT('kwota', OLD.kwota, 'oplacona', OLD.czy_oplacona),
        JSON_OBJECT('kwota', NEW.kwota, 'oplacona', NEW.czy_oplacona),
        CURRENT_USER())//

-- ===== TRIGGER KOLEJKI REZERWACJI =====
CREATE TRIGGER trg_kolejka_po_zwrocie
AFTER UPDATE ON Wypozyczenia
FOR EACH ROW
BEGIN
    DECLARE v_id_ksiazka INT;
    DECLARE v_id_rezerwacji INT;
    IF NEW.data_zwrotu IS NOT NULL AND OLD.data_zwrotu IS NULL THEN
        SELECT e.id_ksiazka INTO v_id_ksiazka
        FROM W_E we JOIN Egzemplarze e ON e.id_egzemplarz = we.id_egzemplarz
        WHERE we.id_wypozyczenie = NEW.id_wypozyczenie LIMIT 1;
        SELECT id_rezerwacji INTO v_id_rezerwacji
        FROM Rezerwacje
        WHERE id_ksiazka = v_id_ksiazka AND status_rez='oczekuje'
        ORDER BY pozycja_kolejki ASC LIMIT 1;
        IF v_id_rezerwacji IS NOT NULL THEN
            UPDATE Rezerwacje SET status_rez='zrealizowana' WHERE id_rezerwacji = v_id_rezerwacji;
        END IF;
    END IF;
END//

DELIMITER ;
