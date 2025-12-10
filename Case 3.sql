-- Определить регионы с наибольшим количеством зарегистрированных доноров.

SELECT 
region,
COUNT(id) AS count_donors
FROM 
donorsearch.user_anon_data
GROUP BY region
ORDER BY count_donors DESC;

-- Изучить динамику общего количества донаций в месяц за 2022 и 2023 годы.

SELECT 
DATE_TRUNC('month', donation_date)::date AS date_month,
COUNT(id) AS count_donors
FROM 
donorsearch.donation_anon 
WHERE donation_date BETWEEN '2022-01-01' AND '2024-01-01'
GROUP BY date_month
ORDER BY date_month

-- Определить наиболее активных доноров в системе, учитывая только данные о зарегистрированных и подтвержденных донациях.

SELECT id, confirmed_donations
FROM 
donorsearch.user_anon_data uad
ORDER BY confirmed_donations DESC;

-- Оценить, как система бонусов влияет на зарегистрированные в системе донации.

WITH 
donation_bonus AS (
SELECT 
uad.id,
uad.confirmed_donations,
COALESCE(uab.user_bonus_count, 0) AS user_bonus_count
FROM 
donorsearch.user_anon_data uad
LEFT JOIN donorsearch.user_anon_bonus uab ON uad.id = uab.user_id)
SELECT 
CASE 
	WHEN user_bonus_count > 0 THEN 'Получили бонусы'
	ELSE 'Не получили бонусы'
END AS bonus,
COUNT(id) AS count_donators,
AVG(confirmed_donations) AS avg_donations
FROM donation_bonus 
GROUP BY bonus;


-- Исследовать вовлечение новых доноров через социальные сети. 
-- Узнать, сколько по каким каналам пришло доноров, и среднее количество донаций по каждому каналу.

SELECT
CASE 
	WHEN autho_vk IS TRUE THEN 'VK'
	WHEN autho_ok IS TRUE THEN 'OK'
	WHEN autho_tg IS TRUE THEN 'TG'
	WHEN autho_yandex IS TRUE THEN 'YA'
	WHEN autho_google IS TRUE THEN 'GOOGLE'
END AS auth_type,
COUNT(id) AS count_donors,
SUM(confirmed_donations) AS count_donations,
ROUND(AVG(confirmed_donations), 2) AS avg_donations
FROM 
donorsearch.user_anon_data uad 
GROUP BY auth_type ;

-- Сравнить активность однократных доноров со средней активностью повторных доноров.

WITH 
donators AS (
SELECT user_id, 
COUNT(id) AS count_donations
FROM 
donorsearch.donation_anon da 
WHERE da.donation_date > '2020-01-01'
GROUP BY user_id
ORDER BY count_donations DESC)
SELECT 
	CASE 
		WHEN count_donations BETWEEN 2 AND 3 THEN '2-3'
		WHEN count_donations BETWEEN 4 AND 5 THEN '4-5'
		WHEN count_donations BETWEEN 0 AND 1 THEN '0-1'
		ELSE '>=6'
	END AS donor_group,
	COUNT(user_id) AS count_donators
	FROM 
	donators 
GROUP BY donor_group
ORDER BY donor_group ASC;

-- Сравнить данные о планируемых донациях с фактическими данными, чтобы оценить эффективность планирования.

-- |donation_type|total_planned_donations|completed_donations|completion_rate|
-- |-------------|-----------------------|-------------------|---------------|
-- |Безвозмездно |          22903        |        4950       |      21.61    |
-- |Платно       |          3299         |        429        |      13.00    |


WITH 
planned_donations AS (
	SELECT 
		DISTINCT user_id, donation_type, donation_date
	FROM 
		donorsearch.donation_plan dp),
actual_donations AS (
	SELECT DISTINCT user_id, donation_date
  	FROM donorsearch.donation_anon
),	
planned_vs_actual AS (
	SELECT
    	pd.user_id,
    	pd.donation_date AS planned_date,
    	pd.donation_type,
		CASE WHEN ad.user_id IS NOT NULL THEN 1 ELSE 0 END AS completed
  	FROM 
  		planned_donations pd
	LEFT JOIN actual_donations ad ON pd.user_id = ad.user_id AND pd.donation_date = ad.donation_date
)
SELECT
  donation_type,
  COUNT(*) AS total_planned_donations,
  SUM(completed) AS completed_donations,
  ROUND(SUM(completed)::numeric /COUNT(*), 2) AS completion_rate
FROM planned_vs_actual
GROUP BY donation_type;


