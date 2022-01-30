CREATE OR REPLACE TABLE t_pavla_mouckova_projekt_SQL_covid19
SELECT c.country ,
	   lt.iso3,  
	   c.`date`,
	   CASE WHEN weekday(c.`date`) IN (5,6) THEN 1 ELSE 0 END AS weekend, 
	   CASE WHEN c.`date` BETWEEN '2020-03-20' AND '2020-06-19' THEN 0
		    WHEN c.`date` BETWEEN '2020-06-20' AND '2020-09-21' THEN 1
		    WHEN c.`date` BETWEEN '2020-09-22' AND '2020-12-20' THEN 2
		    ELSE 3 END AS season,
	   c.confirmed ,
	   t.tests_performed_all_metrics,
	   t.tests_performed,
	   t.people_tested,
	   t.units_unclear
FROM covid19_basic_differences AS c        
JOIN lookup_table lt             								
	ON c.country = lt.country
	AND lt.province IS NULL
LEFT JOIN (SELECT country,
                  `date`, 
                  ISO,
                  tests_performed as tests_performed_all_metrics,
                  SUM(CASE WHEN entity IN ('tests performed', 'tests performed (incl. non-PCR)','samples tested')  THEN tests_performed ELSE 0 END) AS tests_performed,
                  SUM(CASE WHEN entity IN ('units unclear','units unclear (incl. non-PCR)') THEN  tests_performed ELSE 0 END) AS units_unclear,
	          SUM(CASE WHEN entity IN ('people tested', 'people tested (incl. non-PCR)') THEN  tests_performed ELSE 0 END) AS people_tested
            FROM covid19_tests ct 
            GROUP BY country, `date`
          ) AS t								
	ON c.`date` = t.`date`
	AND lt.iso3 = t.ISO
ORDER BY c.`date` DESC, c.country;


CREATE OR REPLACE TABLE t_pavla_mouckova_projekt_SQL_countries  
SELECT distinct e.country,
                c.iso3 ,
                c.surface_area ,
                c.median_age_2018, 
                le.life_exp_1965_2015_diff,
                first_value (e.mortaliy_under5) OVER (PARTITION BY e.country ORDER BY 							
                    CASE WHEN e.mortaliy_under5 IS NULL THEN 2 ELSE 1 END, e.`year` DESC) AS mortality_under5,
                round((first_value (e.gdp) OVER (PARTITION BY e.country ORDER BY 
                    CASE WHEN e.gdp IS NULL THEN 2 ELSE 1 END, e.`year` DESC)) / c.population, 2) AS GDP_pc,
                first_value (e.gini) OVER (PARTITION BY e.country ORDER BY 
                    CASE WHEN e.gini IS NULL THEN 2 ELSE 1 END, e.`year` DESC) AS GINI
FROM economies e 
JOIN countries c 
    ON e.country = c.country
LEFT JOIN ( SELECT le1.*,
	           le2.life_exp_2015,
                   le2.life_exp_2015 - le1.life_exp_1965 AS life_exp_1965_2015_diff
            FROM ( SELECT le.country ,
                          le.iso3 ,
	                  round(le.life_expectancy,3) AS life_exp_1965
                    FROM life_expectancy le 
                    WHERE le.`year` = 1965) AS le1 
                    JOIN (SELECT le.country , 
                                  round(le.life_expectancy,3) AS life_exp_2015
                           FROM life_expectancy le 
                           WHERE le.`year` = 2015
		          ) AS le2
                          ON le1.country = le2.country
		  ) AS le 
	ON c.iso3 = le.iso3;


CREATE OR REPLACE TABLE t_pavla_mouckova_projekt_SQL_religions
SELECT r.country ,
       c.iso3,
       r2.population_total,
       sum(CASE WHEN r.religion = 'Christianity' THEN round(r.population /r2.population_total * 100, 2) ELSE 0 END) AS Christianity,
       sum(CASE WHEN r.religion = 'Islam' THEN round(r.population /r2.population_total * 100, 2)ELSE 0 END) AS Islam,
       sum(CASE WHEN r.religion = 'Unaffiliated Religions' THEN round(r.population /r2.population_total * 100, 2)ELSE 0 END) AS Unaffiliated_Religions,
       sum(CASE WHEN r.religion = 'Hinduism' THEN round(r.population /r2.population_total * 100, 2) ELSE 0 END) AS Hinduism,
       sum(CASE WHEN r.religion = 'Buddhism' THEN round(r.population /r2.population_total * 100, 2) ELSE 0 END) AS Buddhism,
       sum(CASE WHEN r.religion = 'Folk Religions' THEN round(r.population /r2.population_total * 100, 2) ELSE 0 END) AS Folk_Religions,
       sum(CASE WHEN r.religion = 'Other Religions' THEN round(r.population /r2.population_total * 100, 2) ELSE 0 END) AS Other_Religions,
       sum(CASE WHEN r.religion = 'Judaism' THEN round(r.population /r2.population_total * 100, 2) ELSE 0 END) AS Judaism
FROM religions r 
JOIN ( SELECT country ,
              sum(population) AS population_total
       FROM religions  
       WHERE `year` = 2020 
       AND country != 'All countries'
       GROUP BY country 
      ) AS r2
    ON r.country = r2.country
    AND r.`year` = 2020
    AND r.population > 0
JOIN countries AS c
    ON c.country = r.country 
GROUP BY r2.country;


CREATE OR REPLACE TABLE t_pavla_mouckova_projekt_SQL_weather
SELECT w1.`date`,
       w1.city, 
       c.iso3,
       w2.day_temperature_avg,													
       sum(CASE WHEN w1.rain != 0 THEN 3 ELSE 0 end ) AS rainy_hours_sum,  
       max(w1.gust) AS gust_max											
FROM weather w1 
JOIN (SELECT `date`,
              city, 
              avg(temp) AS day_temperature_avg					
      FROM weather 
      WHERE hour BETWEEN 6 AND 18
      GROUP BY `date`, city
     ) AS w2
    ON w1.`date` = w2.`date`
    AND w1.city = w2.city
LEFT JOIN countries c													
    ON w1.city = c.capital_city
WHERE w1.city != 'Brno'
GROUP BY w1.`date`, w1.city;


CREATE OR REPLACE TABLE t_pavla_mouckova_projekt_SQL_final
SELECT te.country,
       te.`date`,
       te.weekend ,
       te.season,
       te.confirmed,
       te.tests_performed_all_metrics,
       te.tests_performed, 
       te.people_tested,
       te.units_unclear,
       re.population_total AS population ,
       round(re.population_total /co.surface_area,2) as population_density,
       co.GDP_pc, 
       co.GINI ,
       co.mortality_under5 ,
       co.life_exp_1965_2015_diff,
       co.median_age_2018,
       re.Christianity, 
       re.Islam, 
       re.Unaffiliated_Religions, 
       re.Buddhism, 
       re.Hinduism, 
       re.Folk_Religions, 
       re.Judaism, 
       re.Other_Religions,
       we.day_temperature_avg,
       we.gust_max ,
       we.rainy_hours_sum 
FROM t_pavla_mouckova_projekt_SQL_covid19 te
LEFT JOIN t_pavla_mouckova_projekt_SQL_weather we
	ON te.iso3 = we.iso3 
	AND te.`date` = we.`date`
LEFT JOIN t_pavla_mouckova_projekt_SQL_countries co 
	ON te.iso3 = co.iso3 
LEFT JOIN t_pavla_mouckova_projekt_SQL_religions re 
	ON te.iso3 = re.iso3
ORDER BY te.`date` DESC, te.country;
