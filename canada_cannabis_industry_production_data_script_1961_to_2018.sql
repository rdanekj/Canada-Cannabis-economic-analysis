SELECT * FROM cannabis_c_p.`industr_ prod`;
select distinct(indicator) FROM cannabis_c_p.`industr_ prod`;
select distinct(industry) FROM cannabis_c_p.`industr_ prod`;
select distinct(authority) FROM cannabis_c_p.`industr_ prod`;
select distinct(geo) FROM cannabis_c_p.`industr_ prod`;
SELECT count(distinct(dguid)) FROM cannabis_c_p.`industr_ prod`;
select distinct(ref_date) FROM cannabis_c_p.`industr_ prod`;

SELECT ref_date, geo, indicator, industry, authority, value, count(*)
FROM cannabis_c_p.`industr_ prod` 
GROUP BY ref_date, geo, indicator, industry, authority, value
HAVING count(*) > 1;

SELECT ref_date, geo, indicator, authority, (value *1000000) as "Dollar_Value"
FROM cannabis_c_p.`industr_ prod`
WHERE 
industry = "Cannabis retail stores"
AND authority = "Unlicensed source"
ORDER BY ref_date;

SELECT ref_date, geo, indicator, authority, (value *1000000) as "Dollar_Value"
FROM cannabis_c_p.`industr_ prod`
WHERE 
industry = "Cannabis retail stores"
AND authority = "licensed source"
ORDER BY ref_date;

SELECT ref_date, geo, indicator, authority, (value *1000000) as "Dollar_Value"
FROM cannabis_c_p.`industr_ prod`
WHERE 
industry = "Cannabis cultivation industry"
AND authority = "licensed source"
ORDER BY ref_date;

SELECT ref_date, geo, indicator, authority, (value *1000000) as "Dollar_Value"
FROM cannabis_c_p.`industr_ prod`
WHERE 
industry = "Cannabis cultivation industry"
AND authority = "unlicensed source"
ORDER BY ref_date;

SELECT ref_date, geo, indicator, authority, (value *1000000) as "Dollar_Value"
FROM cannabis_c_p.`industr_ prod`
WHERE 
indicator = "Intermediate consumption"
AND authority = "unlicensed source"
ORDER BY ref_date;

SELECT ref_date, geo, indicator, authority, (value *1000000) as "Dollar_Value"
FROM cannabis_c_p.`industr_ prod`
WHERE 
indicator = "Domestic own-use production"
AND authority = "licensed source"
ORDER BY ref_date;


##Domestic production value of Canada
SELECT unlicensed.ref_date, unlicensed.geo as country, unlicensed.indicator, unlicensed.industry, unlicensed.authority,
(unlicensed.value *1000000) as "unlicensed_domestic_prod_Value",licensed.authority, (licensed.value *1000000) as "licensed_domestic_prod_Value"
FROM cannabis_c_p.`industr_ prod` unlicensed
JOIN cannabis_c_p.`industr_ prod` licensed
ON unlicensed.ref_date = licensed.ref_date
AND unlicensed.dguid = licensed.dguid
AND unlicensed.industry = licensed.industry
WHERE 
unlicensed.indicator = "Domestic production"
AND unlicensed.authority = "Unlicensed source"
AND licensed.indicator = "Domestic production"
AND licensed.authority = "licensed source"
AND licensed.geo = "Canada"
AND unlicensed.geo = "Canada"
ORDER BY 3,4,2,1;

#CTE domestic_production
WITH domestic_production (ref_date, geo, dguid, indicator, industry, unlicensed_auth, unlicensed_domestic_prod_Value, licensed_auth, licensed_domestic_prod_Value) 
as
(SELECT unlicensed.ref_date, unlicensed.geo, unlicensed.dguid, unlicensed.indicator, unlicensed.industry, unlicensed.authority as "unlicensed_auth",
 (unlicensed.value *1000000) as "unlicensed_domestic_prod_Value",licensed.authority as "licensed_auth" , (licensed.value *1000000) as "licensed_domestic_prod_Value"
FROM cannabis_c_p.`industr_ prod` unlicensed
JOIN cannabis_c_p.`industr_ prod` licensed
ON unlicensed.ref_date = licensed.ref_date
AND unlicensed.dguid = licensed.dguid
AND unlicensed.industry = licensed.industry
WHERE unlicensed.indicator = "Domestic production" AND unlicensed.authority = "Unlicensed source"
AND licensed.indicator = "Domestic production" AND licensed.authority = "licensed source") 
SELECT *
FROM domestic_production
ORDER BY 5,2,1;


-- Canada 
##Domestice production for Canada 

DROP TABLE if exists cannabis_c_p.domestic_prod_country;
CREATE TABLE cannabis_c_p.domestic_prod_country 
( ref_date int, 
 dguid varchar (60),geo varchar (60) ,indicator varchar (60), industry varchar (255),unlicensed_domestic_prod_Value double ,licensed_domestic_prod_Value double);
INSERT INTO cannabis_c_p.domestic_prod_country
SELECT unlicensed.ref_date, unlicensed.dguid, unlicensed.geo, unlicensed.indicator, unlicensed.industry, 
(unlicensed.value *1000000) as "unlicensed_domestic_prod_Value", (licensed.value *1000000) as "licensed_domestic_prod_Value"
FROM cannabis_c_p.`industr_ prod` unlicensed
JOIN cannabis_c_p.`industr_ prod` licensed
ON unlicensed.ref_date = licensed.ref_date
AND unlicensed.dguid = licensed.dguid
AND unlicensed.industry = licensed.industry
WHERE 
unlicensed.indicator = "Domestic production"
AND unlicensed.authority = "Unlicensed source"
AND licensed.indicator = "Domestic production"
AND licensed.authority = "licensed source"
AND licensed.geo = "Canada"
AND unlicensed.geo = "Canada";

SELECT * From cannabis_c_p.domestic_prod_country cdp_1 JOIN cannabis_c_p.domestic_prod_country dpc2
ON cdp_2.ref_date = cdp_1.ref_date + 1 and cdp_1.industry = cdp_2.industry;

-- SELF JOIN cannabis_c_p.domestic_prod_country to calculate change in production value each year and then create temporary table for only yearly difference then join and create new temp table to have production value and production changes in one table. 

SELECT cdp_1.ref_date,cdp_1.dguid ,cdp_1.geo ,cdp_1.indicator , cdp_1.industry ,cdp_1.unlicensed_domestic_prod_Value,
(cdp_2.unlicensed_domestic_prod_Value - cdp_1.unlicensed_domestic_prod_Value) as unlicen_domestic_growth , cdp_1.licensed_domestic_prod_Value ,(cdp_2.licensed_domestic_prod_Value -cdp_1.licensed_domestic_prod_Value) as licensed_domestic_growth
From cannabis_c_p.domestic_prod_country cdp_1 JOIN cannabis_c_p.domestic_prod_country cdp_2
ON cdp_2.ref_date = cdp_1.ref_date + 1 and cdp_1.industry = cdp_2.industry;

SELECT cdp1.ref_date,cdp1.dguid,cdp1.geo,cdp1.indicator, cdp1.industry ,cdp1.unlicensed_domestic_prod_Value, cdvp.unlicen_domestic_growth, (cdvp.unlicen_domestic_growth/cdp1.unlicensed_domestic_prod_Value ) as Unlicenced_Percentage_growth,
 cdp1.licensed_domestic_prod_Value, cdvp.licensed_domestic_growth, (cdvp.licensed_domestic_growth/cdp1.licensed_domestic_prod_Value ) Licenced_Percentage_growth
From cannabis_c_p.domestic_prod_country cdp1 LEFT JOIN 
(SELECT cdp_1.ref_date,cdp_1.dguid ,cdp_1.geo ,cdp_1.indicator , cdp_1.industry ,cdp_1.unlicensed_domestic_prod_Value,
(cdp_2.unlicensed_domestic_prod_Value - cdp_1.unlicensed_domestic_prod_Value) as unlicen_domestic_growth , cdp_1.licensed_domestic_prod_Value ,(cdp_2.licensed_domestic_prod_Value -cdp_1.licensed_domestic_prod_Value) as licensed_domestic_growth
From cannabis_c_p.domestic_prod_country cdp_1 JOIN cannabis_c_p.domestic_prod_country cdp_2
ON cdp_2.ref_date = cdp_1.ref_date + 1 and cdp_1.industry = cdp_2.industry) cdvp
ON  cdp1.ref_date = cdvp.ref_date AND cdp1.industry = cdvp.industry AND cdp1.dguid = cdvp.dguid
ORDER BY 5,1; 

-- Self Join to seperate Cultivation industrie and Retail stores
SELECT cidp.ref_date,cidp.dguid,cidp.geo,cidp.indicator, 
cidp.unlicensed_domestic_prod_Value as Unlic_Cultivation_Industry_Dollar_Value, cidp.unlicen_domestic_growth as Unlic_Cultivation_Industry_Value_Growth, cidp.Unlicenced_Percentage_growth as Unlic_Cultivation_industry_Percent_Growth,
cidp.licensed_domestic_prod_Value as Lic_Cultivation_industry_Dollar_Value, cidp.licensed_domestic_growth as Lic_Cultivation_industry_Value_Growth, cidp.Licenced_Percentage_growth as Lic_Cultivation_Industry_Percent_Growth,
rsdp.unlicensed_domestic_prod_Value as Unlic_Retail_Store_Dollar_Value, rsdp.unlicen_domestic_growth as Unlic_Retail_Store_Value_Growth, rsdp.Unlicenced_Percentage_growth as Unlic_Retail_Store_Percent_Growth,
rsdp.licensed_domestic_prod_Value as Lic_Retail_Store_Dollar_Value, rsdp.licensed_domestic_growth as Lic_Retail_Store_Value_growth, rsdp.Licenced_Percentage_growth as Lic_Retail_Store_Percent_Growth,
(cidp.unlicensed_domestic_prod_Value+ cidp.licensed_domestic_prod_Value + rsdp.unlicensed_domestic_prod_Value + rsdp.licensed_domestic_prod_Value) as Total_Production_Value, 
( cidp.unlicensed_domestic_prod_Value + rsdp.unlicensed_domestic_prod_Value )/(cidp.unlicensed_domestic_prod_Value+ cidp.licensed_domestic_prod_Value + rsdp.unlicensed_domestic_prod_Value + rsdp.licensed_domestic_prod_Value) * 100 as Percent_From_Unlicensed_Industry,
( cidp.licensed_domestic_prod_Value + rsdp.licensed_domestic_prod_Value )/(cidp.unlicensed_domestic_prod_Value+ cidp.licensed_domestic_prod_Value + rsdp.unlicensed_domestic_prod_Value + rsdp.licensed_domestic_prod_Value) *100 as Percent_From_licensed_Industry
FROM
(SELECT cdp1.ref_date,cdp1.dguid,cdp1.geo,cdp1.indicator, cdp1.industry ,cdp1.unlicensed_domestic_prod_Value, cdvp.unlicen_domestic_growth, (cdvp.unlicen_domestic_growth/cdp1.unlicensed_domestic_prod_Value ) as Unlicenced_Percentage_growth,
 cdp1.licensed_domestic_prod_Value, cdvp.licensed_domestic_growth, (cdvp.licensed_domestic_growth/cdp1.licensed_domestic_prod_Value ) Licenced_Percentage_growth
From cannabis_c_p.domestic_prod_country cdp1 LEFT JOIN 
(SELECT cdp_1.ref_date,cdp_1.dguid ,cdp_1.geo ,cdp_1.indicator , cdp_1.industry ,cdp_1.unlicensed_domestic_prod_Value,
(cdp_2.unlicensed_domestic_prod_Value - cdp_1.unlicensed_domestic_prod_Value) as unlicen_domestic_growth , cdp_1.licensed_domestic_prod_Value ,(cdp_2.licensed_domestic_prod_Value -cdp_1.licensed_domestic_prod_Value) as licensed_domestic_growth
From cannabis_c_p.domestic_prod_country cdp_1 JOIN cannabis_c_p.domestic_prod_country cdp_2
ON cdp_2.ref_date = cdp_1.ref_date + 1 and cdp_1.industry = cdp_2.industry) cdvp
ON  cdp1.ref_date = cdvp.ref_date AND cdp1.industry = cdvp.industry AND cdp1.dguid = cdvp.dguid
WHERE cdp1.industry = 'Cannabis cultivation industry') cidp
JOIN
(SELECT cdp1.ref_date,cdp1.dguid,cdp1.geo,cdp1.indicator, cdp1.industry ,cdp1.unlicensed_domestic_prod_Value, cdvp.unlicen_domestic_growth, (cdvp.unlicen_domestic_growth/cdp1.unlicensed_domestic_prod_Value ) as Unlicenced_Percentage_growth,
 cdp1.licensed_domestic_prod_Value, cdvp.licensed_domestic_growth, (cdvp.licensed_domestic_growth/cdp1.licensed_domestic_prod_Value ) Licenced_Percentage_growth
From cannabis_c_p.domestic_prod_country cdp1 LEFT JOIN 
(SELECT cdp_1.ref_date,cdp_1.dguid ,cdp_1.geo ,cdp_1.indicator , cdp_1.industry ,cdp_1.unlicensed_domestic_prod_Value,
(cdp_2.unlicensed_domestic_prod_Value - cdp_1.unlicensed_domestic_prod_Value) as unlicen_domestic_growth , cdp_1.licensed_domestic_prod_Value ,(cdp_2.licensed_domestic_prod_Value -cdp_1.licensed_domestic_prod_Value) as licensed_domestic_growth
From cannabis_c_p.domestic_prod_country cdp_1 JOIN cannabis_c_p.domestic_prod_country cdp_2
ON cdp_2.ref_date = cdp_1.ref_date + 1 and cdp_1.industry = cdp_2.industry) cdvp
ON  cdp1.ref_date = cdvp.ref_date AND cdp1.industry = cdvp.industry AND cdp1.dguid = cdvp.dguid
WHERE cdp1.industry = 'Cannabis retail stores' )rsdp
ON cidp.ref_date = rsdp.ref_date 
Order BY 1;


-- CREAT VIEW FOR ABOVE QUERY
Drop View if exists cannabis_c_p.canada_domestic_prod;
CREATE VIEW cannabis_c_p.canada_domestic_prod as 
SELECT cidp.ref_date,cidp.dguid,cidp.geo,cidp.indicator, 
cidp.unlicensed_domestic_prod_Value as Unlic_Cultivation_Industry_Dollar_Value, cidp.unlicen_domestic_growth as Unlic_Cultivation_Industry_Value_Growth, cidp.Unlicenced_Percentage_growth as Unlic_Cultivation_industry_Percent_Growth,
cidp.licensed_domestic_prod_Value as Lic_Cultivation_industry_Dollar_Value, cidp.licensed_domestic_growth as Lic_Cultivation_industry_Value_Growth, cidp.Licenced_Percentage_growth as Lic_Cultivation_Industry_Percent_Growth,
rsdp.unlicensed_domestic_prod_Value as Unlic_Retail_Store_Dollar_Value, rsdp.unlicen_domestic_growth as Unlic_Retail_Store_Value_Growth, rsdp.Unlicenced_Percentage_growth as Unlic_Retail_Store_Percent_Growth,
rsdp.licensed_domestic_prod_Value as Lic_Retail_Store_Dollar_Value, rsdp.licensed_domestic_growth as Lic_Retail_Store_Value_growth, rsdp.Licenced_Percentage_growth as Lic_Retail_Store_Percent_Growth,
(cidp.unlicensed_domestic_prod_Value+ cidp.licensed_domestic_prod_Value + rsdp.unlicensed_domestic_prod_Value + rsdp.licensed_domestic_prod_Value) as Total_Production_Value, 
( cidp.unlicensed_domestic_prod_Value + rsdp.unlicensed_domestic_prod_Value )/(cidp.unlicensed_domestic_prod_Value+ cidp.licensed_domestic_prod_Value + rsdp.unlicensed_domestic_prod_Value + rsdp.licensed_domestic_prod_Value) * 100 as Percent_From_Unlicensed_Industry,
( cidp.licensed_domestic_prod_Value + rsdp.licensed_domestic_prod_Value )/(cidp.unlicensed_domestic_prod_Value+ cidp.licensed_domestic_prod_Value + rsdp.unlicensed_domestic_prod_Value + rsdp.licensed_domestic_prod_Value) *100 as Percent_From_licensed_Industry
FROM
(SELECT cdp1.ref_date,cdp1.dguid,cdp1.geo,cdp1.indicator, cdp1.industry ,cdp1.unlicensed_domestic_prod_Value, cdvp.unlicen_domestic_growth, (cdvp.unlicen_domestic_growth/cdp1.unlicensed_domestic_prod_Value ) as Unlicenced_Percentage_growth,
 cdp1.licensed_domestic_prod_Value, cdvp.licensed_domestic_growth, (cdvp.licensed_domestic_growth/cdp1.licensed_domestic_prod_Value ) Licenced_Percentage_growth
From cannabis_c_p.domestic_prod_country cdp1 LEFT JOIN 
(SELECT cdp_1.ref_date,cdp_1.dguid ,cdp_1.geo ,cdp_1.indicator , cdp_1.industry ,cdp_1.unlicensed_domestic_prod_Value,
(cdp_2.unlicensed_domestic_prod_Value - cdp_1.unlicensed_domestic_prod_Value) as unlicen_domestic_growth , cdp_1.licensed_domestic_prod_Value ,(cdp_2.licensed_domestic_prod_Value -cdp_1.licensed_domestic_prod_Value) as licensed_domestic_growth
From cannabis_c_p.domestic_prod_country cdp_1 JOIN cannabis_c_p.domestic_prod_country cdp_2
ON cdp_2.ref_date = cdp_1.ref_date + 1 and cdp_1.industry = cdp_2.industry) cdvp
ON  cdp1.ref_date = cdvp.ref_date AND cdp1.industry = cdvp.industry AND cdp1.dguid = cdvp.dguid
WHERE cdp1.industry = 'Cannabis cultivation industry') cidp
JOIN
(SELECT cdp1.ref_date,cdp1.dguid,cdp1.geo,cdp1.indicator, cdp1.industry ,cdp1.unlicensed_domestic_prod_Value, cdvp.unlicen_domestic_growth, (cdvp.unlicen_domestic_growth/cdp1.unlicensed_domestic_prod_Value ) as Unlicenced_Percentage_growth,
 cdp1.licensed_domestic_prod_Value, cdvp.licensed_domestic_growth, (cdvp.licensed_domestic_growth/cdp1.licensed_domestic_prod_Value ) Licenced_Percentage_growth
From cannabis_c_p.domestic_prod_country cdp1 LEFT JOIN 
(SELECT cdp_1.ref_date,cdp_1.dguid ,cdp_1.geo ,cdp_1.indicator , cdp_1.industry ,cdp_1.unlicensed_domestic_prod_Value,
(cdp_2.unlicensed_domestic_prod_Value - cdp_1.unlicensed_domestic_prod_Value) as unlicen_domestic_growth , cdp_1.licensed_domestic_prod_Value ,(cdp_2.licensed_domestic_prod_Value -cdp_1.licensed_domestic_prod_Value) as licensed_domestic_growth
From cannabis_c_p.domestic_prod_country cdp_1 JOIN cannabis_c_p.domestic_prod_country cdp_2
ON cdp_2.ref_date = cdp_1.ref_date + 1 and cdp_1.industry = cdp_2.industry) cdvp
ON  cdp1.ref_date = cdvp.ref_date AND cdp1.industry = cdvp.industry AND cdp1.dguid = cdvp.dguid
WHERE cdp1.industry = 'Cannabis retail stores' )rsdp
ON cidp.ref_date = rsdp.ref_date 
Order BY 1; 



##Total Domestic own-use production value for Canada##

SELECT unlicensed.ref_date, unlicensed.geo as country, unlicensed.indicator, unlicensed.industry, unlicensed.authority, (unlicensed.value *1000000) as "dom_use_unlic_value",
licensed.authority, (licensed.value *1000000) as "dom_use_lic_value"
FROM cannabis_c_p.`industr_ prod` unlicensed
JOIN cannabis_c_p.`industr_ prod` licensed
ON unlicensed.ref_date = licensed.ref_date
AND unlicensed.dguid = licensed.dguid
AND unlicensed.industry = licensed.industry
WHERE 
unlicensed.indicator = "Domestic own-use production"
AND unlicensed.authority = "Unlicensed source"
AND licensed.indicator = "Domestic own-use production"
AND licensed.authority = "licensed source"
AND licensed.geo = "Canada"
AND unlicensed.geo = "Canada"
ORDER BY  3,4,2,1;

##CTE dom_use_prod
-- WITH dom_use_prod (ref_date, dguid, geo, industry, indicator, unlicensed_auth, dom_use_unlic_value,
-- licensed_auth, dom_use_lic_value )
-- as
-- (SELECT unlicensed.ref_date, unlicensed.dguid, unlicensed.geo, unlicensed.industry, unlicensed.indicator, unlicensed.authority as "unlicensed_auth", (unlicensed.value *1000000) as "dom_use_unlic_value",
-- licensed.authority as "licensed_auth", (licensed.value *1000000) as "dom_use_lic_value"
-- FROM cannabis_c_p.`industr_ prod` unlicensed
-- JOIN cannabis_c_p.`industr_ prod` licensed
-- ON unlicensed.ref_date = licensed.ref_date
-- AND unlicensed.dguid = licensed.dguid
-- AND unlicensed.industry = licensed.industry
-- WHERE 
-- unlicensed.indicator = "Domestic own-use production"
-- AND unlicensed.authority = "Unlicensed source"
-- AND licensed.indicator = "Domestic own-use production"
-- AND licensed.authority = "licensed source"
-- AND licensed.geo = "Canada"
-- AND unlicensed.geo = "Canada"
-- ORDER BY ref_date))
-- (SELECT dupp.ref_date, dupp.dguid, dupp.geo, dupp.industry, dupp.indicator, dupp.dom_use_unlic_value,dupg.unlic_growth,
 -- dupp.dom_use_lic_value,dupg.lic_growth FROM dom_use_prod dupp LEFT JOIN (SELECT dup1.ref_date, dup1.dguid, dup1.geo, dup1.industry, dup1.indicator, dup1.unlicensed_auth, 
-- dup1.dom_use_unlic_value,(dup2.dom_use_unlic_value-dup1.dom_use_unlic_value) as unlic_growth , dup1.dom_use_lic_value, 
-- (dup2.dom_use_lic_value - dup1.dom_use_lic_value) as lic_growth
-- From dom_use_prod dup1 JOIN dom_use_prod dup2
-- ON dup2.ref_date = dup1.ref_date + 1 AND  dup1.industry = dup2.industry
-- ORDER BY 3,4,1
-- ) as dupg
-- ON dupp.ref_date=dupg.ref_date AND dupp.industry = dupg.industry
-- ORDER BY 4,1;

-- TAble
DROP TABLE IF EXISTS cannabis_c_p.country_dom_use_prod;
CREATE TABLE cannabis_c_p.country_dom_use_prod
(ref_date int, geo varchar (100), dguid varchar(100),indicator varchar (100), industry varchar (100), dom_use_unlic_value int,
dom_use_lic_value int);
INSERT INTO cannabis_c_p.country_dom_use_prod
SELECT unlicensed.ref_date, unlicensed.geo ,unlicensed.dguid, unlicensed.indicator, unlicensed.industry, (unlicensed.value *1000000) as "dom_use_unlic_value",
 (licensed.value *1000000) as "dom_use_lic_value"
FROM cannabis_c_p.`industr_ prod` unlicensed
JOIN cannabis_c_p.`industr_ prod` licensed
ON unlicensed.ref_date = licensed.ref_date
AND unlicensed.dguid = licensed.dguid
AND unlicensed.industry = licensed.industry
WHERE 
unlicensed.indicator = "Domestic own-use production"
AND unlicensed.authority = "Unlicensed source"
AND licensed.indicator = "Domestic own-use production"
AND licensed.authority = "licensed source"
AND licensed.geo = "Canada"
AND unlicensed.geo = "Canada"
ORDER BY  3,4,2,1;

SELECT dup1.ref_date, dup1.dguid, dup1.geo, dup1.industry, dup1.indicator, 
dup1.dom_use_unlic_value,(dup2.dom_use_unlic_value-dup1.dom_use_unlic_value) as unlic_growth ,
((dup2.dom_use_unlic_value-dup1.dom_use_unlic_value)/dup1.dom_use_unlic_value) as "percent_growth_unlic_dom_use" , dup1.dom_use_lic_value, 
(dup2.dom_use_lic_value - dup1.dom_use_lic_value) as lic_growth, ((dup2.dom_use_lic_value-dup1.dom_use_lic_value)/dup1.dom_use_lic_value) as "percent_growth_lic_dom_use"
From cannabis_c_p.country_dom_use_prod dup1 JOIN cannabis_c_p.country_dom_use_prod dup2
ON dup2.ref_date = dup1.ref_date + 1 AND  dup1.industry = dup2.industry
ORDER BY 3,4,1 ;

SELECT cdup.ref_date , cdup.geo, cdup.dguid,cdup.indicator,cdup.industry, cdup.dom_use_unlic_value, cdupg.unlic_growth, cdupg.percent_growth_unlic_dom_use , cdup.dom_use_lic_value,cdupg.lic_growth, cdupg.percent_growth_lic_dom_use
From cannabis_c_p.country_dom_use_prod cdup LEFT JOIN 
(SELECT dup1.ref_date, dup1.dguid, dup1.geo, dup1.industry, dup1.indicator, 
dup1.dom_use_unlic_value,(dup2.dom_use_unlic_value-dup1.dom_use_unlic_value) as unlic_growth ,
((dup2.dom_use_unlic_value-dup1.dom_use_unlic_value)/dup1.dom_use_unlic_value) as "percent_growth_unlic_dom_use" , dup1.dom_use_lic_value, 
(dup2.dom_use_lic_value - dup1.dom_use_lic_value) as lic_growth, ((dup2.dom_use_lic_value-dup1.dom_use_lic_value)/dup1.dom_use_lic_value) as "percent_growth_lic_dom_use"
From cannabis_c_p.country_dom_use_prod dup1 JOIN cannabis_c_p.country_dom_use_prod dup2
ON dup2.ref_date = dup1.ref_date + 1 AND  dup1.industry = dup2.industry) cdupg
ON cdup.ref_date = cdupg.ref_date AND cdup.industry = cdupg.industry
ORDER BY 5,1;

-- Self JOin to compare value gained from Cannabis Cultivation Vs retail stores
SELECT ciou.ref_date, ciou.geo, ciou.dguid,ciou.indicator,
ciou.dom_use_unlic_value as Unlic_Cultivation_Industry_Dollar_Value, ciou.unlic_growth as Unlic_Cultivation_Industry_Value_Growth, 
ciou.percent_growth_unlic_dom_use as Unlic_Cultivation_Industry_Percent_Growth , 
ciou.dom_use_lic_value as Lic_Cultivation_industry_Dollar_Value, ciou.lic_growth as Lic_Cultivation_industry_Value_Growth, 
ciou.percent_growth_lic_dom_use as Lic_Cultivation_Industry_Percent_Growth,
rsou.dom_use_unlic_value as Unlic_Retail_Store_Dollar_Value, rsou.unlic_growth as Unlic_Retail_Store_Value_Growth,
rsou.percent_growth_unlic_dom_use as Unlic_Retail_Store_Percent_Growth, 
rsou.dom_use_lic_value as Lic_Retail_Store_Dollar_Value,rsou.lic_growth as Lic_Retail_Store_Value_Growth, 
rsou.percent_growth_lic_dom_use as Lic_Retail_Store_Percent_Growth,
(ciou.dom_use_unlic_value+ ciou.dom_use_lic_value+ rsou.dom_use_unlic_value+rsou.dom_use_lic_value ) as Total_Production_Value,
(ciou.dom_use_unlic_value+rsou.dom_use_unlic_value)/(ciou.dom_use_unlic_value+ ciou.dom_use_lic_value+ rsou.dom_use_unlic_value+rsou.dom_use_lic_value ) *100 as Percent_From_Unlicensed_Industry,
( ciou.dom_use_lic_value+rsou.dom_use_lic_value )/(ciou.dom_use_unlic_value+ ciou.dom_use_lic_value+ rsou.dom_use_unlic_value+rsou.dom_use_lic_value ) *100 as Percent_From_licensed_Industry
FROM
(SELECT cdup.ref_date , cdup.geo, cdup.dguid,cdup.indicator,cdup.industry, cdup.dom_use_unlic_value, cdupg.unlic_growth, cdupg.percent_growth_unlic_dom_use , cdup.dom_use_lic_value,cdupg.lic_growth, cdupg.percent_growth_lic_dom_use
From cannabis_c_p.country_dom_use_prod cdup LEFT JOIN 
(SELECT dup1.ref_date, dup1.dguid, dup1.geo, dup1.industry, dup1.indicator, 
dup1.dom_use_unlic_value,(dup2.dom_use_unlic_value-dup1.dom_use_unlic_value) as unlic_growth ,
((dup2.dom_use_unlic_value-dup1.dom_use_unlic_value)/dup1.dom_use_unlic_value) as "percent_growth_unlic_dom_use" , dup1.dom_use_lic_value, 
(dup2.dom_use_lic_value - dup1.dom_use_lic_value) as lic_growth, ((dup2.dom_use_lic_value-dup1.dom_use_lic_value)/dup1.dom_use_lic_value) as "percent_growth_lic_dom_use"
From cannabis_c_p.country_dom_use_prod dup1 JOIN cannabis_c_p.country_dom_use_prod dup2
ON dup2.ref_date = dup1.ref_date + 1 AND  dup1.industry = dup2.industry) cdupg
ON cdup.ref_date = cdupg.ref_date AND cdup.industry = cdupg.industry
WHERE cdup.industry = 'Cannabis cultivation industry' )ciou 
JOIN
(SELECT cdup.ref_date , cdup.geo, cdup.dguid,cdup.indicator,cdup.industry, cdup.dom_use_unlic_value, cdupg.unlic_growth, cdupg.percent_growth_unlic_dom_use , cdup.dom_use_lic_value,cdupg.lic_growth, cdupg.percent_growth_lic_dom_use
From cannabis_c_p.country_dom_use_prod cdup LEFT JOIN 
(SELECT dup1.ref_date, dup1.dguid, dup1.geo, dup1.industry, dup1.indicator, 
dup1.dom_use_unlic_value,(dup2.dom_use_unlic_value-dup1.dom_use_unlic_value) as unlic_growth ,
((dup2.dom_use_unlic_value-dup1.dom_use_unlic_value)/dup1.dom_use_unlic_value) as "percent_growth_unlic_dom_use" , dup1.dom_use_lic_value, 
(dup2.dom_use_lic_value - dup1.dom_use_lic_value) as lic_growth, ((dup2.dom_use_lic_value-dup1.dom_use_lic_value)/dup1.dom_use_lic_value) as "percent_growth_lic_dom_use"
From cannabis_c_p.country_dom_use_prod dup1 JOIN cannabis_c_p.country_dom_use_prod dup2
ON dup2.ref_date = dup1.ref_date + 1 AND  dup1.industry = dup2.industry) cdupg
ON cdup.ref_date = cdupg.ref_date AND cdup.industry = cdupg.industry
WHERE cdup.industry = 'Cannabis retail stores') rsou
ON rsou.ref_date = ciou.ref_date
ORDER BY 1;

-- CREATE VIEWS WITH ABOVE QUERY
DROP VIEW IF EXISTS cannabis_c_p.canada_own_use ;
CREATE VIEW  cannabis_c_p.canada_own_use AS
SELECT ciou.ref_date, ciou.geo, ciou.dguid,ciou.indicator,
ciou.dom_use_unlic_value as Unlic_Cultivation_Industry_Dollar_Value, ciou.unlic_growth as Unlic_Cultivation_Industry_Value_Growth, 
ciou.percent_growth_unlic_dom_use as Unlic_Cultivation_Industry_Percent_Growth , 
ciou.dom_use_lic_value as Lic_Cultivation_industry_Dollar_Value, ciou.lic_growth as Lic_Cultivation_industry_Value_Growth, 
ciou.percent_growth_lic_dom_use as Lic_Cultivation_Industry_Percent_Growth,
rsou.dom_use_unlic_value as Unlic_Retail_Store_Dollar_Value, rsou.unlic_growth as Unlic_Retail_Store_Value_Growth,
rsou.percent_growth_unlic_dom_use as Unlic_Retail_Store_Percent_Growth, 
rsou.dom_use_lic_value as Lic_Retail_Store_Dollar_Value,rsou.lic_growth as Lic_Retail_Store_Value_Growth, 
rsou.percent_growth_lic_dom_use as Lic_Retail_Store_Percent_Growth,
(ciou.dom_use_unlic_value+ ciou.dom_use_lic_value+ rsou.dom_use_unlic_value+rsou.dom_use_lic_value ) as Total_Production_Value,
(ciou.dom_use_unlic_value+rsou.dom_use_unlic_value)/(ciou.dom_use_unlic_value+ ciou.dom_use_lic_value+ rsou.dom_use_unlic_value+rsou.dom_use_lic_value ) *100 as Percent_From_Unlicensed_Industry,
( ciou.dom_use_lic_value+rsou.dom_use_lic_value )/(ciou.dom_use_unlic_value+ ciou.dom_use_lic_value+ rsou.dom_use_unlic_value+rsou.dom_use_lic_value ) *100 as Percent_From_licensed_Industry
FROM
(SELECT cdup.ref_date , cdup.geo, cdup.dguid,cdup.indicator,cdup.industry, cdup.dom_use_unlic_value, cdupg.unlic_growth, cdupg.percent_growth_unlic_dom_use , cdup.dom_use_lic_value,cdupg.lic_growth, cdupg.percent_growth_lic_dom_use
From cannabis_c_p.country_dom_use_prod cdup LEFT JOIN 
(SELECT dup1.ref_date, dup1.dguid, dup1.geo, dup1.industry, dup1.indicator, 
dup1.dom_use_unlic_value,(dup2.dom_use_unlic_value-dup1.dom_use_unlic_value) as unlic_growth ,
((dup2.dom_use_unlic_value-dup1.dom_use_unlic_value)/dup1.dom_use_unlic_value) as "percent_growth_unlic_dom_use" , dup1.dom_use_lic_value, 
(dup2.dom_use_lic_value - dup1.dom_use_lic_value) as lic_growth, ((dup2.dom_use_lic_value-dup1.dom_use_lic_value)/dup1.dom_use_lic_value) as "percent_growth_lic_dom_use"
From cannabis_c_p.country_dom_use_prod dup1 JOIN cannabis_c_p.country_dom_use_prod dup2
ON dup2.ref_date = dup1.ref_date + 1 AND  dup1.industry = dup2.industry) cdupg
ON cdup.ref_date = cdupg.ref_date AND cdup.industry = cdupg.industry
WHERE cdup.industry = 'Cannabis cultivation industry' )ciou 
JOIN
(SELECT cdup.ref_date , cdup.geo, cdup.dguid,cdup.indicator,cdup.industry, cdup.dom_use_unlic_value, cdupg.unlic_growth, cdupg.percent_growth_unlic_dom_use , cdup.dom_use_lic_value,cdupg.lic_growth, cdupg.percent_growth_lic_dom_use
From cannabis_c_p.country_dom_use_prod cdup LEFT JOIN 
(SELECT dup1.ref_date, dup1.dguid, dup1.geo, dup1.industry, dup1.indicator, 
dup1.dom_use_unlic_value,(dup2.dom_use_unlic_value-dup1.dom_use_unlic_value) as unlic_growth ,
((dup2.dom_use_unlic_value-dup1.dom_use_unlic_value)/dup1.dom_use_unlic_value) as "percent_growth_unlic_dom_use" , dup1.dom_use_lic_value, 
(dup2.dom_use_lic_value - dup1.dom_use_lic_value) as lic_growth, ((dup2.dom_use_lic_value-dup1.dom_use_lic_value)/dup1.dom_use_lic_value) as "percent_growth_lic_dom_use"
From cannabis_c_p.country_dom_use_prod dup1 JOIN cannabis_c_p.country_dom_use_prod dup2
ON dup2.ref_date = dup1.ref_date + 1 AND  dup1.industry = dup2.industry) cdupg
ON cdup.ref_date = cdupg.ref_date AND cdup.industry = cdupg.industry
WHERE cdup.industry = 'Cannabis retail stores') rsou
ON rsou.ref_date = ciou.ref_date
ORDER BY 1;

##Intermediate consumption Value  in Canada Yearly##
SELECT unlicensed.ref_date, unlicensed.geo as country, unlicensed.indicator, unlicensed.industry, unlicensed.authority as "unlicensed_auth", (unlicensed.value *1000000) as "Unlic Dollar_Value",
licensed.authority as "licensed_auth", (licensed.value *1000000) as "int_lic Dollar_Value"
FROM cannabis_c_p.`industr_ prod` unlicensed
JOIN cannabis_c_p.`industr_ prod` licensed
ON unlicensed.ref_date = licensed.ref_date
AND unlicensed.dguid = licensed.dguid
AND unlicensed.industry = licensed.industry
WHERE 
licensed.indicator = "Intermediate consumption"
AND licensed.authority = "licensed source"
AND  unlicensed.authority = "Unlicensed source"
AND unlicensed.indicator = "Intermediate consumption"
AND licensed.geo = "Canada"
AND unlicensed.geo = "Canada"
ORDER BY  3,4,2,1;

##CTE interm_use
WITH interm_use (ref_date, geo, industry, indicator, unlicensed_auth, Unlic_Dollar_Value,
licensed_auth, int_lic_Dollar_Value)
as (
SELECT unlicensed.ref_date, unlicensed.geo, unlicensed.industry, unlicensed.indicator, unlicensed.authority as "unlicensed_auth", (unlicensed.value *1000000) as "Unlic_Dollar_Value",
licensed.authority as "licensed_auth", (licensed.value *1000000) as "int_lic_Dollar_Value"
FROM cannabis_c_p.`industr_ prod` unlicensed
JOIN cannabis_c_p.`industr_ prod` licensed
ON unlicensed.ref_date = licensed.ref_date
AND unlicensed.dguid = licensed.dguid
AND unlicensed.industry = licensed.industry
WHERE 
licensed.indicator = "Intermediate consumption"
AND licensed.authority = "licensed source"
AND  unlicensed.authority = "Unlicensed source"
AND unlicensed.indicator = "Intermediate consumption"
AND licensed.geo = "Canada"
AND unlicensed.geo = "Canada"
ORDER BY ref_date)
SELECT *
FROM interm_use;

-- TEMP TABLE
DROP TABLE if exists cannabis_c_p.country_interm_consump;
CREATE TABLE cannabis_c_p.country_interm_consump
(ref_date int, geo varchar(100), dguid varchar(100), industry varchar(100), indicator varchar(100), unlic_Dollar_Value int, 
 int_lic_Dollar_Value int);
INSERT INTO cannabis_c_p.country_interm_consump
SELECT unlicensed.ref_date, unlicensed.geo, unlicensed.dguid, unlicensed.industry, unlicensed.indicator, (unlicensed.value *1000000) as "unlic_Dollar_Value",
 (licensed.value *1000000) as "int_lic_Dollar_Value"
FROM cannabis_c_p.`industr_ prod` unlicensed
JOIN cannabis_c_p.`industr_ prod` licensed
ON unlicensed.ref_date = licensed.ref_date
AND unlicensed.dguid = licensed.dguid
AND unlicensed.industry = licensed.industry
WHERE 
licensed.indicator = "Intermediate consumption"
AND licensed.authority = "licensed source"
AND  unlicensed.authority = "Unlicensed source"
AND unlicensed.indicator = "Intermediate consumption"
AND licensed.geo = "Canada"
AND unlicensed.geo = "Canada";


SELECT cic_1.ref_date, cic_1.geo, cic_1.dguid, cic_1.industry,cic_1.indicator, cic_1.unlic_Dollar_value, cicg.unlic_value_growth_in_year, cicg.percent_unlic_value_growth, cic_1.int_lic_Dollar_Value, cicg.lic_value_growth_in_year, cicg.percent_lic_value_growth
FROM cannabis_c_p.country_interm_consump cic_1 LEFT JOIN (SELECT cic1.ref_date, cic1.geo, cic1.dguid, cic1.indicator, cic1.industry, cic2.Unlic_Dollar_Value - cic1.Unlic_Dollar_Value as unlic_value_growth_in_year, (cic2.Unlic_Dollar_Value - cic1.Unlic_Dollar_Value)/cic1.Unlic_Dollar_Value as percent_unlic_value_growth,
cic2.int_lic_Dollar_Value - cic1.int_lic_Dollar_Value as lic_value_growth_in_year, (cic2.int_lic_Dollar_Value - cic1.int_lic_Dollar_Value)/cic1.int_lic_Dollar_Value as percent_lic_value_growth
FROM cannabis_c_p.country_interm_consump cic1 join cannabis_c_p.country_interm_consump cic2
ON cic2.ref_date = cic1.ref_date +1 AND cic1.industry = cic2.industry) cicg
ON cic_1.ref_date = cicg.ref_date AND cic_1.industry = cicg.industry
ORDER BY 4,1 ;

SELECT ciic.ref_date, ciic.geo, ciic.dguid,ciic.indicator, 
ciic.unlic_Dollar_value as Unlic_Cultivation_Industry_Dollar_Value , ciic.unlic_value_growth_in_year as Unlic_Cultivation_Industry_Value_Growth, ciic.percent_unlic_value_growth as Unlic_Cultivation_Industry_Percent_Growth, 
ciic.int_lic_Dollar_Value as Lic_Cultivation_industry_Dollar_Value, ciic.lic_value_growth_in_year as Lic_Cultivation_industry_Value_Growth , ciic.percent_lic_value_growth as Lic_Cultivation_Industry_Percent_Growth,
cric.unlic_Dollar_value as Unlic_Retail_Store_Dollar_Value, cric.unlic_value_growth_in_year as Unlic_Retail_Store_Value_Growth, cric.percent_unlic_value_growth as Unlic_Retail_Store_Percent_Growth, 
cric.int_lic_Dollar_Value as Lic_Retail_Store_Dollar_Value, cric.lic_value_growth_in_year as Lic_Retail_Store_Value_Growth, cric.percent_lic_value_growth as Lic_Retail_Store_Percent_Growth,
(ciic.unlic_Dollar_value + ciic.int_lic_Dollar_Value+ cric.unlic_Dollar_value+cric.int_lic_Dollar_Value ) as Total_Interm_consumption_Value , 
(ciic.unlic_Dollar_value + cric.unlic_Dollar_value )/(ciic.unlic_Dollar_value + ciic.int_lic_Dollar_Value+ cric.unlic_Dollar_value+cric.int_lic_Dollar_Value ) * 100 as Percent_From_Unlicensed_Industry, 
(ciic.int_lic_Dollar_Value+ + cric.int_lic_Dollar_Value )/(ciic.unlic_Dollar_value + ciic.int_lic_Dollar_Value+ cric.unlic_Dollar_value+cric.int_lic_Dollar_Value ) *100 as Percent_From_licensed_Industry
FROM
(SELECT cic_1.ref_date, cic_1.geo, cic_1.dguid, cic_1.industry,cic_1.indicator, cic_1.unlic_Dollar_value, cicg.unlic_value_growth_in_year, cicg.percent_unlic_value_growth, cic_1.int_lic_Dollar_Value, cicg.lic_value_growth_in_year, cicg.percent_lic_value_growth
FROM cannabis_c_p.country_interm_consump cic_1 LEFT JOIN (SELECT cic1.ref_date, cic1.geo, cic1.dguid, cic1.indicator, cic1.industry, cic2.Unlic_Dollar_Value - cic1.Unlic_Dollar_Value as unlic_value_growth_in_year, (cic2.Unlic_Dollar_Value - cic1.Unlic_Dollar_Value)/cic1.Unlic_Dollar_Value as percent_unlic_value_growth,
cic2.int_lic_Dollar_Value - cic1.int_lic_Dollar_Value as lic_value_growth_in_year, (cic2.int_lic_Dollar_Value - cic1.int_lic_Dollar_Value)/cic1.int_lic_Dollar_Value as percent_lic_value_growth
FROM cannabis_c_p.country_interm_consump cic1 join cannabis_c_p.country_interm_consump cic2
ON cic2.ref_date = cic1.ref_date +1 AND cic1.industry = cic2.industry) cicg
ON cic_1.ref_date = cicg.ref_date AND cic_1.industry = cicg.industry
WHERE cic_1.industry = 'Cannabis cultivation industry')ciic
JOIN
(SELECT cic_1.ref_date, cic_1.geo, cic_1.dguid, cic_1.industry,cic_1.indicator, cic_1.unlic_Dollar_value, cicg.unlic_value_growth_in_year, cicg.percent_unlic_value_growth, cic_1.int_lic_Dollar_Value, cicg.lic_value_growth_in_year, cicg.percent_lic_value_growth
FROM cannabis_c_p.country_interm_consump cic_1 LEFT JOIN (SELECT cic1.ref_date, cic1.geo, cic1.dguid, cic1.indicator, cic1.industry, cic2.Unlic_Dollar_Value - cic1.Unlic_Dollar_Value as unlic_value_growth_in_year, (cic2.Unlic_Dollar_Value - cic1.Unlic_Dollar_Value)/cic1.Unlic_Dollar_Value as percent_unlic_value_growth,
cic2.int_lic_Dollar_Value - cic1.int_lic_Dollar_Value as lic_value_growth_in_year, (cic2.int_lic_Dollar_Value - cic1.int_lic_Dollar_Value)/cic1.int_lic_Dollar_Value as percent_lic_value_growth
FROM cannabis_c_p.country_interm_consump cic1 join cannabis_c_p.country_interm_consump cic2
ON cic2.ref_date = cic1.ref_date +1 AND cic1.industry = cic2.industry) cicg
ON cic_1.ref_date = cicg.ref_date AND cic_1.industry = cicg.industry
WHERE cic_1.industry = 'Cannabis retail stores') cric
ON ciic.ref_date = cric.ref_date AND ciic.geo = cric.geo AND ciic.indicator = cric.indicator
ORDER BY 2,1 ;

-- CREAT VIEW OF ABOVE query
DROP VIEW IF EXISTS cannabis_c_p.canada_interm_consump ;
CREATE VIEW cannabis_c_p.canada_interm_consump  AS
SELECT ciic.ref_date, ciic.geo, ciic.dguid,ciic.indicator, 
ciic.unlic_Dollar_value as Unlic_Cultivation_Industry_Dollar_Value , ciic.unlic_value_growth_in_year as Unlic_Cultivation_Industry_Value_Growth, ciic.percent_unlic_value_growth as Unlic_Cultivation_Industry_Percent_Growth, 
ciic.int_lic_Dollar_Value as Lic_Cultivation_industry_Dollar_Value, ciic.lic_value_growth_in_year as Lic_Cultivation_industry_Value_Growth , ciic.percent_lic_value_growth as Lic_Cultivation_Industry_Percent_Growth,
cric.unlic_Dollar_value as Unlic_Retail_Store_Dollar_Value, cric.unlic_value_growth_in_year as Unlic_Retail_Store_Value_Growth, cric.percent_unlic_value_growth as Unlic_Retail_Store_Percent_Growth, 
cric.int_lic_Dollar_Value as Lic_Retail_Store_Dollar_Value, cric.lic_value_growth_in_year as Lic_Retail_Store_Value_Growth, cric.percent_lic_value_growth as Lic_Retail_Store_Percent_Growth,
(ciic.unlic_Dollar_value + ciic.int_lic_Dollar_Value+ cric.unlic_Dollar_value+cric.int_lic_Dollar_Value ) as Total_Interm_consumption_Value , 
(ciic.unlic_Dollar_value + cric.unlic_Dollar_value )/(ciic.unlic_Dollar_value + ciic.int_lic_Dollar_Value+ cric.unlic_Dollar_value+cric.int_lic_Dollar_Value ) * 100 as Percent_From_Unlicensed_Industry, 
(ciic.int_lic_Dollar_Value+ + cric.int_lic_Dollar_Value )/(ciic.unlic_Dollar_value + ciic.int_lic_Dollar_Value+ cric.unlic_Dollar_value+cric.int_lic_Dollar_Value ) *100 as Percent_From_licensed_Industry
FROM
(SELECT cic_1.ref_date, cic_1.geo, cic_1.dguid, cic_1.industry,cic_1.indicator, cic_1.unlic_Dollar_value, cicg.unlic_value_growth_in_year, cicg.percent_unlic_value_growth, cic_1.int_lic_Dollar_Value, cicg.lic_value_growth_in_year, cicg.percent_lic_value_growth
FROM cannabis_c_p.country_interm_consump cic_1 LEFT JOIN (SELECT cic1.ref_date, cic1.geo, cic1.dguid, cic1.indicator, cic1.industry, cic2.Unlic_Dollar_Value - cic1.Unlic_Dollar_Value as unlic_value_growth_in_year, (cic2.Unlic_Dollar_Value - cic1.Unlic_Dollar_Value)/cic1.Unlic_Dollar_Value as percent_unlic_value_growth,
cic2.int_lic_Dollar_Value - cic1.int_lic_Dollar_Value as lic_value_growth_in_year, (cic2.int_lic_Dollar_Value - cic1.int_lic_Dollar_Value)/cic1.int_lic_Dollar_Value as percent_lic_value_growth
FROM cannabis_c_p.country_interm_consump cic1 join cannabis_c_p.country_interm_consump cic2
ON cic2.ref_date = cic1.ref_date +1 AND cic1.industry = cic2.industry) cicg
ON cic_1.ref_date = cicg.ref_date AND cic_1.industry = cicg.industry
WHERE cic_1.industry = 'Cannabis cultivation industry')ciic
JOIN
(SELECT cic_1.ref_date, cic_1.geo, cic_1.dguid, cic_1.industry,cic_1.indicator, cic_1.unlic_Dollar_value, cicg.unlic_value_growth_in_year, cicg.percent_unlic_value_growth, cic_1.int_lic_Dollar_Value, cicg.lic_value_growth_in_year, cicg.percent_lic_value_growth
FROM cannabis_c_p.country_interm_consump cic_1 LEFT JOIN (SELECT cic1.ref_date, cic1.geo, cic1.dguid, cic1.indicator, cic1.industry, cic2.Unlic_Dollar_Value - cic1.Unlic_Dollar_Value as unlic_value_growth_in_year, (cic2.Unlic_Dollar_Value - cic1.Unlic_Dollar_Value)/cic1.Unlic_Dollar_Value as percent_unlic_value_growth,
cic2.int_lic_Dollar_Value - cic1.int_lic_Dollar_Value as lic_value_growth_in_year, (cic2.int_lic_Dollar_Value - cic1.int_lic_Dollar_Value)/cic1.int_lic_Dollar_Value as percent_lic_value_growth
FROM cannabis_c_p.country_interm_consump cic1 join cannabis_c_p.country_interm_consump cic2
ON cic2.ref_date = cic1.ref_date +1 AND cic1.industry = cic2.industry) cicg
ON cic_1.ref_date = cicg.ref_date AND cic_1.industry = cicg.industry
WHERE cic_1.industry = 'Cannabis retail stores') cric
ON ciic.ref_date = cric.ref_date AND ciic.geo = cric.geo AND ciic.indicator = cric.indicator
ORDER BY 2,1 ;


##Gross value gained in Canada yearly## 

SELECT unlicensed.ref_date, unlicensed.geo as country, unlicensed.industry, unlicensed.indicator, unlicensed.authority as "unlicensed_auth", (unlicensed.value *1000000) as "gross_unlic_Dollar_Value",
licensed.authority as "licensed_auth", (licensed.value *1000000) as "gross_lic_Dollar_Value"
FROM cannabis_c_p.`industr_ prod` unlicensed
JOIN cannabis_c_p.`industr_ prod` licensed
ON unlicensed.ref_date = licensed.ref_date
AND unlicensed.dguid = licensed.dguid
AND unlicensed.industry = licensed.industry
WHERE 
licensed.indicator = "Gross value added"
AND licensed.authority = "licensed source"
AND  unlicensed.authority = "Unlicensed source"
AND unlicensed.indicator = "Gross value added"
AND licensed.geo = "Canada"
AND unlicensed.geo = "Canada"
ORDER BY  3,4,2,1;

DROP TABLE if exists cannabis_c_p.country_canna_gross_value;
CREATE TABLE cannabis_c_p.country_canna_gross_value
( ref_date int, geo varchar(100), dguid varchar(100),industry varchar(100), indicator varchar(100), gross_unlic_Dollar_Value double,
gross_lic_Dollar_Value double );
INSERT INTO cannabis_c_p.country_canna_gross_value
SELECT unlicensed.ref_date, unlicensed.geo, unlicensed.dguid ,unlicensed.industry, unlicensed.indicator,  (unlicensed.value *1000000) as "gross_unlic_Dollar_Value",
 (licensed.value *1000000) as "gross_lic_Dollar_Value"
FROM cannabis_c_p.`industr_ prod` unlicensed
JOIN cannabis_c_p.`industr_ prod` licensed
ON unlicensed.ref_date = licensed.ref_date
AND unlicensed.dguid = licensed.dguid
AND unlicensed.industry = licensed.industry
WHERE 
licensed.indicator = "Gross value added"
AND licensed.authority = "licensed source"
AND  unlicensed.authority = "Unlicensed source"
AND unlicensed.indicator = "Gross value added"
AND licensed.geo = "Canada"
AND unlicensed.geo = "Canada"
ORDER BY  3,4,2,1;

SELECT ccgv1.ref_date, ccgv1.geo, ccgv1.dguid, ccgv1.industry, ccgv1.indicator, 
ccgv1.gross_unlic_Dollar_Value,  ccgv2.gross_unlic_Dollar_Value - ccgv1.gross_unlic_Dollar_Value as unlic_gross_value_increase, 
(ccgv2.gross_unlic_Dollar_Value - ccgv1.gross_unlic_Dollar_Value)/ccgv1.gross_unlic_Dollar_Value as percentage_unlic_gross_value_increase,
ccgv1.gross_lic_Dollar_Value, ccgv2.gross_lic_Dollar_Value - ccgv1.gross_lic_Dollar_Value as lic_gross_value_increase,
(ccgv2.gross_lic_Dollar_Value - ccgv1.gross_lic_Dollar_Value)/ccgv1.gross_lic_Dollar_Value as percentage_lic_gross_value_increase
FROM cannabis_c_p.country_canna_gross_value ccgv1 JOIN cannabis_c_p.country_canna_gross_value ccgv2
ON ccgv2.ref_date = ccgv1.ref_date +1 AND ccgv1.industry = ccgv2.industry
ORDER BY 4,1;

SELECT ccvg_1.ref_date, ccvg_1.geo,ccvg_1.dguid,ccvg_1.industry,ccvg_1.indicator,
ccvg_1.gross_unlic_Dollar_Value, ccgcc.unlic_gross_value_increase, ccgcc.percentage_unlic_gross_value_increase , 
ccvg_1.gross_lic_Dollar_Value, ccgcc.lic_gross_value_increase, ccgcc.percentage_lic_gross_value_increase
FROM cannabis_c_p.country_canna_gross_value ccvg_1 LEFT JOIN 
(SELECT ccgv1.ref_date, ccgv1.geo, ccgv1.dguid, ccgv1.industry, ccgv1.indicator, 
ccgv1.gross_unlic_Dollar_Value,  ccgv2.gross_unlic_Dollar_Value - ccgv1.gross_unlic_Dollar_Value as unlic_gross_value_increase, 
(ccgv2.gross_unlic_Dollar_Value - ccgv1.gross_unlic_Dollar_Value)/ccgv1.gross_unlic_Dollar_Value as percentage_unlic_gross_value_increase,
ccgv1.gross_lic_Dollar_Value, ccgv2.gross_lic_Dollar_Value - ccgv1.gross_lic_Dollar_Value as lic_gross_value_increase,
(ccgv2.gross_lic_Dollar_Value - ccgv1.gross_lic_Dollar_Value)/ccgv1.gross_lic_Dollar_Value as percentage_lic_gross_value_increase
FROM cannabis_c_p.country_canna_gross_value ccgv1 JOIN cannabis_c_p.country_canna_gross_value ccgv2
ON ccgv2.ref_date = ccgv1.ref_date +1 AND ccgv1.industry = ccgv2.industry
) ccgcc
ON ccvg_1.ref_date = ccgcc.ref_date AND ccvg_1.industry = ccgcc.industry
ORDer BY 4,1;

-- SELF JOIN ABOVE QUERY to gather  total yearly gross value 
SELECT cigv.ref_date, cigv.geo,cigv.dguid,cigv.indicator,
cigv.gross_unlic_Dollar_Value as Unlic_Cultivation_Industry_Dollar_Value, cigv.unlic_gross_value_increase as Unlic_Cultivation_Industry_Value_Growth, 
cigv.percentage_unlic_gross_value_increase as Unlic_Cultivation_Industry_Percent_Growth , 
cigv.gross_lic_Dollar_Value as Lic_Cultivation_industry_Dollar_Value, cigv.lic_gross_value_increase as Lic_Cultivation_industry_Value_Growth, 
cigv.percentage_lic_gross_value_increase as Lic_Cultivation_Industry_Percent_Growth,
rsgv.gross_unlic_Dollar_Value as Unlic_Retail_Store_Dollar_Value, rsgv.unlic_gross_value_increase as Unlic_Retail_Store_Value_Growth, 
rsgv.percentage_unlic_gross_value_increase as Unlic_Retail_Store_Percent_Growth , 
rsgv.gross_lic_Dollar_Value as Lic_Retail_Store_Dollar_Value, rsgv.lic_gross_value_increase as Lic_Retail_Store_Value_Growth, 
rsgv.percentage_lic_gross_value_increase as Lic_Retail_Store_Percent_Growth,
(cigv.gross_unlic_Dollar_Value+cigv.gross_lic_Dollar_Value+rsgv.gross_unlic_Dollar_Value+rsgv.gross_lic_Dollar_Value) as Total_Production_Value,
(cigv.gross_unlic_Dollar_Value+rsgv.gross_unlic_Dollar_Value)/ (cigv.gross_unlic_Dollar_Value+cigv.gross_lic_Dollar_Value+rsgv.gross_unlic_Dollar_Value+rsgv.gross_lic_Dollar_Value) * 100 as Percent_From_Unlicensed_Industry,
(cigv.gross_lic_Dollar_Value+rsgv.gross_lic_Dollar_Value)/(cigv.gross_unlic_Dollar_Value+cigv.gross_lic_Dollar_Value+rsgv.gross_unlic_Dollar_Value+rsgv.gross_lic_Dollar_Value) *100 as Percent_From_licensed_Industry
 FROM
(SELECT ccvg_1.ref_date, ccvg_1.geo,ccvg_1.dguid,ccvg_1.industry,ccvg_1.indicator,
ccvg_1.gross_unlic_Dollar_Value, ccgcc.unlic_gross_value_increase, ccgcc.percentage_unlic_gross_value_increase , 
ccvg_1.gross_lic_Dollar_Value, ccgcc.lic_gross_value_increase, ccgcc.percentage_lic_gross_value_increase
FROM cannabis_c_p.country_canna_gross_value ccvg_1 LEFT JOIN 
(SELECT ccgv1.ref_date, ccgv1.geo, ccgv1.dguid, ccgv1.industry, ccgv1.indicator, 
ccgv1.gross_unlic_Dollar_Value,  ccgv2.gross_unlic_Dollar_Value - ccgv1.gross_unlic_Dollar_Value as unlic_gross_value_increase, 
(ccgv2.gross_unlic_Dollar_Value - ccgv1.gross_unlic_Dollar_Value)/ccgv1.gross_unlic_Dollar_Value as percentage_unlic_gross_value_increase,
ccgv1.gross_lic_Dollar_Value, ccgv2.gross_lic_Dollar_Value - ccgv1.gross_lic_Dollar_Value as lic_gross_value_increase,
(ccgv2.gross_lic_Dollar_Value - ccgv1.gross_lic_Dollar_Value)/ccgv1.gross_lic_Dollar_Value as percentage_lic_gross_value_increase
FROM cannabis_c_p.country_canna_gross_value ccgv1 JOIN cannabis_c_p.country_canna_gross_value ccgv2
ON ccgv2.ref_date = ccgv1.ref_date +1 AND ccgv1.industry = ccgv2.industry
) ccgcc
ON ccvg_1.ref_date = ccgcc.ref_date AND ccvg_1.industry = ccgcc.industry
WHERE ccvg_1.industry = 'Cannabis cultivation industry' )cigv
JOIN
(SELECT ccvg_1.ref_date, ccvg_1.geo,ccvg_1.dguid,ccvg_1.industry,ccvg_1.indicator,
ccvg_1.gross_unlic_Dollar_Value, ccgcc.unlic_gross_value_increase, ccgcc.percentage_unlic_gross_value_increase , 
ccvg_1.gross_lic_Dollar_Value, ccgcc.lic_gross_value_increase, ccgcc.percentage_lic_gross_value_increase
FROM cannabis_c_p.country_canna_gross_value ccvg_1 LEFT JOIN 
(SELECT ccgv1.ref_date, ccgv1.geo, ccgv1.dguid, ccgv1.industry, ccgv1.indicator, 
ccgv1.gross_unlic_Dollar_Value,  ccgv2.gross_unlic_Dollar_Value - ccgv1.gross_unlic_Dollar_Value as unlic_gross_value_increase, 
(ccgv2.gross_unlic_Dollar_Value - ccgv1.gross_unlic_Dollar_Value)/ccgv1.gross_unlic_Dollar_Value as percentage_unlic_gross_value_increase,
ccgv1.gross_lic_Dollar_Value, ccgv2.gross_lic_Dollar_Value - ccgv1.gross_lic_Dollar_Value as lic_gross_value_increase,
(ccgv2.gross_lic_Dollar_Value - ccgv1.gross_lic_Dollar_Value)/ccgv1.gross_lic_Dollar_Value as percentage_lic_gross_value_increase
FROM cannabis_c_p.country_canna_gross_value ccgv1 JOIN cannabis_c_p.country_canna_gross_value ccgv2
ON ccgv2.ref_date = ccgv1.ref_date +1 AND ccgv1.industry = ccgv2.industry
) ccgcc
ON ccvg_1.ref_date = ccgcc.ref_date AND ccvg_1.industry = ccgcc.industry
WHERE ccvg_1.industry = 'Cannabis retail stores') rsgv
ON rsgv.ref_date = cigv.ref_date AND cigv.indicator = rsgv.indicator
ORDER BY 1;

-- CREATE VIEWS FOR ABOVE QUERY
DROP VIEW IF EXISTS cannabis_c_p.canada_gross_val; 
CREATE VIEW cannabis_c_p.canada_gross_val  AS
SELECT cigv.ref_date, cigv.geo,cigv.dguid,cigv.indicator,
cigv.gross_unlic_Dollar_Value as Unlic_Cultivation_Industry_Dollar_Value, cigv.unlic_gross_value_increase as Unlic_Cultivation_Industry_Value_Growth, 
cigv.percentage_unlic_gross_value_increase as Unlic_Cultivation_Industry_Percent_Growth , 
cigv.gross_lic_Dollar_Value as Lic_Cultivation_industry_Dollar_Value, cigv.lic_gross_value_increase as Lic_Cultivation_industry_Value_Growth, 
cigv.percentage_lic_gross_value_increase as Lic_Cultivation_Industry_Percent_Growth,
rsgv.gross_unlic_Dollar_Value as Unlic_Retail_Store_Dollar_Value, rsgv.unlic_gross_value_increase as Unlic_Retail_Store_Value_Growth, 
rsgv.percentage_unlic_gross_value_increase as Unlic_Retail_Store_Percent_Growth , 
rsgv.gross_lic_Dollar_Value as Lic_Retail_Store_Dollar_Value, rsgv.lic_gross_value_increase as Lic_Retail_Store_Value_Growth, 
rsgv.percentage_lic_gross_value_increase as Lic_Retail_Store_Percent_Growth,
(cigv.gross_unlic_Dollar_Value+cigv.gross_lic_Dollar_Value+rsgv.gross_unlic_Dollar_Value+rsgv.gross_lic_Dollar_Value) as Total_Production_Value,
(cigv.gross_unlic_Dollar_Value+rsgv.gross_unlic_Dollar_Value)/ (cigv.gross_unlic_Dollar_Value+cigv.gross_lic_Dollar_Value+rsgv.gross_unlic_Dollar_Value+rsgv.gross_lic_Dollar_Value) * 100 as Percent_From_Unlicensed_Industry,
(cigv.gross_lic_Dollar_Value+rsgv.gross_lic_Dollar_Value)/(cigv.gross_unlic_Dollar_Value+cigv.gross_lic_Dollar_Value+rsgv.gross_unlic_Dollar_Value+rsgv.gross_lic_Dollar_Value) *100 as Percent_From_licensed_Industry
FROM
(SELECT ccvg_1.ref_date, ccvg_1.geo,ccvg_1.dguid,ccvg_1.industry,ccvg_1.indicator,
ccvg_1.gross_unlic_Dollar_Value, ccgcc.unlic_gross_value_increase, ccgcc.percentage_unlic_gross_value_increase , 
ccvg_1.gross_lic_Dollar_Value, ccgcc.lic_gross_value_increase, ccgcc.percentage_lic_gross_value_increase
FROM cannabis_c_p.country_canna_gross_value ccvg_1 LEFT JOIN 
(SELECT ccgv1.ref_date, ccgv1.geo, ccgv1.dguid, ccgv1.industry, ccgv1.indicator, 
ccgv1.gross_unlic_Dollar_Value,  ccgv2.gross_unlic_Dollar_Value - ccgv1.gross_unlic_Dollar_Value as unlic_gross_value_increase, 
(ccgv2.gross_unlic_Dollar_Value - ccgv1.gross_unlic_Dollar_Value)/ccgv1.gross_unlic_Dollar_Value as percentage_unlic_gross_value_increase,
ccgv1.gross_lic_Dollar_Value, ccgv2.gross_lic_Dollar_Value - ccgv1.gross_lic_Dollar_Value as lic_gross_value_increase,
(ccgv2.gross_lic_Dollar_Value - ccgv1.gross_lic_Dollar_Value)/ccgv1.gross_lic_Dollar_Value as percentage_lic_gross_value_increase
FROM cannabis_c_p.country_canna_gross_value ccgv1 JOIN cannabis_c_p.country_canna_gross_value ccgv2
ON ccgv2.ref_date = ccgv1.ref_date +1 AND ccgv1.industry = ccgv2.industry
) ccgcc
ON ccvg_1.ref_date = ccgcc.ref_date AND ccvg_1.industry = ccgcc.industry
WHERE ccvg_1.industry = 'Cannabis cultivation industry' )cigv
JOIN
(SELECT ccvg_1.ref_date, ccvg_1.geo,ccvg_1.dguid,ccvg_1.industry,ccvg_1.indicator,
ccvg_1.gross_unlic_Dollar_Value, ccgcc.unlic_gross_value_increase, ccgcc.percentage_unlic_gross_value_increase , 
ccvg_1.gross_lic_Dollar_Value, ccgcc.lic_gross_value_increase, ccgcc.percentage_lic_gross_value_increase
FROM cannabis_c_p.country_canna_gross_value ccvg_1 LEFT JOIN 
(SELECT ccgv1.ref_date, ccgv1.geo, ccgv1.dguid, ccgv1.industry, ccgv1.indicator, 
ccgv1.gross_unlic_Dollar_Value,  ccgv2.gross_unlic_Dollar_Value - ccgv1.gross_unlic_Dollar_Value as unlic_gross_value_increase, 
(ccgv2.gross_unlic_Dollar_Value - ccgv1.gross_unlic_Dollar_Value)/ccgv1.gross_unlic_Dollar_Value as percentage_unlic_gross_value_increase,
ccgv1.gross_lic_Dollar_Value, ccgv2.gross_lic_Dollar_Value - ccgv1.gross_lic_Dollar_Value as lic_gross_value_increase,
(ccgv2.gross_lic_Dollar_Value - ccgv1.gross_lic_Dollar_Value)/ccgv1.gross_lic_Dollar_Value as percentage_lic_gross_value_increase
FROM cannabis_c_p.country_canna_gross_value ccgv1 JOIN cannabis_c_p.country_canna_gross_value ccgv2
ON ccgv2.ref_date = ccgv1.ref_date +1 AND ccgv1.industry = ccgv2.industry
) ccgcc
ON ccvg_1.ref_date = ccgcc.ref_date AND ccvg_1.industry = ccgcc.industry
WHERE ccvg_1.industry = 'Cannabis retail stores') rsgv
ON rsgv.ref_date = cigv.ref_date AND cigv.indicator = rsgv.indicator
ORDER BY 1;

-- Canada Domestic Market Value
SELECT unlicensed.ref_date, unlicensed.geo as region, unlicensed.indicator, unlicensed.industry, 
unlicensed.authority as "unlicensed_auth", (unlicensed.value *1000000) as "Dom_market_prod_Unlic_Dollar_Value",
licensed.authority as "licensed_auth", (licensed.value *1000000) as "Dom_market_prod_lic_Dollar_Value"
FROM cannabis_c_p.`industr_ prod` unlicensed
JOIN cannabis_c_p.`industr_ prod` licensed
ON unlicensed.ref_date = licensed.ref_date
AND unlicensed.dguid = licensed.dguid
AND unlicensed.industry = licensed.industry
WHERE 
licensed.indicator = "Domestic market production"
AND licensed.authority = "licensed source"
AND  unlicensed.authority = "Unlicensed source"
AND unlicensed.indicator = "Domestic market production"
AND licensed.geo = "Canada"
AND unlicensed.geo = "Canada"
ORDER BY 4,1;

Drop Table if exists cannabis_c_p.dom_market_country;
CREATE TABLE cannabis_c_p.dom_market_country 
(ref_date int,geo varchar(100), dguid varchar(100), industry varchar(100), indicator varchar(100), Dom_market_prod_Unlic_Dollar_Value double,
Dom_market_prod_lic_Dollar_Value double);

INSERT INTO cannabis_c_p.dom_market_country 
SELECT unlicensed.ref_date, unlicensed.geo, unlicensed.dguid,  unlicensed.industry, unlicensed.indicator,
 (unlicensed.value *1000000) as "Dom_market_prod_Unlic_Dollar_Value",
 (licensed.value *1000000) as "Dom_market_prod_lic_Dollar_Value"
FROM cannabis_c_p.`industr_ prod` unlicensed
JOIN cannabis_c_p.`industr_ prod` licensed
ON unlicensed.ref_date = licensed.ref_date
AND unlicensed.dguid = licensed.dguid
AND unlicensed.industry = licensed.industry
WHERE 
licensed.indicator = "Domestic market production"
AND licensed.authority = "licensed source"
AND  unlicensed.authority = "Unlicensed source"
AND unlicensed.indicator = "Domestic market production"
AND licensed.geo = "Canada"
AND unlicensed.geo = "Canada"
ORDER BY  4,1;

SELECT * FROM cannabis_c_p.dom_market_country;

-- Join to calculate yearly increase
SELECT dmp1.ref_date, dmp1.geo, dmp1.industry,dmp1.indicator, dmp1.Dom_market_prod_Unlic_Dollar_Value, 
dmp2.Dom_market_prod_Unlic_Dollar_Value - dmp1.Dom_market_prod_Unlic_Dollar_Value as unlic_value_growth_in_year, 
(dmp2.Dom_market_prod_Unlic_Dollar_Value -dmp1.Dom_market_prod_Unlic_Dollar_Value)/dmp1.Dom_market_prod_Unlic_Dollar_Value as percent_unlic_value_growth_in_year,
dmp1.Dom_market_prod_lic_Dollar_Value, dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value as lic_value_growth_in_year, 
(dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value)/dmp1.Dom_market_prod_lic_Dollar_Value as percent_lic_value_growth_in_year
FROM cannabis_c_p.dom_market_country dmp1 
JOIN
cannabis_c_p.dom_market_country dmp2
ON dmp2.ref_date = dmp1.ref_date + 1 AND dmp1.industry = dmp2.industry AND dmp1.geo=dmp2.geo
ORDER BY 3,2,1;


-- Self Left join to represent full data 

SELECT dmp.ref_date, dmp.geo, dmp.dguid, dmp.indicator, dmp.industry, 
 dmp.Dom_market_prod_Unlic_Dollar_Value,  dmp.Dom_market_prod_lic_Dollar_Value,
 dmpc.ref_date, dmpc.geo, dmpc.industry,dmpc.indicator, dmpc.Dom_market_prod_Unlic_Dollar_Value, 
dmpc.unlic_value_growth_in_year, dmpc.percent_unlic_value_growth_in_year,
dmpc.Dom_market_prod_lic_Dollar_Value, dmpc.lic_value_growth_in_year, dmpc.percent_lic_value_growth_in_year
FROM
cannabis_c_p.dom_market_country  dmp 
LEFT JOIN
(SELECT dmp1.ref_date, dmp1.geo, dmp1.industry,dmp1.indicator, dmp1.Dom_market_prod_Unlic_Dollar_Value, 
dmp2.Dom_market_prod_Unlic_Dollar_Value - dmp1.Dom_market_prod_Unlic_Dollar_Value as unlic_value_growth_in_year, 
(dmp2.Dom_market_prod_Unlic_Dollar_Value -dmp1.Dom_market_prod_Unlic_Dollar_Value)/dmp1.Dom_market_prod_Unlic_Dollar_Value as percent_unlic_value_growth_in_year,
dmp1.Dom_market_prod_lic_Dollar_Value, dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value as lic_value_growth_in_year, 
(dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value)/dmp1.Dom_market_prod_lic_Dollar_Value as percent_lic_value_growth_in_year
FROM cannabis_c_p.dom_market_country dmp1 
JOIN
cannabis_c_p.dom_market_country dmp2
ON dmp2.ref_date = dmp1.ref_date + 1 AND dmp1.industry = dmp2.industry AND dmp1.geo=dmp2.geo
)dmpc
ON
dmp.ref_date = dmpc.ref_date AND dmp.geo = dmpc.geo AND dmp.industry = dmpc.industry
ORDER BY 5,1;

-- SELF JOIN AND seperate by industry

SELECT cidmp.ref_date, cidmp.geo, cidmp.dguid, cidmp.indicator, 
cidmp.Dom_market_prod_Unlic_Dollar_Value as Unlic_Cultivation_Industry_Dollar_Value, 
cidmp.unlic_value_growth_in_year as Unlic_Cultivation_Industry_Value_Growth, 
cidmp.percent_unlic_value_growth_in_year as Unlic_Cultivation_Industry_Percent_Growth,
cidmp.Dom_market_prod_lic_Dollar_Value as Lic_Cultivation_industry_Dollar_Value, 
cidmp.lic_value_growth_in_year as Lic_Cultivation_industry_Value_Growth, cidmp.percent_lic_value_growth_in_year as Lic_Cultivation_Industry_Percent_Growth,
rsdmp.Dom_market_prod_Unlic_Dollar_Value as Unlic_Retail_Store_Dollar_Value, 
rsdmp.unlic_value_growth_in_year as Unlic_Retail_Store_Value_Growth, rsdmp.percent_unlic_value_growth_in_year as Unlic_Retail_Store_Percent_Growth,
rsdmp.Dom_market_prod_lic_Dollar_Value as Lic_Retail_Store_Dollar_Value, 
rsdmp.lic_value_growth_in_year as Lic_Retail_Store_Value_Growth, rsdmp.percent_lic_value_growth_in_year as Lic_Retail_Store_Percent_Growth,
(cidmp.unlic_value_growth_in_year + cidmp.Dom_market_prod_lic_Dollar_Value + rsdmp.Dom_market_prod_Unlic_Dollar_Value+rsdmp.Dom_market_prod_lic_Dollar_Value ) as Total_Gross_Value,
(cidmp.unlic_value_growth_in_year + rsdmp.Dom_market_prod_Unlic_Dollar_Value )/(cidmp.unlic_value_growth_in_year + cidmp.Dom_market_prod_lic_Dollar_Value + rsdmp.Dom_market_prod_Unlic_Dollar_Value+rsdmp.Dom_market_prod_lic_Dollar_Value ) *100 as Percent_From_Unlicensed_Industry,
( cidmp.Dom_market_prod_lic_Dollar_Value +rsdmp.Dom_market_prod_lic_Dollar_Value ) /(cidmp.unlic_value_growth_in_year + cidmp.Dom_market_prod_lic_Dollar_Value + rsdmp.Dom_market_prod_Unlic_Dollar_Value+rsdmp.Dom_market_prod_lic_Dollar_Value) *100 as Percent_From_licensed_Industry
FROM
(SELECT dmp.ref_date, dmp.geo, dmp.dguid, dmp.indicator, dmp.industry, 
 dmp.Dom_market_prod_Unlic_Dollar_Value,  dmp.Dom_market_prod_lic_Dollar_Value,
dmpc.unlic_value_growth_in_year, dmpc.percent_unlic_value_growth_in_year,
 dmpc.lic_value_growth_in_year, dmpc.percent_lic_value_growth_in_year
FROM
cannabis_c_p.dom_market_country dmp 
LEFT JOIN
(SELECT dmp1.ref_date, dmp1.geo, dmp1.industry,dmp1.indicator, dmp1.Dom_market_prod_Unlic_Dollar_Value, 
dmp2.Dom_market_prod_Unlic_Dollar_Value - dmp1.Dom_market_prod_Unlic_Dollar_Value as unlic_value_growth_in_year, 
(dmp2.Dom_market_prod_Unlic_Dollar_Value -dmp1.Dom_market_prod_Unlic_Dollar_Value)/dmp1.Dom_market_prod_Unlic_Dollar_Value as percent_unlic_value_growth_in_year,
dmp1.Dom_market_prod_lic_Dollar_Value, dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value as lic_value_growth_in_year, 
(dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value)/dmp1.Dom_market_prod_lic_Dollar_Value as percent_lic_value_growth_in_year
FROM cannabis_c_p.dom_market_country dmp1 
JOIN
cannabis_c_p.dom_market_country dmp2
ON dmp2.ref_date = dmp1.ref_date + 1 AND dmp1.industry = dmp2.industry AND dmp1.geo=dmp2.geo
)dmpc
ON
dmp.ref_date = dmpc.ref_date AND dmp.geo = dmpc.geo AND dmp.industry = dmpc.industry
WHERE dmp.industry = 'Cannabis cultivation industry')cidmp
JOIN
(SELECT dmp.ref_date, dmp.geo, dmp.dguid, dmp.indicator, dmp.industry, 
 dmp.Dom_market_prod_Unlic_Dollar_Value,  dmp.Dom_market_prod_lic_Dollar_Value,
dmpc.unlic_value_growth_in_year, dmpc.percent_unlic_value_growth_in_year,
 dmpc.lic_value_growth_in_year, dmpc.percent_lic_value_growth_in_year
FROM
cannabis_c_p.dom_market_country  dmp 
LEFT JOIN
(SELECT dmp1.ref_date, dmp1.geo, dmp1.industry,dmp1.indicator, dmp1.Dom_market_prod_Unlic_Dollar_Value, 
dmp2.Dom_market_prod_Unlic_Dollar_Value - dmp1.Dom_market_prod_Unlic_Dollar_Value as unlic_value_growth_in_year, 
(dmp2.Dom_market_prod_Unlic_Dollar_Value -dmp1.Dom_market_prod_Unlic_Dollar_Value)/dmp1.Dom_market_prod_Unlic_Dollar_Value as percent_unlic_value_growth_in_year,
dmp1.Dom_market_prod_lic_Dollar_Value, dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value as lic_value_growth_in_year, 
(dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value)/dmp1.Dom_market_prod_lic_Dollar_Value as percent_lic_value_growth_in_year
FROM cannabis_c_p.dom_market_country dmp1 
JOIN
cannabis_c_p.dom_market_country dmp2
ON dmp2.ref_date = dmp1.ref_date + 1 AND dmp1.industry = dmp2.industry AND dmp1.geo=dmp2.geo
)dmpc
ON
dmp.ref_date = dmpc.ref_date AND dmp.geo = dmpc.geo AND dmp.industry = dmpc.industry
WHERE dmp.industry != 'Cannabis cultivation industry')rsdmp
ON 
cidmp.ref_date= rsdmp.ref_date AND cidmp.geo = rsdmp.geo AND cidmp.indicator = rsdmp.indicator
Order by 1;

Drop view if exists  cannabis_c_p.canada_domestic_market;
CREATE VIEW  cannabis_c_p.canada_domestic_market AS
SELECT cidmp.ref_date, cidmp.geo, cidmp.dguid, cidmp.indicator, 
cidmp.Dom_market_prod_Unlic_Dollar_Value as Unlic_Cultivation_Industry_Dollar_Value, 
cidmp.unlic_value_growth_in_year as Unlic_Cultivation_Industry_Value_Growth, 
cidmp.percent_unlic_value_growth_in_year as Unlic_Cultivation_Industry_Percent_Growth,
cidmp.Dom_market_prod_lic_Dollar_Value as Lic_Cultivation_industry_Dollar_Value, 
cidmp.lic_value_growth_in_year as Lic_Cultivation_industry_Value_Growth, cidmp.percent_lic_value_growth_in_year as Lic_Cultivation_Industry_Percent_Growth,
rsdmp.Dom_market_prod_Unlic_Dollar_Value as Unlic_Retail_Store_Dollar_Value, 
rsdmp.unlic_value_growth_in_year as Unlic_Retail_Store_Value_Growth, rsdmp.percent_unlic_value_growth_in_year as Unlic_Retail_Store_Percent_Growth,
rsdmp.Dom_market_prod_lic_Dollar_Value as Lic_Retail_Store_Dollar_Value, 
rsdmp.lic_value_growth_in_year as Lic_Retail_Store_Value_Growth, rsdmp.percent_lic_value_growth_in_year as Lic_Retail_Store_Percent_Growth,
(cidmp.unlic_value_growth_in_year + cidmp.Dom_market_prod_lic_Dollar_Value + rsdmp.Dom_market_prod_Unlic_Dollar_Value+rsdmp.Dom_market_prod_lic_Dollar_Value ) as Total_Gross_Value,
(cidmp.unlic_value_growth_in_year + rsdmp.Dom_market_prod_Unlic_Dollar_Value )/(cidmp.unlic_value_growth_in_year + cidmp.Dom_market_prod_lic_Dollar_Value + rsdmp.Dom_market_prod_Unlic_Dollar_Value+rsdmp.Dom_market_prod_lic_Dollar_Value ) *100 as Percent_From_Unlicensed_Industry,
( cidmp.Dom_market_prod_lic_Dollar_Value +rsdmp.Dom_market_prod_lic_Dollar_Value ) /(cidmp.unlic_value_growth_in_year + cidmp.Dom_market_prod_lic_Dollar_Value + rsdmp.Dom_market_prod_Unlic_Dollar_Value+rsdmp.Dom_market_prod_lic_Dollar_Value) *100 as Percent_From_licensed_Industry
FROM
(SELECT dmp.ref_date, dmp.geo, dmp.dguid, dmp.indicator, dmp.industry, 
 dmp.Dom_market_prod_Unlic_Dollar_Value,  dmp.Dom_market_prod_lic_Dollar_Value,
dmpc.unlic_value_growth_in_year, dmpc.percent_unlic_value_growth_in_year,
 dmpc.lic_value_growth_in_year, dmpc.percent_lic_value_growth_in_year
FROM
cannabis_c_p.dom_market_country dmp 
LEFT JOIN
(SELECT dmp1.ref_date, dmp1.geo, dmp1.industry,dmp1.indicator, dmp1.Dom_market_prod_Unlic_Dollar_Value, 
dmp2.Dom_market_prod_Unlic_Dollar_Value - dmp1.Dom_market_prod_Unlic_Dollar_Value as unlic_value_growth_in_year, 
(dmp2.Dom_market_prod_Unlic_Dollar_Value -dmp1.Dom_market_prod_Unlic_Dollar_Value)/dmp1.Dom_market_prod_Unlic_Dollar_Value as percent_unlic_value_growth_in_year,
dmp1.Dom_market_prod_lic_Dollar_Value, dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value as lic_value_growth_in_year, 
(dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value)/dmp1.Dom_market_prod_lic_Dollar_Value as percent_lic_value_growth_in_year
FROM cannabis_c_p.dom_market_country dmp1 
JOIN
cannabis_c_p.dom_market_country dmp2
ON dmp2.ref_date = dmp1.ref_date + 1 AND dmp1.industry = dmp2.industry AND dmp1.geo=dmp2.geo
)dmpc
ON
dmp.ref_date = dmpc.ref_date AND dmp.geo = dmpc.geo AND dmp.industry = dmpc.industry
WHERE dmp.industry = 'Cannabis cultivation industry')cidmp
JOIN
(SELECT dmp.ref_date, dmp.geo, dmp.dguid, dmp.indicator, dmp.industry, 
 dmp.Dom_market_prod_Unlic_Dollar_Value,  dmp.Dom_market_prod_lic_Dollar_Value,
dmpc.unlic_value_growth_in_year, dmpc.percent_unlic_value_growth_in_year,
 dmpc.lic_value_growth_in_year, dmpc.percent_lic_value_growth_in_year
FROM
cannabis_c_p.dom_market_country  dmp 
LEFT JOIN
(SELECT dmp1.ref_date, dmp1.geo, dmp1.industry,dmp1.indicator, dmp1.Dom_market_prod_Unlic_Dollar_Value, 
dmp2.Dom_market_prod_Unlic_Dollar_Value - dmp1.Dom_market_prod_Unlic_Dollar_Value as unlic_value_growth_in_year, 
(dmp2.Dom_market_prod_Unlic_Dollar_Value -dmp1.Dom_market_prod_Unlic_Dollar_Value)/dmp1.Dom_market_prod_Unlic_Dollar_Value as percent_unlic_value_growth_in_year,
dmp1.Dom_market_prod_lic_Dollar_Value, dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value as lic_value_growth_in_year, 
(dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value)/dmp1.Dom_market_prod_lic_Dollar_Value as percent_lic_value_growth_in_year
FROM cannabis_c_p.dom_market_country dmp1 
JOIN
cannabis_c_p.dom_market_country dmp2
ON dmp2.ref_date = dmp1.ref_date + 1 AND dmp1.industry = dmp2.industry AND dmp1.geo=dmp2.geo
)dmpc
ON
dmp.ref_date = dmpc.ref_date AND dmp.geo = dmpc.geo AND dmp.industry = dmpc.industry
WHERE dmp.industry != 'Cannabis cultivation industry')rsdmp
ON 
cidmp.ref_date= rsdmp.ref_date AND cidmp.geo = rsdmp.geo AND cidmp.indicator = rsdmp.indicator
Order by 1;