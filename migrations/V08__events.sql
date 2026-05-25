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
