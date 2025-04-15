Zadanie 1
  Napisać funkcję SQL lub zapytanie SQL zwracające podstawę do wyliczania wynagrodzenia
  za czas zwolnienia chorobowego pracownika Jan Kowalski, które rozpoczyna się w dniu
  05.08.2022.
  
    Wykładnia prawna:
      ● Podstawą do wyliczania wynagrodzenia za czas zwolnienia chorobowego jest
      średnia miesięczna (arytmetyczna) wartość wynagrodzeń pracowników z ostatnich
      12-tu miesięcy pracy, po ich “odbruttowieniu”
      ● Do wyliczenia “podstawy” brane są tylko składniki wynagrodzeń, które posiadają
      atrybut wliczac_do_podstawy_chorobowego=TRUE
      ● Dla uproszczenia, “odbruttowienie” stanowi przemnożenie tych wynagrodzeń przez
    współczynnik 0,8629

    
Zadanie 2
  Napisać funkcję SQL lub zapytanie SQL zwracające podstawę do wyliczania wynagrodzenia
  za czas zwolnienia chorobowego pracownika Adam Nowak, które rozpoczyna się w dniu
  05.08.2022.
  
    Wykładnia prawna:
      ● Podstawą do wyliczania wynagrodzenia za czas zwolnienia chorobowego jest
      średnia miesięczna (arytmetyczna) wartość wynagrodzeń pracowników z ostatnich
      12-tu miesięcy pracy, po ich “odbruttowieniu”
      ● Do wyliczenia “podstawy” brane są tylko składniki wynagrodzeń, które posiadają
      atrybut wliczac_do_podstawy_chorobowego=TRUE
      ● Dla przypadków, gdy pracownik nie przepracuje całego miesiąca, uzyskane składniki
      wynagrodzenia, posiadające atrybut
      proporcjonalny_do_przepracowanych_dni=TRUE, należy przeliczyć na hipotetyczne
      wartości jak dla całego miesiąca. Do przeliczeń należy zastosować dni kalendarzowe
      absencji i dla uproszczenia należy przyjąć zasadę, że każdy miesiąc ma 30 dni
      ● Dla uproszczenia, “odbruttowienie” stanowi przemnożenie tych wynagrodzeń przez
      współczynnik 0,8629

      
Zadanie 3 (3. poziom trudności)
  Napisać funkcję SQL lub zapytanie SQL zwracające podstawę do wyliczania wynagrodzenia
  za czas zwolnienia chorobowego pracownika Zofia Radomska, które rozpoczyna się w dniu
  05.08.2022.
  
    Wykładnia prawna:
      ● Podstawą do wyliczania wynagrodzenia za czas zwolnienia chorobowego jest
      średnia miesięczna (arytmetyczna) wartość wynagrodzeń pracowników z ostatnich
      12-tu miesięcy pracy, po ich “odbruttowieniu”
      ● W obliczaniu podstawy pomija się miesiące, w których pracownik nie przepracował
      połowy miesiąca. Dla uproszczenia należy przyjąć zasadę, że są to miesiące w
      których nieobecność przekroczyła 15 dni kalendarzowych
      ● Do wyliczenia “podstawy” brane są tylko składniki wynagrodzeń, które posiadają
      atrybut wliczac_do_podstawy_chorobowego=TRUE
      ● Dla przypadków, gdy pracownik nie przepracuje całego miesiąca, uzyskane składniki
      wynagrodzenia, posiadające atrybut
      proporcjonalny_do_przepracowanych_dni=TRUE, należy przeliczyć na hipotetyczne
      wartości jak dla całego miesiąca. Do przeliczeń należy zastosować dni kalendarzowe
      absencji i dla uproszczenia należy przyjąć zasadę, że każdy miesiąc ma 30 dni.
      ● Dla uproszczenia, “odbruttowienie” stanowi przemnożenie tych wynagrodzeń przez
      współczynnik 0,8629
