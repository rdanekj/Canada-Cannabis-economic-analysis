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

##Domestic production value of Provinces in Canada
SELECT unlicensed.ref_date, unlicensed.dguid, unlicensed.geo as region, unlicensed.indicator, unlicensed.industry, unlicensed.authority,
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
AND licensed.geo != "Canada"
AND unlicensed.geo != "Canada"
ORDER BY 3,4,2,1;

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
-- CREAT VIEW FOR ABOVE QUERY
Drop View if exists cannabis_c_p.canada_domestic_prod;
CREATE VIEW cannabis_c_p.canada_domestic_prod as 
SELECT cdp1.ref_date,cdp1.dguid,cdp1.geo,cdp1.indicator, cdp1.industry ,
cdp1.unlicensed_domestic_prod_Value "Unlicensed domestic Prod Value", cdvp.unlicen_domestic_growth , (cdvp.unlicen_domestic_growth/cdp1.unlicensed_domestic_prod_Value ) as "Unlicenced Domestic Prod Percentage growth",
 cdp1.licensed_domestic_prod_Value "Licensed domestic Prod Value", cdvp.licensed_domestic_growth "Licensed domestic Prod Value Gained", (cdvp.licensed_domestic_growth/cdp1.licensed_domestic_prod_Value ) "Licenced Domestic Prod Percentage growth"
From cannabis_c_p.domestic_prod_country cdp1 LEFT JOIN 
(SELECT cdp_1.ref_date,cdp_1.dguid ,cdp_1.geo ,cdp_1.indicator , cdp_1.industry ,cdp_1.unlicensed_domestic_prod_Value,
(cdp_2.unlicensed_domestic_prod_Value - cdp_1.unlicensed_domestic_prod_Value) as unlicen_domestic_growth , cdp_1.licensed_domestic_prod_Value ,(cdp_2.licensed_domestic_prod_Value -cdp_1.licensed_domestic_prod_Value) as licensed_domestic_growth
From cannabis_c_p.domestic_prod_country cdp_1 JOIN cannabis_c_p.domestic_prod_country cdp_2
ON cdp_2.ref_date = cdp_1.ref_date + 1 and cdp_1.industry = cdp_2.industry) cdvp
ON  cdp1.ref_date = cdvp.ref_date AND cdp1.industry = cdvp.industry AND cdp1.dguid = cdvp.dguid
ORDER BY 5,1; 

-- Domestice production for Provinces
DROP TABLE if exists cannabis_c_p.domestic_prod_provinces;
CREATE TABLE cannabis_c_p.domestic_prod_provinces 
( ref_date int, 
 dguid varchar (60),geo varchar (60) ,indicator varchar (60), industry varchar (255),unlicensed_domestic_prod_Value double ,licensed_domestic_prod_Value double);
INSERT INTO cannabis_c_p.domestic_prod_provinces
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
AND licensed.geo != "Canada"
AND unlicensed.geo != "Canada";

select * 
FROM cannabis_c_p.domestic_prod_provinces ORDER BY 5,3,1;
-- SELF JOIN domestic_prod_provinces to calculate change in production value each year and then create temporary table for only yearly difference then join and create new temp table to have production value and production changes in one table. 
SELECT pdp_1.ref_date,pdp_1.dguid ,pdp_1.geo ,pdp_1.indicator , pdp_1.industry ,pdp_1.unlicensed_domestic_prod_Value,
(pdp_2.unlicensed_domestic_prod_Value - pdp_1.unlicensed_domestic_prod_Value) as unlicen_domestic_growth , 
pdp_1.licensed_domestic_prod_Value ,(pdp_2.licensed_domestic_prod_Value -pdp_1.licensed_domestic_prod_Value) as licensed_domestic_growth
From cannabis_c_p.domestic_prod_provinces pdp_1 JOIN cannabis_c_p.domestic_prod_provinces pdp_2
ON pdp_2.ref_date = pdp_1.ref_date + 1 and pdp_1.industry = pdp_2.industry AND  pdp_2.geo = pdp_1.geo 
ORDER BY 5,3,1;

select dpp.ref_date, dpp.dguid,dpp.geo, dpp.indicator,dpp.industry,dpp.unlicensed_domestic_prod_Value,
dpg.unlicen_domestic_growth,dpg.Unlicen_percentage_growth, dpp.licensed_domestic_prod_Value, dpg.licensed_domestic_growth, dpg.Licen_percentage_growth
FROM cannabis_c_p.domestic_prod_provinces dpp Left JOIN (SELECT pdp_1.ref_date,pdp_1.dguid ,pdp_1.geo ,pdp_1.indicator , pdp_1.industry ,pdp_1.unlicensed_domestic_prod_Value,
(pdp_2.unlicensed_domestic_prod_Value - pdp_1.unlicensed_domestic_prod_Value) as unlicen_domestic_growth , (pdp_2.unlicensed_domestic_prod_Value - pdp_1.unlicensed_domestic_prod_Value)/pdp_1.unlicensed_domestic_prod_Value as Unlicen_percentage_growth,
pdp_1.licensed_domestic_prod_Value ,(pdp_2.licensed_domestic_prod_Value -pdp_1.licensed_domestic_prod_Value) as licensed_domestic_growth , (pdp_2.licensed_domestic_prod_Value -pdp_1.licensed_domestic_prod_Value)/pdp_1.licensed_domestic_prod_Value  as Licen_percentage_growth
From cannabis_c_p.domestic_prod_provinces pdp_1 JOIN cannabis_c_p.domestic_prod_provinces pdp_2
ON pdp_2.ref_date = pdp_1.ref_date + 1 and pdp_1.industry = pdp_2.industry AND  pdp_2.geo = pdp_1.geo 
) dpg
ON dpp.ref_date = dpg.ref_date AND dpp.industry = dpg.industry AND  dpp.geo = dpg.geo
ORDER BY 5,3,1;

-- CREATE VIEW FOR ABOVE QUERY 
DROP view if exists cannabis_c_p.province_domestic_prod;
 CREATE VIEW cannabis_c_p.province_domestic_prod as 
select dpp.ref_date, dpp.dguid,dpp.geo, dpp.indicator,dpp.industry,
dpp.unlicensed_domestic_prod_Value "Unlicensed domestic Prod Value", dpg.unlicen_domestic_growth "Unlicensed domestic Prod Value gained",dpg.Unlicen_percentage_growth "Unlicensed domestic Prod Value Percentage growth", 
dpp.licensed_domestic_prod_Value "Licensed domestic Prod Value", dpg.licensed_domestic_growth "Licensed domestic Prod Value gained", dpg.Licen_percentage_growth "Licensed domestic Prod Value Percentage growth"
FROM cannabis_c_p.domestic_prod_provinces dpp Left JOIN (SELECT pdp_1.ref_date,pdp_1.dguid ,pdp_1.geo ,pdp_1.indicator , pdp_1.industry ,pdp_1.unlicensed_domestic_prod_Value,
(pdp_2.unlicensed_domestic_prod_Value - pdp_1.unlicensed_domestic_prod_Value) as unlicen_domestic_growth , (pdp_2.unlicensed_domestic_prod_Value - pdp_1.unlicensed_domestic_prod_Value)/pdp_1.unlicensed_domestic_prod_Value as Unlicen_percentage_growth,
pdp_1.licensed_domestic_prod_Value ,(pdp_2.licensed_domestic_prod_Value -pdp_1.licensed_domestic_prod_Value) as licensed_domestic_growth , (pdp_2.licensed_domestic_prod_Value -pdp_1.licensed_domestic_prod_Value)/pdp_1.licensed_domestic_prod_Value  as Licen_percentage_growth
From cannabis_c_p.domestic_prod_provinces pdp_1 JOIN cannabis_c_p.domestic_prod_provinces pdp_2
ON pdp_2.ref_date = pdp_1.ref_date + 1 and pdp_1.industry = pdp_2.industry AND  pdp_2.geo = pdp_1.geo 
) dpg
ON dpp.ref_date = dpg.ref_date AND dpp.industry = dpg.industry AND  dpp.geo = dpg.geo
ORDER BY 5,3,1;


##Total Domestic own-use production value for province Canada ##
SELECT unlicensed.ref_date, unlicensed.geo as region, unlicensed.indicator, unlicensed.industry, unlicensed.authority, (unlicensed.value *1000000) as "dom_use_unlic_value",
licensed.authority, (licensed.value *1000000) as "dom_use_lic_value"
FROM cannabis_c_p.`industr_ prod` unlicensed
JOIN cannabis_c_p.`industr_ prod` licensed
ON unlicensed.ref_date = licensed.ref_date
AND unlicensed.industry = licensed.industry
AND unlicensed.geo = licensed.geo
WHERE 
unlicensed.indicator = "Domestic own-use production"
AND unlicensed.authority = "Unlicensed source"
AND licensed.indicator = "Domestic own-use production"
AND licensed.authority = "licensed source"
AND licensed.geo != "Canada"
AND unlicensed.geo != "Canada"
ORDER BY  3,4,2,1;
-- Table
DROP TABLE if EXISTS cannabis_c_p.dom_prod_province;
Create Table cannabis_c_p.dom_prod_province
( ref_date int, geo varchar (100), indicator varchar (100), industry varchar (100), unlic_dom_use_value int,
 lic_dom_use_value int);
 INSERT INTO cannabis_c_p.dom_prod_province
SELECT unlicensed.ref_date, unlicensed.geo, unlicensed.indicator, unlicensed.industry, (unlicensed.value *1000000) as "unlic_dom_use_value",
 (licensed.value *1000000) as "lic_dom_use_value"
FROM cannabis_c_p.`industr_ prod` unlicensed
JOIN cannabis_c_p.`industr_ prod` licensed
ON unlicensed.ref_date = licensed.ref_date
AND unlicensed.industry = licensed.industry
AND unlicensed.geo = licensed.geo
WHERE 
unlicensed.indicator = "Domestic own-use production"
AND unlicensed.authority = "Unlicensed source"
AND licensed.indicator = "Domestic own-use production"
AND licensed.authority = "licensed source"
AND licensed.geo != "Canada"
AND unlicensed.geo != "Canada"
ORDER BY  3,4,2,1;
SELECT *
FROM cannabis_c_p.dom_prod_province;

SELECT dpp1.ref_date , dpp1.geo , dpp1.indicator , dpp1.industry , 
 (dpp2.unlic_dom_use_value - dpp1.unlic_dom_use_value)as "unlic_dom_value_growth", (dpp2.unlic_dom_use_value - dpp1.unlic_dom_use_value)/dpp1.unlic_dom_use_value as "percent_growth_unlic_dom_value"
 ,(dpp2.lic_dom_use_value-dpp1.lic_dom_use_value) as "lic_dom_value_growth",(dpp2.lic_dom_use_value - dpp1.lic_dom_use_value)/dpp1.unlic_dom_use_value  as "percent_growth_lic_dom_value"
FROM cannabis_c_p.dom_prod_province dpp1 JOIN cannabis_c_p.dom_prod_province dpp2
ON dpp2.ref_date = dpp1.ref_date +1 AND dpp1.industry=dpp2.industry  AND dpp2.geo = dpp1.geo
ORDER BY 4,2,1; 

SELECT dpp.ref_date,dpp.geo,dpp.indicator,dpp.industry,dpp.unlic_dom_use_value, dppg.unlic_dom_value_growth,dppg.percent_growth_unlic_dom_value, dpp.lic_dom_use_value, dppg.lic_dom_value_growth,dppg.percent_growth_lic_dom_value
FROM cannabis_c_p.dom_prod_province dpp LEFT JOIN (SELECT dpp1.ref_date , dpp1.geo , dpp1.indicator , dpp1.industry , 
 (dpp2.unlic_dom_use_value - dpp1.unlic_dom_use_value)as "unlic_dom_value_growth", (dpp2.unlic_dom_use_value - dpp1.unlic_dom_use_value)/dpp1.unlic_dom_use_value  as "percent_growth_unlic_dom_value"
 ,(dpp2.lic_dom_use_value-dpp1.lic_dom_use_value) as "lic_dom_value_growth",(dpp2.lic_dom_use_value - dpp1.lic_dom_use_value)/dpp1.unlic_dom_use_value  as "percent_growth_lic_dom_value"
FROM cannabis_c_p.dom_prod_province dpp1 JOIN cannabis_c_p.dom_prod_province dpp2
ON dpp2.ref_date = dpp1.ref_date +1 AND dpp1.industry=dpp2.industry  AND dpp2.geo = dpp1.geo) dppg
ON dpp.ref_date = dppg.ref_date AND dpp.geo = dppg.geo AND dppg.industry = dpp.industry
ORDER BY 4,5,1;
-- make view for above query
Drop view if exists cannabis_c_p.province_own_use;
CREATE VIEW  cannabis_c_p.province_own_use as
SELECT dpp.ref_date,dpp.geo,dpp.indicator,dpp.industry,
dpp.unlic_dom_use_value "Unlicensed Domestic-Own-Use value", dppg.unlic_dom_value_growth "Unlicensed Domestic-Own-Use value Gained",dppg.percent_growth_unlic_dom_value "Unlicensed Domestic-Own-Use value Percentage growth", 
dpp.lic_dom_use_value "Licensed Domestic-Own-Use value", dppg.lic_dom_value_growth "Licensed Domestic-Own-Use value Gained",dppg.percent_growth_lic_dom_value "Licensed Domestic-Own-Use value Percentage growth"
FROM cannabis_c_p.dom_prod_province dpp LEFT JOIN (SELECT dpp1.ref_date , dpp1.geo , dpp1.indicator , dpp1.industry , 
 (dpp2.unlic_dom_use_value - dpp1.unlic_dom_use_value)as "unlic_dom_value_growth", (dpp2.unlic_dom_use_value - dpp1.unlic_dom_use_value)/dpp1.unlic_dom_use_value  as "percent_growth_unlic_dom_value"
 ,(dpp2.lic_dom_use_value-dpp1.lic_dom_use_value) as "lic_dom_value_growth",(dpp2.lic_dom_use_value - dpp1.lic_dom_use_value)/dpp1.unlic_dom_use_value  as "percent_growth_lic_dom_value"
FROM cannabis_c_p.dom_prod_province dpp1 JOIN cannabis_c_p.dom_prod_province dpp2
ON dpp2.ref_date = dpp1.ref_date +1 AND dpp1.industry=dpp2.industry  AND dpp2.geo = dpp1.geo) dppg
ON dpp.ref_date = dppg.ref_date AND dpp.geo = dppg.geo AND dppg.industry = dpp.industry
ORDER BY 4,5,1;

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
-- CREATE VIEWS WITH ABOVE QUERY
DROP VIEW IF EXISTS cannabis_c_p.canada_own_use ;
CREATE VIEW  cannabis_c_p.canada_own_use AS
SELECT cdup.ref_date , cdup.geo, cdup.dguid,cdup.indicator,cdup.industry,
 cdup.dom_use_unlic_value "Licensed Domestic Own Use Value", cdupg.unlic_growth "Licensed Domestic-Own-Use value Gained", cdupg.percent_growth_unlic_dom_use "Licensed Domestic-Own-Use value Percentage growth" ,
 cdup.dom_use_lic_value "Unlicensed Domestic Own Use Value",cdupg.lic_growth "Unlicensed Domestic-Own-Use value Gained", cdupg.percent_growth_lic_dom_use "Unlicensed Domestic-Own-Use value Percentage growth"
From cannabis_c_p.country_dom_use_prod cdup LEFT JOIN 
(SELECT dup1.ref_date, dup1.dguid, dup1.geo, dup1.industry, dup1.indicator, 
dup1.dom_use_unlic_value,(dup2.dom_use_unlic_value-dup1.dom_use_unlic_value) as unlic_growth ,
((dup2.dom_use_unlic_value-dup1.dom_use_unlic_value)/dup1.dom_use_unlic_value) as "percent_growth_unlic_dom_use" , dup1.dom_use_lic_value, 
(dup2.dom_use_lic_value - dup1.dom_use_lic_value) as lic_growth, ((dup2.dom_use_lic_value-dup1.dom_use_lic_value)/dup1.dom_use_lic_value) as "percent_growth_lic_dom_use"
From cannabis_c_p.country_dom_use_prod dup1 JOIN cannabis_c_p.country_dom_use_prod dup2
ON dup2.ref_date = dup1.ref_date + 1 AND  dup1.industry = dup2.industry) cdupg
ON cdup.ref_date = cdupg.ref_date AND cdup.industry = cdupg.industry
ORDER BY 5,1; 

##Intermediate consumption Value  in Provinces of Canada Yearly##


SELECT unlicensed.ref_date, unlicensed.geo as region, unlicensed.indicator, unlicensed.industry, unlicensed.authority as "unlicensed_auth", (unlicensed.value *1000000) as "Unlic Dollar_Value",
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
AND licensed.geo <> "Canada"
AND unlicensed.geo <> "Canada"
ORDER BY  3,4,2,1;

DROP TABLE IF EXISTS cannabis_c_p.province_int_consump;
CREATE TABLE cannabis_c_p.province_int_consump
(ref_date int, geo varchar(100),dguid varchar(100), indicator varchar(100),
industry varchar(100), Unlic_inter_Dollar_Value int, lic_inter_Dollar_Value int);
INSERT INTO cannabis_c_p.province_int_consump
SELECT unlicensed.ref_date, unlicensed.geo , unlicensed.dguid,unlicensed.indicator, unlicensed.industry,  (unlicensed.value *1000000) as "Unlic_inter_Dollar_Value",
 (licensed.value *1000000) as "lic_inter_Dollar_Value"
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
AND licensed.geo <> "Canada"
AND unlicensed.geo <> "Canada"
ORDER BY  3,4,2,1;

SELECT pic.ref_date, pic.geo ,pic.dguid, pic.indicator , pic.industry , pic.Unlic_inter_Dollar_Value , 
(pic2.Unlic_inter_Dollar_Value -pic.Unlic_inter_Dollar_Value) as year_unlisc_growth,(pic2.Unlic_inter_Dollar_Value -pic.Unlic_inter_Dollar_Value)/pic.Unlic_inter_Dollar_Value as year_unlisc_value_percent_growth,pic.lic_inter_Dollar_Value,
 (pic2.lic_inter_Dollar_Value - pic.lic_inter_Dollar_Value) year_lisc_growth ,(pic2.lic_inter_Dollar_Value -pic.lic_inter_Dollar_Value)/pic.lic_inter_Dollar_Value as year_lisc_value_percent_growth
FROM cannabis_c_p.province_int_consump pic JOIN cannabis_c_p.province_int_consump pic2 
ON pic2.ref_date = pic.ref_date + 1  AND pic.geo = pic2.geo AND pic.dguid=pic2.dguid AND pic.industry = pic2.industry
ORDER BY 5,2,1;

SELECT pic_1.ref_date,  pic_1.geo,pic_1.dguid,pic_1.indicator,pic_1.industry,
pic_1.Unlic_inter_Dollar_Value , picg.year_unlisc_growth, picg.year_unlisc_value_percent_growth,
pic_1.lic_inter_Dollar_Value, picg.year_lisc_growth, picg.year_lisc_value_percent_growth
FROM cannabis_c_p.province_int_consump pic_1 LEFT JOIN 
(SELECT pic.ref_date, pic.geo ,pic.dguid, pic.indicator , pic.industry , pic.Unlic_inter_Dollar_Value , 
(pic2.Unlic_inter_Dollar_Value -pic.Unlic_inter_Dollar_Value) as year_unlisc_growth,(pic2.Unlic_inter_Dollar_Value -pic.Unlic_inter_Dollar_Value)/pic.Unlic_inter_Dollar_Value as year_unlisc_value_percent_growth,pic.lic_inter_Dollar_Value,
 (pic2.lic_inter_Dollar_Value - pic.lic_inter_Dollar_Value) year_lisc_growth ,(pic2.lic_inter_Dollar_Value -pic.lic_inter_Dollar_Value)/pic.lic_inter_Dollar_Value as year_lisc_value_percent_growth
FROM cannabis_c_p.province_int_consump pic JOIN cannabis_c_p.province_int_consump pic2 
ON pic2.ref_date = pic.ref_date + 1  AND pic.geo = pic2.geo AND pic.dguid=pic2.dguid AND pic.industry = pic2.industry) picg 
ON  pic_1.ref_date=picg.ref_date AND pic_1.geo = picg.geo AND pic_1.dguid=picg.dguid AND pic_1.industry = picg.industry
ORDER BY 5,2,1;

-- CREATE VIEW FOR ABOVE QUERY
DROP VIEW IF EXISTS cannabis_c_p.province_interm_consump; 
CREATE VIEW cannabis_c_p.province_interm_consump  AS 
SELECT pic_1.ref_date,  pic_1.geo,pic_1.dguid,pic_1.indicator,pic_1.industry,
pic_1.Unlic_inter_Dollar_Value "Unlicensed Intermediate Consumption Value" , picg.year_unlisc_growth "Unlicensed Intermediate Consumption Gained", picg.year_unlisc_value_percent_growth "Unlicensed Intermediate Consumption Percentage Growth",
pic_1.lic_inter_Dollar_Value "Licensed Intermediate Consumption Value", picg.year_lisc_growth "Licensed Intermediate Consumption Gained", picg.year_lisc_value_percent_growth "Licensed Intermediate Consumption Percentage Growth"
FROM cannabis_c_p.province_int_consump pic_1 LEFT JOIN 
(SELECT pic.ref_date, pic.geo ,pic.dguid, pic.indicator , pic.industry , pic.Unlic_inter_Dollar_Value , 
(pic2.Unlic_inter_Dollar_Value -pic.Unlic_inter_Dollar_Value) as year_unlisc_growth,(pic2.Unlic_inter_Dollar_Value -pic.Unlic_inter_Dollar_Value)/pic.Unlic_inter_Dollar_Value as year_unlisc_value_percent_growth,pic.lic_inter_Dollar_Value,
 (pic2.lic_inter_Dollar_Value - pic.lic_inter_Dollar_Value) year_lisc_growth ,(pic2.lic_inter_Dollar_Value -pic.lic_inter_Dollar_Value)/pic.lic_inter_Dollar_Value as year_lisc_value_percent_growth
FROM cannabis_c_p.province_int_consump pic JOIN cannabis_c_p.province_int_consump pic2 
ON pic2.ref_date = pic.ref_date + 1  AND pic.geo = pic2.geo AND pic.dguid=pic2.dguid AND pic.industry = pic2.industry) picg 
ON  pic_1.ref_date=picg.ref_date AND pic_1.geo = picg.geo AND pic_1.dguid=picg.dguid AND pic_1.industry = picg.industry
ORDER BY 5,2,1;

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


SELECT cic_1.ref_date, cic_1.geo, cic_1.dguid, cic_1.industry, cic_1.unlic_Dollar_value, cicg.unlic_value_growth_in_year, cicg.percent_unlic_value_growth, cic_1.int_lic_Dollar_Value, cicg.lic_value_growth_in_year, cicg.percent_lic_value_growth
FROM cannabis_c_p.country_interm_consump cic_1 LEFT JOIN (SELECT cic1.ref_date, cic1.geo, cic1.dguid, cic1.indicator, cic1.industry, cic2.Unlic_Dollar_Value - cic1.Unlic_Dollar_Value as unlic_value_growth_in_year, (cic2.Unlic_Dollar_Value - cic1.Unlic_Dollar_Value)/cic1.Unlic_Dollar_Value as percent_unlic_value_growth,
cic2.int_lic_Dollar_Value - cic1.int_lic_Dollar_Value as lic_value_growth_in_year, (cic2.int_lic_Dollar_Value - cic1.int_lic_Dollar_Value)/cic1.int_lic_Dollar_Value as percent_lic_value_growth
FROM cannabis_c_p.country_interm_consump cic1 join cannabis_c_p.country_interm_consump cic2
ON cic2.ref_date = cic1.ref_date +1 AND cic1.industry = cic2.industry) cicg
ON cic_1.ref_date = cicg.ref_date AND cic_1.industry = cicg.industry
ORDER BY 4,1 ;
-- CREAT VIEW OF ABOVE query
DROP VIEW IF EXISTS cannabis_c_p.canada_interm_consump ;
CREATE VIEW cannabis_c_p.canada_interm_consump  AS
SELECT cic_1.ref_date, cic_1.geo, cic_1.dguid, cic_1.indicator ,cic_1.industry, 
cic_1.unlic_Dollar_value "Unlicensed Intermediate Consumption Value", cicg.unlic_value_growth_in_year "Unlicensed Intermediate Consumption Value Gained", cicg.percent_unlic_value_growth "Unlicensed Intermediate Consumption Percentage Growth", 
cic_1.int_lic_Dollar_Value "Licensed Intermediate Consumption Value", cicg.lic_value_growth_in_year "Licensed Intermediate Consumption Value Gained", cicg.percent_lic_value_growth "Licensed Intermediate Consumption Percentage Growth"
FROM cannabis_c_p.country_interm_consump cic_1 LEFT JOIN (SELECT cic1.ref_date, cic1.geo, cic1.dguid, cic1.indicator, cic1.industry, cic2.Unlic_Dollar_Value - cic1.Unlic_Dollar_Value as unlic_value_growth_in_year, (cic2.Unlic_Dollar_Value - cic1.Unlic_Dollar_Value)/cic1.Unlic_Dollar_Value as percent_unlic_value_growth,
cic2.int_lic_Dollar_Value - cic1.int_lic_Dollar_Value as lic_value_growth_in_year, (cic2.int_lic_Dollar_Value - cic1.int_lic_Dollar_Value)/cic1.int_lic_Dollar_Value as percent_lic_value_growth
FROM cannabis_c_p.country_interm_consump cic1 join cannabis_c_p.country_interm_consump cic2
ON cic2.ref_date = cic1.ref_date +1 AND cic1.industry = cic2.industry) cicg
ON cic_1.ref_date = cicg.ref_date AND cic_1.industry = cicg.industry
ORDER BY 5,1 ;

##Gross value gained in each Province of Canada yearly##
SELECT unlicensed.ref_date, unlicensed.geo as region, unlicensed.industry, unlicensed.indicator, unlicensed.authority as "unlicensed_auth", (unlicensed.value *1000000) as "gross_unlic_Dollar_Value",
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
AND licensed.geo != "Canada"
AND unlicensed.geo != "Canada"
ORDER BY  3,4,2,1;

DROP TABLE IF EXISTS cannabis_c_p.gross_val_added_per_region;
Create Table cannabis_c_p.gross_val_added_per_region
(ref_date int,geo varchar(100), dguid varchar(100), industry varchar(100), indicator varchar(100), gross_unlic_Dollar_Value int,
gross_lic_Dollar_Value int);

INSERT INTO cannabis_c_p.gross_val_added_per_region
SELECT unlicensed.ref_date, unlicensed.geo ,unlicensed.dguid, unlicensed.industry, unlicensed.indicator, (unlicensed.value *1000000) as "gross_unlic_Dollar_Value",
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
AND licensed.geo != "Canada"
AND unlicensed.geo != "Canada"
ORDER BY  3,4,2,1;

SELECT gvap1.ref_date,gvap1.geo, gvap1.industry,gvap1.indicator, gvap1.gross_unlic_Dollar_Value, 
gvap2.gross_unlic_Dollar_Value -gvap1.gross_unlic_Dollar_Value as unlic_value_growth_in_year, 
(gvap2.gross_unlic_Dollar_Value -gvap1.gross_unlic_Dollar_Value)/gvap1.gross_unlic_Dollar_Value as percent_unlic_value_growth_in_year,
gvap1.gross_lic_Dollar_Value, gvap2.gross_lic_Dollar_Value - gvap1.gross_lic_Dollar_Value as lic_value_growth_in_year, 
(gvap2.gross_lic_Dollar_Value - gvap1.gross_lic_Dollar_Value)/gvap1.gross_lic_Dollar_Value as percent_lic_value_growth_in_year
FROM cannabis_c_p.gross_val_added_per_region gvap1 JOIN cannabis_c_p.gross_val_added_per_region gvap2
ON gvap2.ref_date = gvap1.ref_date + 1 AND gvap1.industry = gvap2.industry AND gvap1.geo=gvap2.geo
ORDER BY 3,2,1;

SELECT  gvar.ref_date,  gvar.geo, gvar.dguid, gvar.industry,gvar.indicator, gvar.gross_unlic_Dollar_Value,  ggvap.unlic_value_growth_in_year , ggvap.percent_unlic_value_growth_in_year,
gvar.gross_lic_Dollar_Value, ggvap.lic_value_growth_in_year, ggvap.percent_lic_value_growth_in_year
FROM cannabis_c_p.gross_val_added_per_region gvar LEFT JOIN 
(SELECT gvap1.ref_date,gvap1.geo,gvap1.industry,gvap1.indicator, 
gvap2.gross_unlic_Dollar_Value -gvap1.gross_unlic_Dollar_Value as unlic_value_growth_in_year, 
(gvap2.gross_unlic_Dollar_Value -gvap1.gross_unlic_Dollar_Value)/gvap1.gross_unlic_Dollar_Value as percent_unlic_value_growth_in_year,
 gvap2.gross_lic_Dollar_Value - gvap1.gross_lic_Dollar_Value as lic_value_growth_in_year, 
(gvap2.gross_lic_Dollar_Value - gvap1.gross_lic_Dollar_Value)/gvap1.gross_lic_Dollar_Value as percent_lic_value_growth_in_year
FROM cannabis_c_p.gross_val_added_per_region gvap1 JOIN cannabis_c_p.gross_val_added_per_region gvap2
ON gvap2.ref_date = gvap1.ref_date + 1 AND gvap1.industry = gvap2.industry AND gvap1.geo=gvap2.geo) ggvap
ON gvar.ref_date = ggvap.ref_date AND gvar.industry = ggvap.industry AND gvar.geo = ggvap.geo 
ORDER BY 4,2,1;
-- CREATE VIEW WITH ABOVE QUERY
DROP VIEW IF EXISTS cannabis_c_p.province_gross_val;
CREATE VIEW  cannabis_c_p.province_gross_val as 
SELECT  gvar.ref_date,  gvar.geo, gvar.dguid, gvar.industry,gvar.indicator, gvar.gross_unlic_Dollar_Value "Unlicensed Gross Value",  ggvap.unlic_value_growth_in_year "Unlicensed Gross Value Gained", ggvap.percent_unlic_value_growth_in_year "Unlicensed Gross Value Percentage change",
gvar.gross_lic_Dollar_Value "Licensed Gross Value", ggvap.lic_value_growth_in_year "Licensed Gross Value Gained", ggvap.percent_lic_value_growth_in_year "Licensed Gross Value Percentage change"
FROM cannabis_c_p.gross_val_added_per_region gvar LEFT JOIN 
(SELECT gvap1.ref_date,gvap1.geo,gvap1.industry,gvap1.indicator, 
gvap2.gross_unlic_Dollar_Value -gvap1.gross_unlic_Dollar_Value as unlic_value_growth_in_year, 
(gvap2.gross_unlic_Dollar_Value -gvap1.gross_unlic_Dollar_Value)/gvap1.gross_unlic_Dollar_Value as percent_unlic_value_growth_in_year,
 gvap2.gross_lic_Dollar_Value - gvap1.gross_lic_Dollar_Value as lic_value_growth_in_year, 
(gvap2.gross_lic_Dollar_Value - gvap1.gross_lic_Dollar_Value)/gvap1.gross_lic_Dollar_Value as percent_lic_value_growth_in_year
FROM cannabis_c_p.gross_val_added_per_region gvap1 JOIN cannabis_c_p.gross_val_added_per_region gvap2
ON gvap2.ref_date = gvap1.ref_date + 1 AND gvap1.industry = gvap2.industry AND gvap1.geo=gvap2.geo) ggvap
ON gvar.ref_date = ggvap.ref_date AND gvar.industry = ggvap.industry AND gvar.geo = ggvap.geo 
ORDER BY 4,2,1;

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
-- CREATE VIEWS FOR ABOVE QUERY
DROP VIEW IF EXISTS cannabis_c_p.canada_gross_val; 
CREATE VIEW cannabis_c_p.canada_gross_val  AS
SELECT ccvg_1.ref_date, ccvg_1.geo,ccvg_1.dguid,ccvg_1.industry,ccvg_1.indicator,
ccvg_1.gross_unlic_Dollar_Value as "Unlicensed Gross Value", ccgcc.unlic_gross_value_increase "Unlicensed Gross value gained", ccgcc.percentage_unlic_gross_value_increase "Percentage Unlicensed Gross value Change", 
ccvg_1.gross_lic_Dollar_Value as "Licensed Gross Value", ccgcc.lic_gross_value_increase as "Licensed Gross value gained", ccgcc.percentage_lic_gross_value_increase "Percentage Licensed Gross value Change"
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
