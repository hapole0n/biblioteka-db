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

-- ============================================================================
-- V02__seed.sql - Dane testowe: 125 czytelnikow, 64 autorow, 110 ksiazek
-- ============================================================================
USE biblioteka;

-- CZYTELNICY (125)
INSERT INTO Czytelnicy (imie, nazwisko, email, data_rejestracji) VALUES
('Oleh','Kropyva','oleh.kropyva@stud.pl','2024-10-01'),
('Ihor','Paukov','ihor.paukov@stud.pl','2024-10-02'),
('Anna','Kowalska','anna.kowalska@stud.pl','2024-11-15'),
('Piotr','Nowak','piotr.nowak@stud.pl','2025-01-10'),
('Marta','Wisniewska','marta.w@stud.pl','2025-02-20'),
('Adam','Abdullayev','adam.abdullayev@stud.pl','2024-10-03'),
('Vitaliia','Abram','vitaliia.abram@stud.pl','2024-10-04'),
('Klaudia','Abramczyk','klaudia.abramczyk@stud.pl','2024-10-05'),
('Michal','Aftyka','michal.aftyka@stud.pl','2024-10-06'),
('Matvii','Aksenko','matvii.aksenko@stud.pl','2024-10-07'),
('Kseniya','Alkhovik','kseniya.alkhovik@stud.pl','2024-10-08'),
('Yahor','Altsyvanovich','yahor.altsy@stud.pl','2024-10-09'),
('Olech','Andreichuk','olech.andreichuk@stud.pl','2024-10-10'),
('Daria','Androsenko','daria.androsenko@stud.pl','2024-10-11'),
('Yehor','Andrushchenko','yehor.andrushchenko@stud.pl','2024-10-12'),
('Aliaksei','Aniskevich','aliaksei.aniskevich@stud.pl','2024-10-13'),
('Jakub','Babik','jakub.babik@stud.pl','2024-10-14'),
('Damian','Baczynski','damian.baczynski@stud.pl','2024-10-15'),
('Bartosz','Baginski','bartosz.baginski@stud.pl','2024-10-16'),
('Nazar','Bahmet','nazar.bahmet@stud.pl','2024-10-17'),
('Nadzeya','Bahuminskaya','nadzeya.bahum@stud.pl','2024-10-18'),
('Anton','Bahuminski','anton.bahuminski@stud.pl','2024-10-19'),
('Andrii','Bakhmach','andrii.bakhmach@stud.pl','2024-10-20'),
('Oleh','Balashov','oleh.balashov@stud.pl','2024-10-21'),
('Kamil','Banaszek','kamil.banaszek@stud.pl','2024-10-22'),
('Paulina','Banaszek','paulina.banaszek@stud.pl','2024-10-23'),
('Zuzanna','Barabasz','zuzanna.barabasz@stud.pl','2024-10-24'),
('Jakub','Baran','jakub.baran@stud.pl','2024-10-25'),
('Vadzim','Baranouski','vadzim.baranouski@stud.pl','2024-10-26'),
('Artur','Barbarych','artur.barbarych@stud.pl','2024-10-27'),
('Rafal','Bardzel','rafal.bardzel@stud.pl','2024-10-28'),
('Marcelina','Bartnik','marcelina.bartnik@stud.pl','2024-10-29'),
('Jakub','Barwicki','jakub.barwicki@stud.pl','2024-10-30'),
('Szymon','Barylka','szymon.barylka@stud.pl','2024-10-31'),
('Raman','Barysevich','raman.barysevich@stud.pl','2024-11-01'),
('Ilya','Belabarodau','ilya.belabarodau@stud.pl','2024-11-02'),
('Yaroslava','Berezhan','yaroslava.berezhan@stud.pl','2024-11-03'),
('Pawel','Berniak','pawel.berniak@stud.pl','2024-11-04'),
('Dmytro','Bernyk','dmytro.bernyk@stud.pl','2024-11-05'),
('Vitalii','Bezkorvainy','vitalii.bezkor@stud.pl','2024-11-06'),
('Szymon','Bialy','szymon.bialy@stud.pl','2024-11-07'),
('Bohdan','Biliak','bohdan.biliak@stud.pl','2024-11-08'),
('Yeva','Bilous','yeva.bilous@stud.pl','2024-11-09'),
('Yahor','Bitel','yahor.bitel@stud.pl','2024-11-10'),
('Alisa','Boiko','alisa.boiko@stud.pl','2024-11-11'),
('Danylo','Bolotian','danylo.bolotian@stud.pl','2024-11-12'),
('Kacper','Bonat','kacper.bonat@stud.pl','2024-11-13'),
('Anastasiia','Bonda','anastasiia.bonda@stud.pl','2024-11-14'),
('Volodymyr','Bondarenko','volodymyr.bondarenko@stud.pl','2024-11-15'),
('Justyna','Borowiec','justyna.borowiec@stud.pl','2024-11-16'),
('Vadym','Bortnichuk','vadym.bortnichuk@stud.pl','2024-11-17'),
('Maksym','Borys','maksym.borys@stud.pl','2024-11-18'),
('Jagoda','Brzozka','jagoda.brzozka@stud.pl','2024-11-19'),
('Michal','Budnicki','michal.budnicki@stud.pl','2024-11-20'),
('Pawel','Butrym','pawel.butrym@stud.pl','2024-11-21'),
('Uladzislau','Bychkou','uladzislau.bychkou@stud.pl','2024-11-22'),
('Daniil','Byk','daniil.byk@stud.pl','2024-11-23'),
('Orest','Cheretskyi','orest.cheretskyi@stud.pl','2024-11-24'),
('Wiktoria','Chmielewska','wiktoria.chmielewska@stud.pl','2024-11-25'),
('Bartlomiej','Chmielewski','bartlomiej.chmielewski@stud.pl','2024-11-26'),
('Piotr','Cholewa','piotr.cholewa@stud.pl','2024-11-27'),
('Mykhailo','Chudnyi','mykhailo.chudnyi@stud.pl','2024-11-28'),
('Alesia','Chumak','alesia.chumak@stud.pl','2024-11-29'),
('Bohdan','Chumak','bohdan.chumak@stud.pl','2024-11-30'),
('Anastasiya','Chyhryn','anastasiya.chyhryn@stud.pl','2024-12-01'),
('Pawel','Cislo','pawel.cislo@stud.pl','2024-12-02'),
('Rafal','Cybula','rafal.cybula@stud.pl','2024-12-03'),
('Karolina','Czarko','karolina.czarko@stud.pl','2024-12-04'),
('Jan','Czubak','jan.czubak@stud.pl','2024-12-05'),
('Dmytro','Davydiuk','dmytro.davydiuk@stud.pl','2024-12-06'),
('Yaroslava','Dehtiarenko','yaroslava.dehtiar@stud.pl','2024-12-07'),
('Mikolaj','Delikat','mikolaj.delikat@stud.pl','2024-12-08'),
('Mykola','Derevianko','mykola.derevianko@stud.pl','2024-12-09'),
('Piotr','Debek','piotr.debek@stud.pl','2024-12-10'),
('Dmytro','Dikan','dmytro.dikan@stud.pl','2024-12-11'),
('Maksym','Dmytruk','maksym.dmytruk@stud.pl','2024-12-12'),
('Oleksandr','Dobronravov','oleksandr.dobronravov@stud.pl','2024-12-13'),
('Karol','Domownik','karol.domownik@stud.pl','2024-12-14'),
('Karyna','Dorash','karyna.dorash@stud.pl','2024-12-15'),
('Anna','Drewienkowska','anna.drewien@stud.pl','2024-12-16'),
('Taisiia','Drozhzha','taisiia.drozhzha@stud.pl','2024-12-17'),
('Tetiana','Dubii','tetiana.dubii@stud.pl','2024-12-18'),
('Aleksandra','Dubil','aleksandra.dubil@stud.pl','2024-12-19'),
('Olech','Duda','olech.duda@stud.pl','2024-12-20'),
('Krystian','Dudzinski','krystian.dudzinski@stud.pl','2024-12-21'),
('Artsem','Dzemiantsevich','artsem.dzem@stud.pl','2024-12-22'),
('Yahor','Dzenisiuk','yahor.dzenisiuk@stud.pl','2024-12-23'),
('Serhii','Dziailo','serhii.dziailo@stud.pl','2024-12-24'),
('Olga','Dziak','olga.dziak@stud.pl','2024-12-25'),
('Izabela','Eciak','izabela.eciak@stud.pl','2024-12-26'),
('Vladyslav','Fedoniuk','vladyslav.fedoniuk@stud.pl','2024-12-27'),
('Jakub','Fedorowicz','jakub.fedorowicz@stud.pl','2024-12-28'),
('Bartosz','Filipek','bartosz.filipek@stud.pl','2024-12-29'),
('Mariia','Flidermoiz','mariia.flidermoiz@stud.pl','2024-12-30'),
('Ostap','Flotchuk','ostap.flotchuk@stud.pl','2024-12-31'),
('Maksym','Gabruk','maksym.gabruk@stud.pl','2025-01-02'),
('Julia','Gaska','julia.gaska@stud.pl','2025-01-03'),
('Sebastian','Gil','sebastian.gil@stud.pl','2025-01-04'),
('Marcin','Glab','marcin.glab@stud.pl','2025-01-05'),
('Szymon','Gnat','szymon.gnat@stud.pl','2025-01-06'),
('Alicja','Godziek','alicja.godziek@stud.pl','2025-01-07'),
('Kacper','Godziszewski','kacper.godziszewski@stud.pl','2025-01-08'),
('Przemyslaw','Goluch','przemyslaw.goluch@stud.pl','2025-01-09'),
('Martyna','Golebiowska','martyna.goleb@stud.pl','2025-01-10'),
('Krzysztof','Grabowski','krzysztof.grabowski@stud.pl','2025-01-11'),
('Gabriel','Grzybowski','gabriel.grzybowski@stud.pl','2025-01-12'),
('Jakub','Guzewicz','jakub.guzewicz@stud.pl','2025-01-13'),
('Oleksii','Halanzha','oleksii.halanzha@stud.pl','2025-01-14'),
('Ivan','Havryliak','ivan.havryliak@stud.pl','2025-01-15'),
('Vadym','Havrylik','vadym.havrylik@stud.pl','2025-01-16'),
('Roza','Henkiel','roza.henkiel@stud.pl','2025-01-17'),
('Aliaksandr','Hetman','aliaksandr.hetman@stud.pl','2025-01-18'),
('Volodymyr','Hnatiak','volodymyr.hnatiak@stud.pl','2025-01-19'),
('Anastasia','Hopchuk','anastasia.hopchuk@stud.pl','2025-01-20'),
('Dmytro','Hromik','dmytro.hromik@stud.pl','2025-01-21'),
('Aliaksandra','Hrynkevych','aliaksandra.hryn@stud.pl','2025-01-22'),
('Alina','Ivanova','alina.ivanova@stud.pl','2025-01-23'),
('Olha','Ivanova','olha.ivanova@stud.pl','2025-01-24'),
('Yauhenii','Ivus','yauhenii.ivus@stud.pl','2025-01-25'),
('Maciej','Jachec','maciej.jachec@stud.pl','2025-01-26'),
('Natalia','Jarzabek','natalia.jarzabek@stud.pl','2025-01-27'),
('Hanna','Jasinska','hanna.jasinska@stud.pl','2025-01-28'),
('Volodymyr','Kalinin','volodymyr.kalinin@stud.pl','2025-01-29'),
('Maksymilian','Kaluza','maksymilian.kaluza@stud.pl','2025-01-30'),
('Ilia','Kaminskyi','ilia.kaminskyi@stud.pl','2025-01-31');

-- AUTORZY (64)
INSERT INTO Autorzy (imie, nazwisko) VALUES
('Adam','Mickiewicz'),('Henryk','Sienkiewicz'),('Stanislaw','Lem'),('Olga','Tokarczuk'),('Andrzej','Sapkowski'),
('Boleslaw','Prus'),('Wladyslaw','Reymont'),('Stefan','Zeromski'),('Eliza','Orzeszkowa'),('Maria','Konopnicka'),
('Juliusz','Slowacki'),('Cyprian','Norwid'),('Czeslaw','Milosz'),('Wislawa','Szymborska'),('Witold','Gombrowicz'),
('Bruno','Schulz'),('Stanislaw','Witkiewicz'),('Ryszard','Kapuscinski'),('Hanna','Krall'),('Slawomir','Mrozek'),
('Marek','Krajewski'),('Tadeusz','Konwicki'),('Jaroslaw','Iwaszkiewicz'),('Maria','Dabrowska'),('Joanna','Bator'),
('Karl','Marx'),('Friedrich','Engels'),('Fiodor','Dostojewski'),('Lew','Tolstoj'),('Aleksander','Puszkin'),
('Anton','Czechow'),('Mikolaj','Gogol'),('Michail','Bulhakov'),('Taras','Shevchenko'),('Lesia','Ukrainka'),
('Ivan','Franko'),('Mykhailo','Kotsiubynsky'),('Vasyl','Stus'),('Lina','Kostenko'),('Olha','Kobylianska'),
('Volodymyr','Vynnychenko'),('Mykhailo','Stelmakh'),('Yurii','Andrukhovych'),('William','Shakespeare'),('Miguel','Cervantes'),
('Johann','Goethe'),('Victor','Hugo'),('Charles','Dickens'),('Jane','Austen'),('Mark','Twain'),
('Ernest','Hemingway'),('George','Orwell'),('Franz','Kafka'),('Albert','Camus'),('Gabriel','Marquez'),
('John','Tolkien'),('George','Martin'),('Antoine','Saint-Exupery'),('Umberto','Eco'),('Haruki','Murakami'),
('Stephen','King'),('Dante','Alighieri'),('Henrik','Ibsen'),('Joanne','Rowling');

-- KATEGORIE
INSERT INTO Kategorie (nazwa) VALUES
('Powiesc historyczna'),('Fantastyka'),('Science Fiction'),('Poezja'),('Literatura wspolczesna'),
('Klasyka polska'),('Klasyka rosyjska'),('Klasyka ukrainska'),('Klasyka swiatowa'),('Filozofia'),
('Ekonomia polityczna'),('Dramat'),('Powiesc kryminalna'),('Reportaz'),('Literatura dziecieca');

-- WYDAWNICTWA
INSERT INTO Wydawnictwa (nazwa, kraj, rok_wydania) VALUES
('PWN','Polska',1951),('Czytelnik','Polska',1944),('SuperNOWA','Polska',1990),
('Wydawnictwo Literackie','Polska',1953),('Iskry','Polska',1953),('Znak','Polska',1959),
('W.A.B.','Polska',1991),('Proszynski','Polska',1990),('Rebis','Polska',1991),('MUZA','Polska',1990),
('Penguin Books','Wielka Brytania',1935),('Random House','USA',1927),('Folio','Ukraina',1991),
('Azbuka','Rosja',1995),('Suhrkamp','Niemcy',1950);

-- KSIAZKI (110)
INSERT INTO Ksiazki (tytul, id_kategoria) VALUES
('Pan Tadeusz',4),('Quo Vadis',1),('Solaris',3),('Bieguni',5),('Wiedzmin: Ostatnie zyczenie',2),
('Dziady',12),('Konrad Wallenrod',6),('Ballady i romanse',4),('Ogniem i mieczem',1),('Potop',1),
('Pan Wolodyjowski',1),('Krzyzacy',1),('Lalka',6),('Faraon',1),('Chlopi',6),
('Ziemia obiecana',6),('Przedwiosnie',6),('Ludzie bezdomni',6),('Nad Niemnem',6),('Mendel Gdanski',6),
('Kordian',12),('Balladyna',12),('Promethidion',4),('Zniewolony umysl',10),('Dolina Issy',5),
('Wiersze wybrane',4),('Ferdydurke',6),('Kosmos',5),('Sklepy cynamonowe',6),('Sanatorium pod klepsydra',6),
('Szewcy',12),('Cesarz',14),('Heban',14),('Imperium',14),('Zdazyc przed Panem Bogiem',14),
('Tango',12),('Smierc w Breslau',13),('Mala apokalipsa',5),('Brzezina',5),('Noce i dnie',6),
('Piaskowa Gora',5),('Ksiegi Jakubowe',5),('Prawiek i inne czasy',5),('Cyberiada',3),('Bajki robotow',3),
('Niezwyciezony',3),('Wiedzmin: Miecz przeznaczenia',2),('Wiedzmin: Krew elfow',2),('Wiedzmin: Czas pogardy',2),('Wiedzmin: Chrzest ognia',2),
('Wiedzmin: Wieza Jaskolki',2),('Wiedzmin: Pani Jeziora',2),('Wiedzmin: Sezon burz',2),('Kapital. Tom I',11),('Kapital. Tom II',11),
('Manifest komunistyczny',11),('Ideologia niemiecka',10),('Krytyka programu gotajskiego',11),('Zbrodnia i kara',7),('Bracia Karamazow',7),
('Idiota',7),('Notatki z podziemia',7),('Wojna i pokoj',7),('Anna Karenina',7),('Eugeniusz Oniegin',4),
('Trzy siostry',12),('Wisniowy sad',12),('Martwe dusze',7),('Mistrz i Malgorzata',7),('Kobzar',8),
('Lisova pisnia',8),('Zachar Berkut',8),('Tini zabutykh predkiv',8),('Palimpsesty',8),('Berestechko',8),
('Marusia Churai',8),('Zemlia',8),('Sonyachna mashyna',8),('Moscoviada',8),('Hamlet',12),
('Romeo i Julia',12),('Makbet',12),('Don Kichot',9),('Faust',12),('Nedznicy',9),
('Dzwonnik z Notre Dame',9),('Oliver Twist',9),('Opowiesc o dwoch miastach',9),('Duma i uprzedzenie',9),('Przygody Tomka Sawyera',15),
('Stary czlowiek i morze',9),('Komu bije dzwon',9),('Rok 1984',9),('Folwark zwierzecy',9),('Proces',9),
('Przemiana',9),('Dzuma',9),('Obcy',9),('Sto lat samotnosci',9),('Hobbit',2),
('Wladca Pierscieni: Druzyna Pierscienia',2),('Wladca Pierscieni: Dwie wieze',2),('Wladca Pierscieni: Powrot krola',2),('Gra o tron',2),('Maly Ksiaze',15),
('Imie rozy',13),('Norwegian Wood',5),('Lsnienie',2),('Boska Komedia',4),('Domek dla lalek',12);

-- K_A
INSERT INTO K_A (id_ksiazka, id_autor) VALUES
(1,1),(2,2),(3,3),(4,4),(5,5),(6,1),(7,1),(8,1),(9,2),(10,2),(11,2),(12,2),(13,6),(14,6),(15,7),(16,7),
(17,8),(18,8),(19,9),(20,10),(21,11),(22,11),(23,12),(24,13),(25,13),(26,14),(27,15),(28,15),(29,16),(30,16),
(31,17),(32,18),(33,18),(34,18),(35,19),(36,20),(37,21),(38,22),(39,23),(40,24),(41,25),(42,4),(43,4),
(44,3),(45,3),(46,3),(47,5),(48,5),(49,5),(50,5),(51,5),(52,5),(53,5),
(54,26),(55,26),(56,26),(56,27),(57,26),(57,27),(58,26),
(59,28),(60,28),(61,28),(62,28),(63,29),(64,29),(65,30),(66,31),(67,31),(68,32),(69,33),
(70,34),(71,35),(72,36),(73,37),(74,38),(75,39),(76,39),(77,40),(78,41),(79,43),
(80,44),(81,44),(82,44),(83,45),(84,46),(85,47),(86,47),(87,48),(88,48),(89,49),(90,50),
(91,51),(92,51),(93,52),(94,52),(95,53),(96,53),(97,54),(98,54),(99,55),
(100,56),(101,56),(102,56),(103,56),(104,57),(105,58),(106,59),(107,60),(108,61),(109,62),(110,63);

-- STATUS
INSERT INTO Status (nazwa_statusu) VALUES ('zarezerwowane'),('wypozyczone'),('zwrocone'),('przetrzymane'),('anulowane');

-- EGZEMPLARZE
INSERT INTO Egzemplarze (numer_inwentarzowy, id_ksiazka, id_wydawnictwo) VALUES
('INW-001',1,4),('INW-002',1,4),('INW-003',1,1),('INW-004',2,2),('INW-005',2,2),('INW-006',2,5),
('INW-007',3,3),('INW-008',3,8),('INW-009',3,3),('INW-010',4,7),('INW-011',4,7),
('INW-012',5,3),('INW-013',5,3),('INW-014',5,3),('INW-015',6,4),('INW-016',6,4),
('INW-017',7,4),('INW-018',7,1),('INW-019',8,4),('INW-020',8,1),('INW-021',9,2),('INW-022',9,2),
('INW-023',10,2),('INW-024',10,2),('INW-025',11,2),('INW-026',11,5),('INW-027',12,2),('INW-028',12,2),
('INW-029',13,4),('INW-030',13,4),('INW-031',14,4),('INW-032',14,4),('INW-033',15,4),('INW-034',15,4),
('INW-035',16,4),('INW-036',16,1),('INW-037',17,4),('INW-038',18,4),('INW-039',19,4),('INW-040',20,1),
('INW-041',21,4),('INW-042',22,4),('INW-043',23,4),('INW-044',24,6),('INW-045',25,6),('INW-046',26,4),
('INW-047',27,2),('INW-048',28,2),('INW-049',29,4),('INW-050',30,4),('INW-051',31,4),
('INW-052',32,2),('INW-053',33,2),('INW-054',34,2),('INW-055',35,2),('INW-056',36,4),('INW-057',37,9),
('INW-058',38,2),('INW-059',39,2),('INW-060',40,2),('INW-061',41,10),('INW-062',42,7),('INW-063',43,7),
('INW-064',44,8),('INW-065',45,8),('INW-066',46,8),
('INW-067',47,3),('INW-068',47,3),('INW-069',48,3),('INW-070',48,3),('INW-071',49,3),('INW-072',50,3),
('INW-073',51,3),('INW-074',52,3),('INW-075',53,3),
('INW-076',54,6),('INW-077',54,15),('INW-078',55,6),('INW-079',56,15),('INW-080',57,15),('INW-081',58,15),
('INW-082',59,9),('INW-083',59,14),('INW-084',60,9),('INW-085',60,14),('INW-086',61,9),('INW-087',62,9),
('INW-088',63,9),('INW-089',63,14),('INW-090',64,9),('INW-091',65,4),('INW-092',66,9),('INW-093',67,9),
('INW-094',68,9),('INW-095',69,9),('INW-096',69,14),
('INW-097',70,13),('INW-098',71,13),('INW-099',72,13),('INW-100',73,13),('INW-101',74,13),('INW-102',75,13),
('INW-103',76,13),('INW-104',77,13),('INW-105',78,13),('INW-106',79,13),
('INW-107',80,11),('INW-108',80,4),('INW-109',81,11),('INW-110',82,11),('INW-111',83,11),('INW-112',84,15),
('INW-113',85,9),('INW-114',86,9),('INW-115',87,11),('INW-116',88,11),('INW-117',89,11),('INW-118',90,9),
('INW-119',91,11),('INW-120',92,11),('INW-121',93,11),('INW-122',93,9),('INW-123',94,11),('INW-124',95,15),
('INW-125',96,15),('INW-126',97,11),('INW-127',98,11),('INW-128',99,9),
('INW-129',100,9),('INW-130',100,11),('INW-131',101,9),('INW-132',102,9),('INW-133',103,9),('INW-134',104,9),
('INW-135',105,4),('INW-136',106,4),('INW-137',107,4),('INW-138',108,9),('INW-139',109,4),('INW-140',110,12);

-- WYPOZYCZENIA (55)
INSERT INTO Wypozyczenia (id_czytelnik, data_wypozyczenia, data_zwrotu) VALUES
(1,'2025-03-01','2025-03-15'),(2,'2025-03-05','2025-03-20'),(3,'2025-04-10',NULL),(4,'2025-04-12','2025-04-25'),(5,'2025-05-01',NULL),
(6,'2025-03-02','2025-03-16'),(7,'2025-03-03','2025-03-18'),(8,'2025-03-04',NULL),(9,'2025-03-06','2025-03-22'),(10,'2025-03-08','2025-03-25'),
(11,'2025-03-10',NULL),(12,'2025-03-12','2025-03-30'),(13,'2025-03-15','2025-04-01'),(14,'2025-03-18',NULL),(15,'2025-03-20','2025-04-05'),
(16,'2025-03-22','2025-04-08'),(17,'2025-03-25',NULL),(18,'2025-03-28','2025-04-12'),(19,'2025-04-01','2025-04-15'),(20,'2025-04-03',NULL),
(21,'2025-04-05','2025-04-20'),(22,'2025-04-07','2025-04-22'),(23,'2025-04-10',NULL),(24,'2025-04-12','2025-04-26'),(25,'2025-04-15','2025-04-30'),
(26,'2025-04-17',NULL),(27,'2025-04-20','2025-05-05'),(28,'2025-04-22','2025-05-07'),(29,'2025-04-25',NULL),(30,'2025-04-28','2025-05-10'),
(31,'2025-05-01','2025-05-15'),(32,'2025-05-02',NULL),(33,'2025-05-03','2025-05-17'),(34,'2025-05-04',NULL),(35,'2025-05-05','2025-05-18'),
(36,'2025-05-06',NULL),(37,'2025-05-07','2025-05-19'),(38,'2025-05-08',NULL),(39,'2025-05-09','2025-05-20'),(40,'2025-05-10',NULL),
(50,'2025-04-15','2025-04-29'),(60,'2025-04-20',NULL),(70,'2025-04-25','2025-05-09'),(80,'2025-04-28',NULL),(90,'2025-05-01','2025-05-14'),
(100,'2025-05-03',NULL),(110,'2025-05-05','2025-05-18'),(120,'2025-05-07',NULL),
(45,'2025-03-15','2025-04-02'),(55,'2025-03-20',NULL),(65,'2025-04-01','2025-04-16'),(75,'2025-04-05','2025-04-19'),(85,'2025-04-10',NULL),
(95,'2025-04-15','2025-04-28'),(105,'2025-04-20',NULL);

-- KARY (20)
INSERT INTO Kary (id_wypozyczenie, kwota, czy_oplacona) VALUES
(1,5.00,TRUE),(2,10.50,FALSE),(3,25.00,FALSE),(4,3.00,TRUE),(5,15.00,FALSE),
(8,12.00,FALSE),(11,8.50,TRUE),(14,30.00,FALSE),(17,5.00,FALSE),(20,18.00,FALSE),
(23,22.50,FALSE),(26,7.50,TRUE),(29,40.00,FALSE),(32,11.00,FALSE),(34,6.00,TRUE),
(36,16.50,FALSE),(38,9.00,FALSE),(40,28.00,FALSE),(42,14.50,FALSE),(50,19.00,FALSE);

-- W_E
INSERT INTO W_E (id_wypozyczenie, id_egzemplarz) VALUES
(1,1),(2,4),(3,12),(4,15),(5,2),(6,7),(7,21),(8,29),(9,67),(10,76),
(11,97),(12,107),(13,113),(14,121),(15,129),(16,53),(17,37),(18,46),(19,33),(20,24),
(21,28),(22,58),(23,82),(24,90),(25,111),(26,49),(27,123),(28,131),(29,135),(30,140),
(31,72),(32,99),(33,118),(34,127),(35,68),(36,84),(37,61),(38,102),(39,114),(40,128),
(41,11),(42,20),(43,30),(44,42),(45,44),(46,55),(47,57),(48,64),(49,71),(50,78),
(51,89),(52,100),(53,106),(54,116),(55,122);

-- W_S
INSERT INTO W_S (id_wypozyczenie, id_status, data_zmiany) VALUES
(1,2,'2025-03-01 10:00:00'),(1,3,'2025-03-15 12:00:00'),(2,2,'2025-03-05 11:00:00'),(2,3,'2025-03-20 12:30:00'),
(3,2,'2025-04-10 09:30:00'),(4,2,'2025-04-12 14:00:00'),(4,3,'2025-04-25 10:00:00'),(5,2,'2025-05-01 14:00:00'),
(6,2,'2025-03-02 10:00:00'),(6,3,'2025-03-16 11:00:00'),(7,2,'2025-03-03 12:00:00'),(7,3,'2025-03-18 13:00:00'),
(8,2,'2025-03-04 10:00:00'),(9,2,'2025-03-06 09:00:00'),(9,3,'2025-03-22 11:00:00'),(10,2,'2025-03-08 14:30:00'),
(10,3,'2025-03-25 09:00:00'),(11,2,'2025-03-10 11:00:00'),(15,2,'2025-03-20 10:00:00'),(15,3,'2025-04-05 11:30:00'),
(20,2,'2025-04-03 10:00:00'),(23,2,'2025-04-10 10:00:00'),(29,2,'2025-04-25 10:00:00'),(34,2,'2025-05-04 10:00:00'),
(40,2,'2025-05-10 10:00:00'),(45,2,'2025-05-01 10:00:00'),(45,3,'2025-05-14 11:00:00'),(50,2,'2025-03-20 10:00:00'),
(55,2,'2025-04-20 10:00:00');

-- ============================================================================
-- V03__views.sql - 8 widokow podstawowych (proste + zlozone + aktualizowalny)
-- ============================================================================
USE biblioteka;

CREATE OR REPLACE VIEW v_czytelnicy_publiczni AS
SELECT id_czytelnik, imie, nazwisko FROM Czytelnicy;

CREATE OR REPLACE VIEW v_ksiazki_fantastyka AS
SELECT id_ksiazka, tytul, id_kategoria
FROM Ksiazki
WHERE id_kategoria IN (2, 3)
WITH CHECK OPTION;

CREATE OR REPLACE VIEW v_kategorie_licznosc AS
SELECT kat.id_kategoria, kat.nazwa, COUNT(k.id_ksiazka) AS liczba_ksiazek
FROM Kategorie kat
LEFT JOIN Ksiazki k ON k.id_kategoria = kat.id_kategoria
GROUP BY kat.id_kategoria, kat.nazwa;

CREATE OR REPLACE VIEW v_ksiazki_pelne AS
SELECT k.id_ksiazka, k.tytul, kat.nazwa AS kategoria,
       GROUP_CONCAT(DISTINCT CONCAT(a.imie,' ',a.nazwisko) SEPARATOR ', ') AS autorzy,
       COUNT(DISTINCT e.id_egzemplarz) AS liczba_egzemplarzy
FROM Ksiazki k
LEFT JOIN Kategorie kat ON kat.id_kategoria = k.id_kategoria
LEFT JOIN K_A ka        ON ka.id_ksiazka    = k.id_ksiazka
LEFT JOIN Autorzy a     ON a.id_autor       = ka.id_autor
LEFT JOIN Egzemplarze e ON e.id_ksiazka     = k.id_ksiazka
GROUP BY k.id_ksiazka, k.tytul, kat.nazwa;

CREATE OR REPLACE VIEW v_aktualne_wypozyczenia AS
SELECT w.id_wypozyczenie,
       CONCAT(c.imie,' ',c.nazwisko) AS czytelnik,
       w.data_wypozyczenia,
       DATEDIFF(CURRENT_DATE, w.data_wypozyczenia) AS dni_od_wypozyczenia,
       k.tytul, e.numer_inwentarzowy
FROM Wypozyczenia w
JOIN Czytelnicy c  ON c.id_czytelnik = w.id_czytelnik
JOIN W_E we        ON we.id_wypozyczenie = w.id_wypozyczenie
JOIN Egzemplarze e ON e.id_egzemplarz = we.id_egzemplarz
JOIN Ksiazki k     ON k.id_ksiazka = e.id_ksiazka
WHERE w.data_zwrotu IS NULL;

CREATE OR REPLACE VIEW v_kary_niezaplacone AS
SELECT k.id_kara, CONCAT(c.imie,' ',c.nazwisko) AS czytelnik,
       c.email, k.kwota, w.data_wypozyczenia, w.data_zwrotu
FROM Kary k
JOIN Wypozyczenia w ON w.id_wypozyczenie = k.id_wypozyczenie
JOIN Czytelnicy c   ON c.id_czytelnik = w.id_czytelnik
WHERE k.czy_oplacona = FALSE;

CREATE OR REPLACE VIEW v_historia_statusow AS
SELECT ws.id_ws, w.id_wypozyczenie,
       CONCAT(c.imie,' ',c.nazwisko) AS czytelnik,
       s.nazwa_statusu, ws.data_zmiany
FROM W_S ws
JOIN Wypozyczenia w ON w.id_wypozyczenie = ws.id_wypozyczenie
JOIN Status s       ON s.id_status = ws.id_status
JOIN Czytelnicy c   ON c.id_czytelnik = w.id_czytelnik
ORDER BY w.id_wypozyczenie, ws.data_zmiany;

CREATE OR REPLACE VIEW v_egzemplarze_dostepne AS
SELECT e.id_egzemplarz, e.numer_inwentarzowy, k.tytul,
       wyd.nazwa AS wydawnictwo
FROM Egzemplarze e
JOIN Ksiazki k        ON k.id_ksiazka = e.id_ksiazka
LEFT JOIN Wydawnictwa wyd ON wyd.id_wydawnictwo = e.id_wydawnictwo
WHERE NOT EXISTS (
    SELECT 1 FROM W_E we
    JOIN Wypozyczenia w ON w.id_wypozyczenie = we.id_wypozyczenie
    WHERE we.id_egzemplarz = e.id_egzemplarz AND w.data_zwrotu IS NULL
);

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

-- ============================================================================
-- V07__procedures.sql - 5 procedur skladowanych z transakcjami
-- WYMAGANIE: V06 musi byc juz zaladowane (Punkty_Lojalnosci, Rezerwacje)
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

-- ============================================================================
-- V08__events.sql - 2 zaplanowane zadania (Event Scheduler)
-- ============================================================================
USE biblioteka;
SET GLOBAL event_scheduler = ON;

DELIMITER //

CREATE EVENT IF NOT EXISTS ev_auto_oznacz_przetrzymane
ON SCHEDULE EVERY 1 DAY STARTS (TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY + INTERVAL 2 HOUR)
DO
BEGIN
    INSERT INTO W_S(id_wypozyczenie, id_status)
    SELECT w.id_wypozyczenie,
           (SELECT id_status FROM Status WHERE nazwa_statusu='przetrzymane')
    FROM Wypozyczenia w
    WHERE w.data_zwrotu IS NULL
      AND DATEDIFF(CURRENT_DATE, w.data_wypozyczenia) > 30
      AND NOT EXISTS (
          SELECT 1 FROM W_S ws
          WHERE ws.id_wypozyczenie = w.id_wypozyczenie
            AND ws.id_status = (SELECT id_status FROM Status WHERE nazwa_statusu='przetrzymane')
      );
END//

CREATE EVENT IF NOT EXISTS ev_codzienne_statystyki
ON SCHEDULE EVERY 1 DAY STARTS (TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY + INTERVAL 3 HOUR)
DO
BEGIN
    INSERT INTO Statystyki_Dzienne(
        data_dnia, liczba_wypozyczen, liczba_zwrotow,
        liczba_nowych_kar, suma_kar_naliczonych, aktywni_czytelnicy)
    SELECT
        CURRENT_DATE - INTERVAL 1 DAY,
        (SELECT COUNT(*) FROM Wypozyczenia WHERE data_wypozyczenia=CURRENT_DATE - INTERVAL 1 DAY),
        (SELECT COUNT(*) FROM Wypozyczenia WHERE data_zwrotu     =CURRENT_DATE - INTERVAL 1 DAY),
        (SELECT COUNT(*) FROM Kary k JOIN Wypozyczenia w ON w.id_wypozyczenie=k.id_wypozyczenie
            WHERE w.data_zwrotu=CURRENT_DATE - INTERVAL 1 DAY),
        (SELECT COALESCE(SUM(k.kwota),0) FROM Kary k JOIN Wypozyczenia w ON w.id_wypozyczenie=k.id_wypozyczenie
            WHERE w.data_zwrotu=CURRENT_DATE - INTERVAL 1 DAY),
        (SELECT COUNT(DISTINCT id_czytelnik) FROM Wypozyczenia
            WHERE data_wypozyczenia=CURRENT_DATE - INTERVAL 1 DAY)
    ON DUPLICATE KEY UPDATE liczba_wypozyczen=VALUES(liczba_wypozyczen);
END//

DELIMITER ;

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

-- ============================================================================
-- V10__permissions.sql - migracja zachowana jako no-op
-- ============================================================================
USE biblioteka;

-- Funkcja logowania na rozne profile zostala usunieta z projektu.
-- Baza nie tworzy juz rol MySQL ani kont demonstracyjnych.
