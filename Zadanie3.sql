CREATE OR REPLACE FUNCTION podstawa_wynagrodzenia_chorobowego_3(
    p_imie TEXT,
    p_nazwisko TEXT,
    p_data_rozpoczecia DATE
)
RETURNS NUMERIC AS $$
DECLARE
    p_id_pracownika INTEGER;
    pierwszy_miesiac TEXT;
    ostatni_miesiac TEXT;
    wynik NUMERIC ;
BEGIN
			-- obliczamy pierwszy miesiac tzn. od podanego miesiaca (jako parametr funkcji) odejmujemy 12 miesiecy
			pierwszy_miesiac := to_char(date_trunc('month', p_data_rozpoczecia) - interval '12 month', 'YYYY-MM'); 
    		ostatni_miesiac := to_char(date_trunc('month', p_data_rozpoczecia) - interval '1 month', 'YYYY-MM');

	-- funkcja zwracajaca id pracownika o imieniu i nazwisku podanym jako argumenty.
	-- pozwolilem sobie zalozyc na potrzeby zadania ,ze nie bedzie wiecej osob o tym samym imieniu i nazwisku 
	SELECT id FROM pracownicy WHERE imie = p_imie AND nazwisko = p_nazwisko INTO p_id_pracownika;



    SELECT
        ROUND( AVG(miesieczna_podstawa),2)
      INTO wynik
    FROM(
        SELECT
            ( SUM(
                CASE 
                    WHEN s.proporcjonalny_do_przepracowanych_dni = true
						  -- Przeliczenie na hipoteczne wartosci dla danego miesiaca 
                        THEN sw.kwota * ((30.0 - COALESCE(n.dni_nieobecne, 0)) / 30)
                    ELSE sw.kwota /* jesli s.proporcjonalny_do_przepracowanych_dni = false, wtedy zostawiamy niezmieniona wartosc sw.kwota */
                END
			 -- wyliczenie kowoty brutto 
            ) *0.8629) AS miesieczna_podstawa
			
        FROM Wynagrodzenia AS w
        JOIN skladniki_wynagrodzenia AS sw
          ON w.id = sw.id_wynagrodzenia
        JOIN skladniki AS s
          ON sw.id_skladnika = s.id

		-- dodajemy kolumny z data pierwszego i ostatniego dnia miesiaca.
        JOIN LATERAL(
            SELECT 
                to_date(w.miesiac || '-01', 'YYYY-MM-DD') AS poczatek_mies,
                to_date(w.miesiac || '-01', 'YYYY-MM-DD') + 29 AS koniec_mies
        ) AS m ON true

		-- korzystamy z lateral zeby dynamicznie wyliczac daty nieobecnosci dla kazdego miesiaca.
        LEFT JOIN LATERAL(
         SELECT
		 	-- uzywamy sum na wypadek gdyby było pare okresow nieobecnosci w danym miesiacu.
		 	-- dzieki temu poprawnie rodzielimy okresy nieobecności między miesiące, jesli mamy np nieobecnosc 2022-04-28 do 2022-05-18.
			SUM (GREATEST (0,
			   LEAST(m.koniec_mies, nieobecnosci.data_koncowa) - GREATEST(m.poczatek_mies, nieobecnosci.data_poczatkowa) + 1
			))
			 AS dni_nieobecne
			-- dodajemy 1 poniewaz np. 07.02.2025 - 05.02.2025 = 2 a tak naprawde to sa 3 dni wolnego.
            FROM nieobecnosci
             WHERE nieobecnosci.id_pracownika = w.id_pracownika
              AND nieobecnosci.rodzaj_nieobecnosci = 'chorobowe'
			  -- warunek, dzieki ktoremu rozpatryjemy nieobecnosci w danym miesiacu  
              AND nieobecnosci.data_koncowa >= m.poczatek_mies
              AND nieobecnosci.data_poczatkowa <= m.koniec_mies
        ) AS n ON true

        WHERE w.id_pracownika =  p_id_pracownika
          AND s.wliczac_do_podstawy_chorobowego = true
          AND w.miesiac BETWEEN pierwszy_miesiac AND ostatni_miesiac
		  -- sprawdzamy czy liczba nieobecnosci jest mniejsza od 15
		  AND COALESCE (n.dni_nieobecne, 0) <= 15
        GROUP BY w.miesiac
    ) podsumowanie;

    RETURN wynik;
END;
$$ LANGUAGE plpgsql;


--wywolanie funkcji
SELECT podstawa_wynagrodzenia_chorobowego_3('Zofia', 'Radomska', '2022-08-05') AS podstawa ;

