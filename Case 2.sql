-- Определите диапазон заработных плат в общем, а именно средние значения, минимумы и максимумы нижних и верхних порогов зарплаты.

SELECT 
MIN(salary_from) AS min_from,
MIN(salary_to) AS min_to,
MAX(salary_from) AS max_from,
MAX(salary_to) AS max_to,
AVG(salary_from) AS AVG_from,
AVG(salary_to) AS AVG_to
FROM public.parcing_table LIMIT 10;

-- Выявите регионы и компании, в которых сосредоточено наибольшее количество вакансий.

SELECT employer,
COUNT(name) AS count_vac
FROM public.parcing_table pt 
GROUP BY employer
ORDER BY count_vac DESC
LIMIT 10;


SELECT area,
COUNT(name) AS count_vac
FROM public.parcing_table pt 
GROUP BY area
ORDER BY count_vac DESC
LIMIT 10;

-- Проанализируйте, какие преобладают типы занятости, а также графики работы.

SELECT DISTINCT schedule
FROM 
public.parcing_table pt ;


SELECT DISTINCT pt.employment 
FROM 
public.parcing_table pt;

-- Изучите распределение грейдов (Junior, Middle, Senior) среди аналитиков данных и системных аналитиков.

WITH 
sum_count_vac_query AS (SELECT 
COUNT(name) AS sum_count_vac
FROM
public.parcing_table pt 
WHERE 
pt."name" LIKE '%Аналитик данных%' OR 
pt."name" LIKE '%аналитик данных%' OR 
pt."name" LIKE '%Системный аналитик%' OR 
pt."name" LIKE '%Системный аналитик%')
SELECT experience,
COUNT(name) AS count_vac,
ROUND((COUNT(name)::NUMERIC / (SELECT sum_count_vac FROM sum_count_vac_query)) * 100, 2) AS percent_vac
FROM public.parcing_table pt
WHERE 
pt."name" LIKE '%Аналитик данных%' OR 
pt."name" LIKE '%аналитик данных%' OR 
pt."name" LIKE '%Системный аналитик%' OR 
pt."name" LIKE '%системный аналитик%'
GROUP BY experience

-- Выявите основных работодателей, предлагаемые зарплаты и условия труда для аналитиков.

SELECT 
employer,
schedule, 
employment,
AVG(salary_from),
AVG(salary_to),
COUNT(name) AS num_vacancies
FROM public.parcing_table pt
WHERE 
(pt."name" LIKE '%Аналитик данных%' OR 
pt."name" LIKE '%аналитик данных%' OR 
pt."name" LIKE '%Системный аналитик%' OR 
pt."name" LIKE '%системный аналитик%')
GROUP BY employer, schedule, employment
ORDER BY num_vacancies DESC 







