# Nytt mejl

Syfte: Undersöka hur många % av tillgänglig mark som amvänds för vind deployment i olika kommuner hittills.
 
Ta område med vindklass 3-5. Ändra befolkningsmasken till att man får bygga vind där det bor 75 pers/km2 eller mer.
 
Ta fram fördelningsfunktion för andel som har en viss deployment densitet. Ta bort kommuner som inte har någon vindkraft (annars tror jag det stör hur datan ser ut)
    * NM: kanske scatter(installed, turbine density)
 
Gör en fördelning mer land: Alltså fördelning av deployment density per kommun för Danmark, en för Sverige, en för tyskland, och en för USA. För att se hur mycket de skiljer sig åt per land. Du sade idag att du bara tittat på tre delstater, men vi sade väl att vi skulle kolla på hela USA.
    * NM: Nu förstår jag. Första delen (fördelning per land) har jag gjort. Ska försöka beta av fler delstater i USA också. Kort möte fredag lunch är OK.

## Mitt svar

Fine. Jag vill också börja få lite grepp om de andra parametrarna, turbintäthet i en park till att börja med. Tänkte så här:
 
* Kolla om rotordiameter finns angiven för varje turbin, annars uppskatta med hjälp av turbineffekten. 
* Ta reda på närmaste turbingranne för varje turbin, uttryck avståndet i rotordiametrar och rita histogram. Hur bra stämmer tumregeln minst 5-7 rotordiametrar isär?
* Klustra turbinerna i parker med turbiner som har alla har max X meter till närmaste granne i klustret (testa olika X från 10-30 rotordiametrar).
* Välj ett värde på karakteristiskt turbinavstånd A inom varje park - antingen min, max eller medelavstånd inom parken. Alla tre kan kanske vara rimliga val.
* Beräkna parkyta som ytan av alla cirklar med radie A/2 omkring varje turbin minus allt överlapp. Beräkna sedan turbintäthet i parken.
* Rita histogram över turbintäthet för alla parker, jämför med vårt värde på 5 MW/km2.
 
När vi har bättre koll på turbintäthet i parker blir vår nya "exploateringsgrad" mer konkret.

# To do

1. Why did we mask out areas where turbines exist IRL?
    * split onshore_OK into separate mask categories
    * add all into regional dataframe
    * print summary statistics per country (see dataframe for regional stats)

2. Calculate exploited area
    * calculate total area of each region, and total masked and unmasked areas
    * separate by on and offshore as well
    * calculate power density of (actual) turbines in total and (model) unmasked areas
        for each region (density_total, density_unmasked)
    * calculate exploited area for each region in % using our assumed turbine density
    * redo calculation for entire country and print summary statistics 

3. Time variation of exploited area
    * repeat step 2c, 2d and 2e for each year
    * save result in a matrix (region_name x exploited_area_in_year) and country
        result in a vector, then sort by current exploited and plot top 10 curves

# Nytt mejl

Några tillägg och kommentarer.
 
1. Kolla för alla länder de vindkraftverk som ligger på områden som är förbjudna enligt vår mask. Analysera vilka kriterier som gjorde dem förbjudna. Fokus på de stora dragen, och relativt nya verk. Syfte, testa var masken är för restriktiv.
    * Om många turbiner ligger i protected-area pixlar kan vi disaggregera dem (det finns ~10 undertyper av protected area).
    * Kanske även titta i en liten pixelomgivning till varje turbinpixel. Vi kommer att göra en hel del missar där vi ligger längs en gräns av en typ av maskdata.
    * På sikt (typ punkt 4, eller 7 eller 12) kan vi vända på den här punkten och ta fram bra vindlägen i tillåtna områden enligt vår mask som inte har bebyggts alls. Går det att karakterisera dem på något sätt? Har vi missat en hel kategori av mask?  
        - Ja, jag tänkte också på någon sådan variant. Vi ska ha det i minnet och fundera på hur det görs på ett bra sätt
 
2. Ta fram faktisk täthet av vind MW/m2 på tillåten mark, i kommuner. Fokusera på vindtäta områden, Danmark, nordtyskland, kanske delar av USA. Syfte analysera maximal täthet som hittills uppnåtts.
    * Här kan vi uttrycka tätheten dels i MW/km2 över hela kommunen och dels som procent exploaterad area (om vi antar att vår turbintäthet för en park är någorlunda korrekt).
        - Över hela kommunen tänker jag är mindre intressant. Men såväl % som MW/km2 är ju relevanta mått för oss [Niclas menade MW/km2 över tillåten yta i kommunen]
    * En fördel med att analysera en hel kommun: kommunen motsvarar ofta ett helt minisamhälle med minst en tätort och flera mindre samhällen med landsbygd däremellan. Hade vi valt lite slumpmässiga 10x10 km pixlar så kommer vi ibland att pricka en hel vindpark, och då ser det ut som 100% exploatering ibland är möjligt.
        - Sant

3. Plocka ut 10 kommuner med högst täthet i varje land. Analysera hur tätheten utvecklats över tid. Syfte: Verkar utbyggnaden över tid mattas vi någon särskild nivå?
    * Kanske hjälper att aggregera dessa 10 kommuner och normalisera till exploateringsgrad.
        - Det förstod jag inte
        [Dålig idé. Bättre bara aggregera och göra om beräkningen för hela regionklumpen,
        alltså aggregera kapacitet och area var för sig och sedan ta kvoten.]


# Gammalt mejl

Jag tror vi ska utgå ifrån iden om avvikelser från slumpmässig placering. Så om vi tar ett land, och först plockar bort allt land som har sämre vindförhållanden än x (Detta kan ju tas från data också, vilket vindkraftverk är byggt på stället med sämst vindläge?

Det som vi har kvar är en karta med landklasser, vinddata och befolkningstäthet där man rimligen kan placera vindkraftverk. Frågan är vilken systematik som finns i placeringen som skiljer ifrån den slumpmässiga. Analysera per land med avseende på

Vindproduktion, och hur den har utvecklats över tid
Befolkningstäthet. Finns det en folkningstäthet med över och under representation av vindkraft. Denna analys ska nog både göras på 1km2 och 10 km2 upplösning
Landklasser, troligen bra med ett mer detaljerat dataset.
 
Beroende på tid så kan vi ju sedan analysera hur det påverkar med tidpunkt vindkraftverket byggdes, turbinstorlek etc

En analys till som vore intressant. Om vi tar högsta täthet (nog med uppläsning på 100 km2 här, enskilda parker är ju inte intressanta, utan mer på landskapsnivå). Identifiera de 5 områdena i varje land med högst MW/km2 i. Finns det gemensamma nämnare mellan dessa områden i de olika länderna?

Fredrik



Niclas:

histogram wind quality per turbine (test mean wind speed & annual electricity)
color the dots, either per country or per land type
sanity check: scatter with Danish electricity generation per turbine

for each turbine, add land type, population density in [pixel, <10km, <100km]
 
