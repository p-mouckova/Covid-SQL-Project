## Covid_SQL_projekt - zadání :
___ 

#### **Zadání:** Od Vašeho kolegy statistika jste obdrželi následující email:

Dobrý den,

snažím se určit faktory, které ovlivňují rychlost šíření koronaviru na úrovni jednotlivých států. Chtěl bych Vás, coby datového analytika, požádat o pomoc s přípravou dat, která potom budu statisticky zpracovávat. Prosím Vás o dodání dat podle požadavků sepsaných níže.

Výsledná data budou panelová, klíče budou stát (country) a den (date). Budu vyhodnocovat model, který bude vysvětlovat denní nárůsty nakažených v jednotlivých zemích. Samotné počty nakažených mi nicméně nejsou nic platné - je potřeba vzít v úvahu také počty provedených testů a počet obyvatel daného státu. Z těchto tří proměnných je potom možné vytvořit vhodnou vysvětlovanou proměnnou. Denní počty nakažených chci vysvětlovat pomocí proměnných několika typů. Každý sloupec v tabulce bude představovat jednu proměnnou. Chceme získat následující sloupce:

#### Časové proměnné
   * binární proměnná pro víkend / pracovní den
   * roční období daného dne (zakódujte prosím jako 0 až 3)
    
#### Proměnné specifické pro daný stát
   * hustota zalidnění - ve státech s vyšší hustotou zalidnění se nákaza může šířit rychleji  
   * HDP na obyvatele - použijeme jako indikátor ekonomické vyspělosti státu  
   * GINI koeficient - má majetková nerovnost vliv na šíření koronaviru?  
   * dětská úmrtnost - použijeme jako indikátor kvality zdravotnictví  
   * medián věku obyvatel v roce 2018 - státy se starším obyvatelstvem mohou být postiženy více
   * podíly jednotlivých náboženství - použijeme jako proxy proměnnou pro kulturní specifika. Pro každé náboženství v daném státě bych chtěl procentní podíl jeho příslušníků na celkovém obyvatelstvu
   * rozdíl mezi očekávanou dobou dožití v roce 1965 a v roce 2015 - státy, ve kterých proběhl rychlý rozvoj mohou reagovat jinak než země, které jsou vyspělé už delší dobu
#### Počasí (ovlivňuje chování lidí a také schopnost šíření viru)
   * průměrná denní (nikoli noční!) teplota
   * počet hodin v daném dni, kdy byly srážky nenulové
   * maximální síla větru v nárazech během dne
    
Napadají Vás ještě nějaké další proměnné, které bychom mohli použít? Pokud vím, měl(a) byste si vystačit s daty z následujících tabulek: countries, economies, life_expectancy, religions, covid19_basic_differences, covid19_testing, weather, lookup_table.

V případě nejasností se mě určitě zeptejte.

S pozdravem, Student (a.k.a. William Gosset)


---
--- 
## Informace o výstupních datech

K získání výsledné tabulky jsou použity 4 pomocné tabulky:

#### 1.	**t_pavla_mouckova_projekt_SQL_covid19**
Tato tabulka obsahuje informace o počtu nakažených lidí a počtu provedených testů.  
Jednotlivé státy reportují počty testů pomocí různých nebo více metrik. 
A protože nevím, jak detailně budou data o šíření koronaviru zpracovávána, rozhodla jsem se vytvořit 
4 sloupce pro počty testů:  
* **tests_performed_all_metrics** – zde jsou počty testů bez ohledu na metriku testování. 
                        U států, které uvádí více metrik, je brána první dostupná hodnota. 
* **tests_performed** – zde jsou počty všech provedených testů, včetně opakovaných testů stejných osob ( 89 států )
* **people_tested** – zde jsou počty testovaných lidí ( 25 států )
* **units_unclear** – zde jsou počty testů u státu, které neuvádí metriku testování a nelze je proto zahrnout do předchozích 2 sloupců ( 4 státy )
#### 2.	**t_pavla_mouckova_projekt_SQL_countries**
Zde jsou vybrána data potřebná k výpočtům hustoty zalidnění, rozdílu očekávané doby dožití, HDP na obyvatele, GINI koeficinetu, úmrtnosti a mediánu věku obyvatel
#### 3. **t_pavla_mouckova_projekt_SQL_religions**
Tato tabulka slouží k výpočtu podílů jednotlivých náboženství na celkové populaci a k transformaci výsledných hodnot z řádků do sloupců pro jednotlivé státy.   
#### 4.	**t_pavla_mouckova_projekt_SQL_weather** 
V této tabulce jsou zpracována data o počasí pro jednotlivé státy .  
___
###Výsledná tabulka 

#### **t_pavla_mouckova_projekt_SQL_final** 
Obsahuje následující informace:

* **country** – název země, v tabulce jsou informace o 190 zemích
* **date** – datum testování, data jsou dostupná od 22.1.2020
* **weekend** – obsahuje hodnotu 0 pro pracovní den a hodnotu 1 pro víkend
* **season** – popisuje roční období daného dne, nabývá následujících hodnot: 0 – jaro, 1 – léto, 
                 2 – podzim, 3- zima
* **confirmed** – udává počet nakažených lidí k danému dni
* **tests_performed_ all_metrics**  – udává počtu provedených testů v daný den bez ohledu na rozdílné. Data o počtech provedených testů  jsou dostupná pro 118 států.     
* **tests_performed** , **people_tested**, **units_unclear** – detailní rozdělení počtu testů dle metrik
* **population** – populace daného státu. Informace o populaci pro jednotlivé státy byla obsažena hned v několika tabulkách s mírně odlišnými hodnotami. Do výsledné tabulky jsem se 
rozhodla použít spočtenou hodnotu celkové populace z tabulky Religions, protože k této hodnotě se vážou podíly jednotlivých náboženství v dané zemi .
* **population_density** – pro hustotu zalidnění jsem nepoužila již dostupné informace z tabulky countries, ale přepočítala jsem ji s výše použitou populací z tabulky Religions.
* **GDP_pc** – udává HDP na obyvatele. Zde jsou použita poslední dostupná data pro jednotlivé státy. Pro 16 státu data nejsou dostupná.
* **GINI** – poslední dostupná data pro GINI koeficient jednotlivý států. Pro 36 států tato data dostupná nejsou
* **mortlity_under5** – údaje o dětské úmrtnosti
* **life_exp_1965_2015_diff** – rozdíl mezi očekávanou dobou dožití v roce 1965 a v roce 2015
* **median_age18** – medián věku obyvatel v roce 2018

Následující sloupce **Christianity** , **Islam, Unaffiliated Religions**, **Hinduism**, **Buddhism**, **Folk Religions**,
 **Other Religions** a **Judaism** udávají podíl těchto náboženství na celkové populaci země v procentech.

Data o počasí jsou dostupná pouze pro 34 států . Tyto hodnoty byly naměřeny v hlavních městech daných států.  
* **day_temperature_avg**– průměrná denní teplota, pro výpočet jsem použila hodnoty v čase 6 – 18 hodin
* **gust_max** – maximální síla větru v nárazech během dne
* **rainy_hours_sum**– počet hodin v daném dni, kdy byly srážky nenulové 
___



