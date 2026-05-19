-- ============================================================================
-- V01__schema.sql - Struktura bazy danych (DDL)
-- ============================================================================
DROP DATABASE IF EXISTS biblioteka;
CREATE DATABASE biblioteka
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;
USE biblioteka;

CREATE TABLE Czytelnicy (
    id_czytelnik     INT AUTO_INCREMENT PRIMARY KEY,
    imie             VARCHAR(50)  NOT NULL,
    nazwisko         VARCHAR(50)  NOT NULL,
    email            VARCHAR(100) NOT NULL UNIQUE,
    data_rejestracji DATE         NOT NULL DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB;

CREATE TABLE Autorzy (
    id_autor INT AUTO_INCREMENT PRIMARY KEY,
    imie     VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE Kategorie (
    id_kategoria INT AUTO_INCREMENT PRIMARY KEY,
    nazwa        VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE Wydawnictwa (
    id_wydawnictwo INT AUTO_INCREMENT PRIMARY KEY,
    nazwa          VARCHAR(100) NOT NULL,
    kraj           VARCHAR(50),
    rok_wydania    YEAR
) ENGINE=InnoDB;

CREATE TABLE Ksiazki (
    id_ksiazka   INT AUTO_INCREMENT PRIMARY KEY,
    tytul        VARCHAR(200) NOT NULL,
    id_kategoria INT,
    CONSTRAINT fk_ksiazki_kategoria
        FOREIGN KEY (id_kategoria) REFERENCES Kategorie(id_kategoria)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Egzemplarze (
    id_egzemplarz       INT AUTO_INCREMENT PRIMARY KEY,
    numer_inwentarzowy  VARCHAR(20) NOT NULL UNIQUE,
    id_ksiazka          INT NOT NULL,
    id_wydawnictwo      INT,
    CONSTRAINT fk_egz_ksiazka
        FOREIGN KEY (id_ksiazka) REFERENCES Ksiazki(id_ksiazka)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_egz_wydawnictwo
        FOREIGN KEY (id_wydawnictwo) REFERENCES Wydawnictwa(id_wydawnictwo)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Status (
    id_status     INT AUTO_INCREMENT PRIMARY KEY,
    nazwa_statusu VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE Wypozyczenia (
    id_wypozyczenie    INT AUTO_INCREMENT PRIMARY KEY,
    id_czytelnik       INT NOT NULL,
    data_wypozyczenia  DATE NOT NULL,
    data_zwrotu        DATE,
    CONSTRAINT fk_wyp_czytelnik
        FOREIGN KEY (id_czytelnik) REFERENCES Czytelnicy(id_czytelnik)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Kary (
    id_kara         INT AUTO_INCREMENT PRIMARY KEY,
    id_wypozyczenie INT NOT NULL UNIQUE,
    kwota           DECIMAL(8,2) NOT NULL,
    czy_oplacona    BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_kary_wyp
        FOREIGN KEY (id_wypozyczenie) REFERENCES Wypozyczenia(id_wypozyczenie)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE K_A (
    id_ksiazka INT NOT NULL,
    id_autor   INT NOT NULL,
    PRIMARY KEY (id_ksiazka, id_autor),
    CONSTRAINT fk_ka_ksiazka FOREIGN KEY (id_ksiazka) REFERENCES Ksiazki(id_ksiazka)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ka_autor FOREIGN KEY (id_autor) REFERENCES Autorzy(id_autor)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE W_E (
    id_wypozyczenie INT NOT NULL,
    id_egzemplarz   INT NOT NULL,
    PRIMARY KEY (id_wypozyczenie, id_egzemplarz),
    CONSTRAINT fk_we_wyp FOREIGN KEY (id_wypozyczenie) REFERENCES Wypozyczenia(id_wypozyczenie)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_we_egz FOREIGN KEY (id_egzemplarz) REFERENCES Egzemplarze(id_egzemplarz)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE W_S (
    id_ws            INT AUTO_INCREMENT PRIMARY KEY,
    id_wypozyczenie  INT NOT NULL,
    id_status        INT NOT NULL,
    data_zmiany      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ws_wyp FOREIGN KEY (id_wypozyczenie) REFERENCES Wypozyczenia(id_wypozyczenie)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ws_status FOREIGN KEY (id_status) REFERENCES Status(id_status)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Audyt_Czytelnicy (
    id_audyt        INT AUTO_INCREMENT PRIMARY KEY,
    id_czytelnik    INT,
    imie            VARCHAR(50),
    nazwisko        VARCHAR(50),
    email           VARCHAR(100),
    data_usuniecia  DATETIME DEFAULT CURRENT_TIMESTAMP,
    usuniety_przez  VARCHAR(100)
) ENGINE=InnoDB;
