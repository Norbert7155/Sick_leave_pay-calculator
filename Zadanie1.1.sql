-- pozwolilem sobie na nazwy zmiennych w jezyku polskim poniewaz kolumny w bazie tez sa nazwane po polsku
-- funkacja o nazwie podstawa_wynagrodzenia_chorobowego przyjmujaca trzy argumenty imie, nazwisko i data rozpoczecia urlopu chorobowego.
-- moze sie pojawic przypadek w ktorym mamy dwoch pracownikow co nazywaja sie tak samo ale na potrzeby zadania przyjalem ,ze taka sytulacja nie bedzie maiala miejsca.

CREATE OR REPLACE FUNCTION podstawa_wynagrodzenia_chorobowego(
	p_imie TEXT,
	p_nazwisko TEXT,
    p_data_rozpoczecia DATE
)  RETURNS NUMERIC AS $$ 
DECLARE 
	p_id_pracownika NUMERIC;
    pierwszy_miesiac TEXT;
    ostatni_miesiac TEXT;
    wynik NUMERIC;
BEGIN
			-- obliczamy pierwszy miesiac tzn. od podanego miesiaca (jako parametr funkcji) odejmujemy 12 miesiecy
		 	pierwszy_miesiac := to_char(date_trunc('month', p_data_rozpoczecia) - interval '12 month', 'YYYY-MM'); 
    		ostatni_miesiac := to_char(date_trunc('month', p_data_rozpoczecia) - interval '1 month', 'YYYY-MM');
			
		-- funkcja zwracajaca id pracownika o imieniu i nazwisku podanym jako argumenty.
		SELECT id FROM pracownicy WHERE imie = p_imie AND nazwisko = p_nazwisko INTO p_id_pracownika;
		
		
		-- liczymy srednia (AVG) z miesieczne_zarobki_brutto i zaokraglamy do 2 miejsc po przecinku (ROUND)
	    SELECT ROUND(AVG(miesieczne_zarobki_brutto),2) INTO wynik
    	FROM (
			/* 
				Podzapytanie select oblicza miesieczne zarobki brutto,
				dla każdego miesiąca miedzy pierwszy_miesiac a ostatni_miesiac,
				dla wynagrodzeń pracownika o id = p_id_pracownika.
			*/
	      	SELECT SUM(sw.kwota) * 0.8629 AS miesieczne_zarobki_brutto 
	      	FROM Wynagrodzenia AS w   
	      	JOIN skladniki_wynagrodzenia AS sw 
			  ON w.id = sw.id_wynagrodzenia        
	      	JOIN skladniki AS s 
			  ON sw.id_skladnika = s.id    
	      	WHERE w.id_pracownika = p_id_pracownika
		        AND s.wliczac_do_podstawy_chorobowego = true       
				-- Uwzględniamy tylko te składniki, które mają być wliczane do podstawy
		        AND w.miesiac BETWEEN pierwszy_miesiac AND ostatni_miesiac
				-- Ograniczenie do miesiąca w przedziale od 'pierwszy_miesiac' do 'ostatni_miesiac'
	      	GROUP BY w.miesiac 
			-- Grupujemy aby dla każdego miesiąca obliczamy sumę składników pensji
    	) AS podsumowanie ;


    RETURN wynik;
END;
$$ LANGUAGE plpgsql;

-- wywolanie funkcji z argumentami imie=jan nazwisko=kowalski i data zwolnienia=2022-08-05 
SELECT podstawa_wynagrodzenia_chorobowego('Jan', 'Kowalski', '2022-08-05') AS podstawa;









