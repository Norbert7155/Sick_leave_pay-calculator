CREATE OR REPLACE FUNCTION podstawa_wynagrodzenia_chorobowego_2(
    p_imie TEXT,
    p_nazwisko TEXT,
    p_data_rozpoczecia DATE
)
RETURNS NUMERIC AS $$
DECLARE
    p_id_pracownika INTEGER;
    pierwszy_miesiac TEXT;
    ostatni_miesiac TEXT;
    wynik NUMERIC;
BEGIN
			-- obliczamy pierwszy miesiac tzn. od podanego miesiaca (jako parametr funkcji) odejmujemy 12 miesiecy
			pierwszy_miesiac := to_char(date_trunc('month', p_data_rozpoczecia) - interval '12 month', 'YYYY-MM'); 
    		ostatni_miesiac := to_char(date_trunc('month', p_data_rozpoczecia) - interval '1 month', 'YYYY-MM');

	-- funkcja zwracajaca id pracownika o imieniu i nazwisku podanym jako argumenty.
	SELECT id FROM pracownicy WHERE imie = p_imie AND nazwisko = p_nazwisko INTO p_id_pracownika;


    SELECT
        ROUND(AVG(miesieczna_podstawa), 2)
      INTO wynik
    FROM(
        SELECT
            ( SUM (
                CASE 
                    WHEN s.proporcjonalny_do_przepracowanych_dni = true
						 -- Przeliczenie na hipoteczne wartosci dla danego miesiaca 
                        THEN sw.kwota * (30.0 / (30.0 - COALESCE(n.dni_nieobecne, 0)))
                    ELSE sw.kwota /* jesli s.proporcjonalny_do_przepracowanych_dni = false, wtedy zostawiamy niezmieniona wartosc sw.kwota */
                END
			 -- wyliczenie kowoty brutto 
            ) *0.8629) AS miesieczna_podstawa
			
        FROM Wynagrodzenia AS w
        JOIN skladniki_wynagrodzenia AS sw
          ON w.id = sw.id_wynagrodzenia
        JOIN skladniki AS s
          ON sw.id_skladnika = s.id

		-- dodajemy kolumny z data pierwszego i ostatniego dnia miesiaca
        JOIN LATERAL(
            SELECT 
                to_date(w.miesiac || '-01', 'YYYY-MM-DD') AS poczatek_mies,
                to_date(w.miesiac || '-01', 'YYYY-MM-DD') + 29 AS koniec_mies
        ) AS m ON TRUE

		-- korzystamy z lateral zeby dynamicznie wyliczac daty nieobecnosci dla kazdego miesiaca.
        LEFT JOIN LATERAL (
			-- uzywamy sum na wypadek gdyby było pare okresow nieobecnosci w danym miesiacu.
            SELECT COALESCE(SUM(data_koncowa - data_poczatkowa + 1), 0) AS dni_nieobecne
			-- dodajemy 1 poniewaz np. 07.02.2025 - 05.02.2025 = 2 a tak naprawde to sa 3 dni wolnego.
            FROM nieobecnosci
            WHERE nieobecnosci.id_pracownika = w.id_pracownika
              AND nieobecnosci.rodzaj_nieobecnosci = 'chorobowe'
			  -- warunek, dzieki ktoremu rozpatryjemy nieobecnosci w danym miesiacu  
              AND nieobecnosci.data_koncowa >= m.poczatek_mies
              AND nieobecnosci.data_poczatkowa <= m.koniec_mies
        ) n ON TRUE

        WHERE w.id_pracownika = p_id_pracownika
          AND s.wliczac_do_podstawy_chorobowego = true
          AND w.miesiac BETWEEN pierwszy_miesiac AND ostatni_miesiac
        GROUP BY w.miesiac
    ) podsumowanie;

    RETURN wynik;
END;
$$ LANGUAGE plpgsql;


--wywolanie funkcji
SELECT podstawa_wynagrodzenia_chorobowego_2('Adam', 'Nowak', '2022-08-05') AS podstawa;

