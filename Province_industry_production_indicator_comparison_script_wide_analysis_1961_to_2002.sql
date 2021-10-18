-- Industry Production for Provinces wide data analysis of each indicator comparing the licensed and inlicensed industries and the 
-- total value gained in each indicator as well as the percentage of the total value that comes from both licensed and unlicensed industries
-- in each province each year. 

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
-- SPlit domestic production for cultivation and retail and self join 
SELECT ccdp.ref_date, ccdp.dguid,ccdp.geo, ccdp.indicator, ccdp.Cultivation_unlicensed_domestic_prod_Value,
ccdp.Cultivation_unlicen_domestic_growth,ccdp.Cultivation_Unlicen_percentage_growth, 
ccdp.Cultivation_licensed_domestic_prod_Value, ccdp.Cultivation_licensed_domestic_growth, ccdp.Cultivation_Licen_percentage_growth,
rsdp.retail_stores_unlicensed_domestic_prod_Value, rsdp.retail_stores_unlicen_domestic_growth, rsdp.retail_stores_Unlicen_percentage_growth, 
rsdp.retail_stores_licensed_domestic_prod_Value, rsdp.retail_stores_licensed_domestic_growth, rsdp.retail_stores_Licen_percentage_growth,
(ccdp.Cultivation_unlicensed_domestic_prod_Value+ccdp.Cultivation_licensed_domestic_prod_Value+rsdp.retail_stores_unlicensed_domestic_prod_Value+rsdp.retail_stores_licensed_domestic_prod_Value) as Total_Domestic_Production_Value, 
(ccdp.Cultivation_unlicensed_domestic_prod_Value+rsdp.retail_stores_unlicensed_domestic_prod_Value)/(ccdp.Cultivation_unlicensed_domestic_prod_Value+ccdp.Cultivation_licensed_domestic_prod_Value+rsdp.retail_stores_unlicensed_domestic_prod_Value+rsdp.retail_stores_licensed_domestic_prod_Value) as Percentage_unlicenced_Domestic_Production
FROM
(select dpp.ref_date, dpp.dguid,dpp.geo, dpp.indicator,dpp.industry,dpp.unlicensed_domestic_prod_Value as Cultivation_unlicensed_domestic_prod_Value,
dpg.unlicen_domestic_growth as Cultivation_unlicen_domestic_growth,dpg.Unlicen_percentage_growth as Cultivation_Unlicen_percentage_growth, 
dpp.licensed_domestic_prod_Value as Cultivation_licensed_domestic_prod_Value,
dpg.licensed_domestic_growth as Cultivation_licensed_domestic_growth, dpg.Licen_percentage_growth as Cultivation_Licen_percentage_growth
FROM cannabis_c_p.domestic_prod_provinces dpp Left JOIN (SELECT pdp_1.ref_date,pdp_1.dguid ,pdp_1.geo ,pdp_1.indicator , pdp_1.industry ,pdp_1.unlicensed_domestic_prod_Value,
(pdp_2.unlicensed_domestic_prod_Value - pdp_1.unlicensed_domestic_prod_Value) as unlicen_domestic_growth , (pdp_2.unlicensed_domestic_prod_Value - pdp_1.unlicensed_domestic_prod_Value)/pdp_1.unlicensed_domestic_prod_Value as Unlicen_percentage_growth,
pdp_1.licensed_domestic_prod_Value ,(pdp_2.licensed_domestic_prod_Value -pdp_1.licensed_domestic_prod_Value) as licensed_domestic_growth , (pdp_2.licensed_domestic_prod_Value -pdp_1.licensed_domestic_prod_Value)/pdp_1.licensed_domestic_prod_Value  as Licen_percentage_growth
From cannabis_c_p.domestic_prod_provinces pdp_1 JOIN cannabis_c_p.domestic_prod_provinces pdp_2
ON pdp_2.ref_date = pdp_1.ref_date + 1 and pdp_1.industry = pdp_2.industry AND  pdp_2.geo = pdp_1.geo 
) dpg
ON dpp.ref_date = dpg.ref_date AND dpp.industry = dpg.industry AND  dpp.geo = dpg.geo
WHERE dpp.industry = 'Cannabis cultivation industry')ccdp
JOIN
(select dpp.ref_date, dpp.dguid,dpp.geo, dpp.indicator,dpp.industry,
dpp.unlicensed_domestic_prod_Value as retail_stores_unlicensed_domestic_prod_Value, dpg.unlicen_domestic_growth as retail_stores_unlicen_domestic_growth, dpg.Unlicen_percentage_growth as retail_stores_Unlicen_percentage_growth, 
dpp.licensed_domestic_prod_Value as retail_stores_licensed_domestic_prod_Value, dpg.licensed_domestic_growth as retail_stores_licensed_domestic_growth, dpg.Licen_percentage_growth as retail_stores_Licen_percentage_growth
FROM cannabis_c_p.domestic_prod_provinces dpp Left JOIN (SELECT pdp_1.ref_date,pdp_1.dguid ,pdp_1.geo ,pdp_1.indicator , pdp_1.industry ,pdp_1.unlicensed_domestic_prod_Value,
(pdp_2.unlicensed_domestic_prod_Value - pdp_1.unlicensed_domestic_prod_Value) as unlicen_domestic_growth , (pdp_2.unlicensed_domestic_prod_Value - pdp_1.unlicensed_domestic_prod_Value)/pdp_1.unlicensed_domestic_prod_Value as Unlicen_percentage_growth,
pdp_1.licensed_domestic_prod_Value ,(pdp_2.licensed_domestic_prod_Value -pdp_1.licensed_domestic_prod_Value) as licensed_domestic_growth , (pdp_2.licensed_domestic_prod_Value -pdp_1.licensed_domestic_prod_Value)/pdp_1.licensed_domestic_prod_Value  as Licen_percentage_growth
From cannabis_c_p.domestic_prod_provinces pdp_1 JOIN cannabis_c_p.domestic_prod_provinces pdp_2
ON pdp_2.ref_date = pdp_1.ref_date + 1 and pdp_1.industry = pdp_2.industry AND  pdp_2.geo = pdp_1.geo 
) dpg
ON dpp.ref_date = dpg.ref_date AND dpp.industry = dpg.industry AND  dpp.geo = dpg.geo
WHERE dpp.industry = 'Cannabis retail stores' ) rsdp
ON ccdp.ref_date =rsdp.ref_date AND ccdp.indicator = rsdp.indicator AND ccdp.geo = rsdp.geo
ORDER BY 3,1;

-- CREATE VIEW FOR ABOVE QUERY 
DROP view if exists cannabis_c_p.province_domestic_prod;
 CREATE VIEW cannabis_c_p.province_domestic_prod as 
SELECT ccdp.ref_date, ccdp.dguid,ccdp.geo, ccdp.indicator, ccdp.Cultivation_unlicensed_domestic_prod_Value,
ccdp.Cultivation_unlicen_domestic_growth,ccdp.Cultivation_Unlicen_percentage_growth, 
ccdp.Cultivation_licensed_domestic_prod_Value, ccdp.Cultivation_licensed_domestic_growth, ccdp.Cultivation_Licen_percentage_growth,
rsdp.retail_stores_unlicensed_domestic_prod_Value, rsdp.retail_stores_unlicen_domestic_growth, rsdp.retail_stores_Unlicen_percentage_growth, 
rsdp.retail_stores_licensed_domestic_prod_Value, rsdp.retail_stores_licensed_domestic_growth, rsdp.retail_stores_Licen_percentage_growth,
(ccdp.Cultivation_unlicensed_domestic_prod_Value+ccdp.Cultivation_licensed_domestic_prod_Value+rsdp.retail_stores_unlicensed_domestic_prod_Value+rsdp.retail_stores_licensed_domestic_prod_Value) as Total_Domestic_Production_Value, 
(ccdp.Cultivation_unlicensed_domestic_prod_Value+rsdp.retail_stores_unlicensed_domestic_prod_Value)/(ccdp.Cultivation_unlicensed_domestic_prod_Value+ccdp.Cultivation_licensed_domestic_prod_Value+rsdp.retail_stores_unlicensed_domestic_prod_Value+rsdp.retail_stores_licensed_domestic_prod_Value) as Percentage_unlicenced_Domestic_Production
FROM
(select dpp.ref_date, dpp.dguid,dpp.geo, dpp.indicator,dpp.industry,dpp.unlicensed_domestic_prod_Value as Cultivation_unlicensed_domestic_prod_Value,
dpg.unlicen_domestic_growth as Cultivation_unlicen_domestic_growth,dpg.Unlicen_percentage_growth as Cultivation_Unlicen_percentage_growth, 
dpp.licensed_domestic_prod_Value as Cultivation_licensed_domestic_prod_Value,
dpg.licensed_domestic_growth as Cultivation_licensed_domestic_growth, dpg.Licen_percentage_growth as Cultivation_Licen_percentage_growth
FROM cannabis_c_p.domestic_prod_provinces dpp Left JOIN (SELECT pdp_1.ref_date,pdp_1.dguid ,pdp_1.geo ,pdp_1.indicator , pdp_1.industry ,pdp_1.unlicensed_domestic_prod_Value,
(pdp_2.unlicensed_domestic_prod_Value - pdp_1.unlicensed_domestic_prod_Value) as unlicen_domestic_growth , (pdp_2.unlicensed_domestic_prod_Value - pdp_1.unlicensed_domestic_prod_Value)/pdp_1.unlicensed_domestic_prod_Value as Unlicen_percentage_growth,
pdp_1.licensed_domestic_prod_Value ,(pdp_2.licensed_domestic_prod_Value -pdp_1.licensed_domestic_prod_Value) as licensed_domestic_growth , (pdp_2.licensed_domestic_prod_Value -pdp_1.licensed_domestic_prod_Value)/pdp_1.licensed_domestic_prod_Value  as Licen_percentage_growth
From cannabis_c_p.domestic_prod_provinces pdp_1 JOIN cannabis_c_p.domestic_prod_provinces pdp_2
ON pdp_2.ref_date = pdp_1.ref_date + 1 and pdp_1.industry = pdp_2.industry AND  pdp_2.geo = pdp_1.geo 
) dpg
ON dpp.ref_date = dpg.ref_date AND dpp.industry = dpg.industry AND  dpp.geo = dpg.geo
WHERE dpp.industry = 'Cannabis cultivation industry')ccdp
JOIN
(select dpp.ref_date, dpp.dguid,dpp.geo, dpp.indicator,dpp.industry,
dpp.unlicensed_domestic_prod_Value as retail_stores_unlicensed_domestic_prod_Value, dpg.unlicen_domestic_growth as retail_stores_unlicen_domestic_growth, dpg.Unlicen_percentage_growth as retail_stores_Unlicen_percentage_growth, 
dpp.licensed_domestic_prod_Value as retail_stores_licensed_domestic_prod_Value, dpg.licensed_domestic_growth as retail_stores_licensed_domestic_growth, dpg.Licen_percentage_growth as retail_stores_Licen_percentage_growth
FROM cannabis_c_p.domestic_prod_provinces dpp Left JOIN (SELECT pdp_1.ref_date,pdp_1.dguid ,pdp_1.geo ,pdp_1.indicator , pdp_1.industry ,pdp_1.unlicensed_domestic_prod_Value,
(pdp_2.unlicensed_domestic_prod_Value - pdp_1.unlicensed_domestic_prod_Value) as unlicen_domestic_growth , (pdp_2.unlicensed_domestic_prod_Value - pdp_1.unlicensed_domestic_prod_Value)/pdp_1.unlicensed_domestic_prod_Value as Unlicen_percentage_growth,
pdp_1.licensed_domestic_prod_Value ,(pdp_2.licensed_domestic_prod_Value -pdp_1.licensed_domestic_prod_Value) as licensed_domestic_growth , (pdp_2.licensed_domestic_prod_Value -pdp_1.licensed_domestic_prod_Value)/pdp_1.licensed_domestic_prod_Value  as Licen_percentage_growth
From cannabis_c_p.domestic_prod_provinces pdp_1 JOIN cannabis_c_p.domestic_prod_provinces pdp_2
ON pdp_2.ref_date = pdp_1.ref_date + 1 and pdp_1.industry = pdp_2.industry AND  pdp_2.geo = pdp_1.geo 
) dpg
ON dpp.ref_date = dpg.ref_date AND dpp.industry = dpg.industry AND  dpp.geo = dpg.geo
WHERE dpp.industry = 'Cannabis retail stores' ) rsdp
ON ccdp.ref_date =rsdp.ref_date AND ccdp.indicator = rsdp.indicator AND ccdp.geo = rsdp.geo
ORDER BY 3,1;

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

-- SELF JOIN ABOVE QUERY FOR INDICATORS
SELECT cipd.ref_date,cipd.geo,cipd.indicator,
cipd.unlic_dom_use_value as Unlic_Cultivation_Industry_Dollar_Value, 
cipd.unlic_dom_value_growth as Unlic_Cultivation_Industry_Value_Growth,
cipd.percent_growth_unlic_dom_value as Unlic_Cultivation_Industry_Percent_Growth, 
cipd.lic_dom_use_value as Lic_Cultivation_industry_Dollar_Value, 
cipd.lic_dom_value_growth as Lic_Cultivation_industry_Value_Growth,
cipd.percent_growth_lic_dom_value as Lic_Cultivation_Industry_Percent_Growth,
ridp.unlic_dom_use_value as Unlic_Retail_Store_Dollar_Value, 
ridp.unlic_dom_value_growth as Unlic_Retail_Store_Value_Growth,
ridp.percent_growth_unlic_dom_value as Unlic_Retail_Store_Percent_Growth, 
ridp.lic_dom_use_value as Lic_Retail_Store_Dollar_Value, 
ridp.lic_dom_value_growth as Lic_Retail_Store_Value_Growth,
ridp.percent_growth_lic_dom_value as Lic_Retail_Store_Percent_Growth,
(cipd.unlic_dom_use_value + cipd.lic_dom_use_value + ridp.unlic_dom_use_value + ridp.lic_dom_use_value) as Total_Production_Value,
(cipd.unlic_dom_use_value + ridp.unlic_dom_use_value)/(cipd.unlic_dom_use_value + cipd.lic_dom_use_value + ridp.unlic_dom_use_value + ridp.lic_dom_use_value) *100 as Percent_From_Unlicensed_Industry,
(cipd.lic_dom_use_value + ridp.lic_dom_use_value)/(cipd.unlic_dom_use_value + cipd.lic_dom_use_value + ridp.unlic_dom_use_value + ridp.lic_dom_use_value)*100 as Percent_From_Licensed_Industry
FROM
(SELECT dpp.ref_date,dpp.geo,dpp.indicator,dpp.industry,dpp.unlic_dom_use_value, dppg.unlic_dom_value_growth,dppg.percent_growth_unlic_dom_value, dpp.lic_dom_use_value, dppg.lic_dom_value_growth,dppg.percent_growth_lic_dom_value
FROM cannabis_c_p.dom_prod_province dpp LEFT JOIN (SELECT dpp1.ref_date , dpp1.geo , dpp1.indicator , dpp1.industry , 
 (dpp2.unlic_dom_use_value - dpp1.unlic_dom_use_value)as "unlic_dom_value_growth", (dpp2.unlic_dom_use_value - dpp1.unlic_dom_use_value)/dpp1.unlic_dom_use_value  as "percent_growth_unlic_dom_value"
 ,(dpp2.lic_dom_use_value-dpp1.lic_dom_use_value) as "lic_dom_value_growth",(dpp2.lic_dom_use_value - dpp1.lic_dom_use_value)/dpp1.unlic_dom_use_value  as "percent_growth_lic_dom_value"
FROM cannabis_c_p.dom_prod_province dpp1 JOIN cannabis_c_p.dom_prod_province dpp2
ON dpp2.ref_date = dpp1.ref_date +1 AND dpp1.industry=dpp2.industry  AND dpp2.geo = dpp1.geo) dppg
ON dpp.ref_date = dppg.ref_date AND dpp.geo = dppg.geo AND dppg.industry = dpp.industry
WHERE dpp.industry = 'Cannabis cultivation industry') cipd
JOIN
(SELECT dpp.ref_date,dpp.geo,dpp.indicator,dpp.industry,dpp.unlic_dom_use_value, dppg.unlic_dom_value_growth,dppg.percent_growth_unlic_dom_value, dpp.lic_dom_use_value, dppg.lic_dom_value_growth,dppg.percent_growth_lic_dom_value
FROM cannabis_c_p.dom_prod_province dpp LEFT JOIN (SELECT dpp1.ref_date , dpp1.geo , dpp1.indicator , dpp1.industry , 
 (dpp2.unlic_dom_use_value - dpp1.unlic_dom_use_value)as "unlic_dom_value_growth", (dpp2.unlic_dom_use_value - dpp1.unlic_dom_use_value)/dpp1.unlic_dom_use_value  as "percent_growth_unlic_dom_value"
 ,(dpp2.lic_dom_use_value-dpp1.lic_dom_use_value) as "lic_dom_value_growth",(dpp2.lic_dom_use_value - dpp1.lic_dom_use_value)/dpp1.unlic_dom_use_value  as "percent_growth_lic_dom_value"
FROM cannabis_c_p.dom_prod_province dpp1 JOIN cannabis_c_p.dom_prod_province dpp2
ON dpp2.ref_date = dpp1.ref_date +1 AND dpp1.industry=dpp2.industry  AND dpp2.geo = dpp1.geo) dppg
ON dpp.ref_date = dppg.ref_date AND dpp.geo = dppg.geo AND dppg.industry = dpp.industry
WHERE dpp.industry = 'Cannabis retail stores')ridp
 ON  ridp.ref_date=cipd.ref_date AND cipd.geo = ridp.geo AND cipd.indicator = ridp.indicator
ORDER BY 2,1;

-- make view for above query
Drop view if exists cannabis_c_p.province_own_use;
CREATE VIEW  cannabis_c_p.province_own_use as
SELECT cipd.ref_date,cipd.geo,cipd.indicator,
cipd.unlic_dom_use_value as Unlic_Cultivation_Industry_Dollar_Value, 
cipd.unlic_dom_value_growth as Unlic_Cultivation_Industry_Value_Growth,
cipd.percent_growth_unlic_dom_value as Unlic_Cultivation_Industry_Percent_Growth, 
cipd.lic_dom_use_value as Lic_Cultivation_industry_Dollar_Value, 
cipd.lic_dom_value_growth as Lic_Cultivation_industry_Value_Growth,
cipd.percent_growth_lic_dom_value as Lic_Cultivation_Industry_Percent_Growth,
ridp.unlic_dom_use_value as Unlic_Retail_Store_Dollar_Value, 
ridp.unlic_dom_value_growth as Unlic_Retail_Store_Value_Growth,
ridp.percent_growth_unlic_dom_value as Unlic_Retail_Store_Percent_Growth, 
ridp.lic_dom_use_value as Lic_Retail_Store_Dollar_Value, 
ridp.lic_dom_value_growth as Lic_Retail_Store_Value_Growth,
ridp.percent_growth_lic_dom_value as Lic_Retail_Store_Percent_Growth,
(cipd.unlic_dom_use_value + cipd.lic_dom_use_value + ridp.unlic_dom_use_value + ridp.lic_dom_use_value) as Total_Production_Value,
(cipd.unlic_dom_use_value + ridp.unlic_dom_use_value)/(cipd.unlic_dom_use_value + cipd.lic_dom_use_value + ridp.unlic_dom_use_value + ridp.lic_dom_use_value) *100 as Percent_From_Unlicensed_Industry,
(cipd.lic_dom_use_value + ridp.lic_dom_use_value)/(cipd.unlic_dom_use_value + cipd.lic_dom_use_value + ridp.unlic_dom_use_value + ridp.lic_dom_use_value)*100 as Percent_From_Licensed_Industry
FROM
(SELECT dpp.ref_date,dpp.geo,dpp.indicator,dpp.industry,dpp.unlic_dom_use_value, dppg.unlic_dom_value_growth,dppg.percent_growth_unlic_dom_value, dpp.lic_dom_use_value, dppg.lic_dom_value_growth,dppg.percent_growth_lic_dom_value
FROM cannabis_c_p.dom_prod_province dpp LEFT JOIN (SELECT dpp1.ref_date , dpp1.geo , dpp1.indicator , dpp1.industry , 
 (dpp2.unlic_dom_use_value - dpp1.unlic_dom_use_value)as "unlic_dom_value_growth", (dpp2.unlic_dom_use_value - dpp1.unlic_dom_use_value)/dpp1.unlic_dom_use_value  as "percent_growth_unlic_dom_value"
 ,(dpp2.lic_dom_use_value-dpp1.lic_dom_use_value) as "lic_dom_value_growth",(dpp2.lic_dom_use_value - dpp1.lic_dom_use_value)/dpp1.unlic_dom_use_value  as "percent_growth_lic_dom_value"
FROM cannabis_c_p.dom_prod_province dpp1 JOIN cannabis_c_p.dom_prod_province dpp2
ON dpp2.ref_date = dpp1.ref_date +1 AND dpp1.industry=dpp2.industry  AND dpp2.geo = dpp1.geo) dppg
ON dpp.ref_date = dppg.ref_date AND dpp.geo = dppg.geo AND dppg.industry = dpp.industry
WHERE dpp.industry = 'Cannabis cultivation industry') cipd
JOIN
(SELECT dpp.ref_date,dpp.geo,dpp.indicator,dpp.industry,dpp.unlic_dom_use_value, dppg.unlic_dom_value_growth,dppg.percent_growth_unlic_dom_value, dpp.lic_dom_use_value, dppg.lic_dom_value_growth,dppg.percent_growth_lic_dom_value
FROM cannabis_c_p.dom_prod_province dpp LEFT JOIN (SELECT dpp1.ref_date , dpp1.geo , dpp1.indicator , dpp1.industry , 
 (dpp2.unlic_dom_use_value - dpp1.unlic_dom_use_value)as "unlic_dom_value_growth", (dpp2.unlic_dom_use_value - dpp1.unlic_dom_use_value)/dpp1.unlic_dom_use_value  as "percent_growth_unlic_dom_value"
 ,(dpp2.lic_dom_use_value-dpp1.lic_dom_use_value) as "lic_dom_value_growth",(dpp2.lic_dom_use_value - dpp1.lic_dom_use_value)/dpp1.unlic_dom_use_value  as "percent_growth_lic_dom_value"
FROM cannabis_c_p.dom_prod_province dpp1 JOIN cannabis_c_p.dom_prod_province dpp2
ON dpp2.ref_date = dpp1.ref_date +1 AND dpp1.industry=dpp2.industry  AND dpp2.geo = dpp1.geo) dppg
ON dpp.ref_date = dppg.ref_date AND dpp.geo = dppg.geo AND dppg.industry = dpp.industry
WHERE dpp.industry = 'Cannabis retail stores')ridp
 ON  ridp.ref_date=cipd.ref_date AND cipd.geo = ridp.geo AND cipd.indicator = ridp.indicator
ORDER BY 2,1;



##Intermediate consumption Value in Provinces of Canada Yearly##

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

SELECT cvic.ref_date,  cvic.geo,cvic.dguid,cvic.indicator,
cvic.Unlic_inter_Dollar_Value as Unlic_Cultivation_Industry_Dollar_Value, 
cvic.year_unlisc_growth as Unlic_Cultivation_Industry_Value_Growth, 
cvic.year_unlisc_value_percent_growth as Unlic_Cultivation_Industry_Percent_Growth,
cvic.lic_inter_Dollar_Value as Lic_Cultivation_industry_Dollar_Value, 
cvic.year_lisc_growth as Lic_Cultivation_industry_Value_Growth, 
cvic.year_lisc_value_percent_growth as Lic_Cultivation_Industry_Percent_Growth,
cric.Unlic_inter_Dollar_Value as Unlic_Retail_Store_Dollar_Value , 
cric.year_unlisc_growth as Unlic_Retail_Store_Value_Growth, 
cric.year_unlisc_value_percent_growth as Unlic_Retail_Store_Percent_Growth,
cric.lic_inter_Dollar_Value as Lic_Retail_Store_Dollar_Value, cric.year_lisc_growth as Lic_Retail_Store_Value_Growth,
 cric.year_lisc_value_percent_growth as Lic_Retail_Store_Percent_Growth,
(cvic.Unlic_inter_Dollar_Value + cvic.lic_inter_Dollar_Value+cric.Unlic_inter_Dollar_Value +cric.lic_inter_Dollar_Value) as Total_Production_Value,
(cvic.Unlic_inter_Dollar_Value +cric.Unlic_inter_Dollar_Value)/(cvic.Unlic_inter_Dollar_Value + cvic.lic_inter_Dollar_Value+cric.Unlic_inter_Dollar_Value +cric.lic_inter_Dollar_Value) *100 as Percent_From_Unlicensed_Industry,
(cvic.lic_inter_Dollar_Value +cric.lic_inter_Dollar_Value)/(cvic.Unlic_inter_Dollar_Value + cvic.lic_inter_Dollar_Value+cric.Unlic_inter_Dollar_Value +cric.lic_inter_Dollar_Value) *100 as Percent_From_Licensed_Industry
FROM
(SELECT pic_1.ref_date,  pic_1.geo,pic_1.dguid,pic_1.indicator,pic_1.industry,
pic_1.Unlic_inter_Dollar_Value , picg.year_unlisc_growth, picg.year_unlisc_value_percent_growth,
pic_1.lic_inter_Dollar_Value, picg.year_lisc_growth, picg.year_lisc_value_percent_growth
FROM cannabis_c_p.province_int_consump pic_1 LEFT JOIN 
(SELECT pic.ref_date, pic.geo ,pic.dguid, pic.indicator , pic.industry , pic.Unlic_inter_Dollar_Value , 
(pic2.Unlic_inter_Dollar_Value -pic.Unlic_inter_Dollar_Value) as year_unlisc_growth,(pic2.Unlic_inter_Dollar_Value -pic.Unlic_inter_Dollar_Value)/pic.Unlic_inter_Dollar_Value as year_unlisc_value_percent_growth,pic.lic_inter_Dollar_Value,
 (pic2.lic_inter_Dollar_Value - pic.lic_inter_Dollar_Value) year_lisc_growth ,(pic2.lic_inter_Dollar_Value -pic.lic_inter_Dollar_Value)/pic.lic_inter_Dollar_Value as year_lisc_value_percent_growth
FROM cannabis_c_p.province_int_consump pic JOIN cannabis_c_p.province_int_consump pic2 
ON pic2.ref_date = pic.ref_date + 1  AND pic.geo = pic2.geo AND pic.dguid=pic2.dguid AND pic.industry = pic2.industry) picg 
ON  pic_1.ref_date=picg.ref_date AND pic_1.geo = picg.geo AND pic_1.dguid=picg.dguid AND pic_1.industry = picg.industry
WHERE pic_1.industry = 'Cannabis cultivation industry') cvic
JOIN
(SELECT pic_1.ref_date,  pic_1.geo,pic_1.dguid,pic_1.indicator,pic_1.industry,
pic_1.Unlic_inter_Dollar_Value , picg.year_unlisc_growth, picg.year_unlisc_value_percent_growth,
pic_1.lic_inter_Dollar_Value, picg.year_lisc_growth, picg.year_lisc_value_percent_growth
FROM cannabis_c_p.province_int_consump pic_1 LEFT JOIN 
(SELECT pic.ref_date, pic.geo ,pic.dguid, pic.indicator , pic.industry , pic.Unlic_inter_Dollar_Value , 
(pic2.Unlic_inter_Dollar_Value -pic.Unlic_inter_Dollar_Value) as year_unlisc_growth,(pic2.Unlic_inter_Dollar_Value -pic.Unlic_inter_Dollar_Value)/pic.Unlic_inter_Dollar_Value as year_unlisc_value_percent_growth,pic.lic_inter_Dollar_Value,
 (pic2.lic_inter_Dollar_Value - pic.lic_inter_Dollar_Value) year_lisc_growth ,(pic2.lic_inter_Dollar_Value -pic.lic_inter_Dollar_Value)/pic.lic_inter_Dollar_Value as year_lisc_value_percent_growth
FROM cannabis_c_p.province_int_consump pic JOIN cannabis_c_p.province_int_consump pic2 
ON pic2.ref_date = pic.ref_date + 1  AND pic.geo = pic2.geo AND pic.dguid=pic2.dguid AND pic.industry = pic2.industry) picg 
ON  pic_1.ref_date=picg.ref_date AND pic_1.geo = picg.geo AND pic_1.dguid=picg.dguid AND pic_1.industry = picg.industry
WHERE pic_1.industry = 'Cannabis retail stores') cric
ON cvic.ref_date = cric.ref_date AND cvic.geo = cric.geo  AND cvic.indicator = cric.indicator
ORDER BY 2,1;

-- CREATE VIEW FOR ABOVE QUERY
DROP VIEW IF EXISTS cannabis_c_p.province_interm_consump; 
CREATE VIEW cannabis_c_p.province_interm_consump  AS 
SELECT cvic.ref_date,  cvic.geo,cvic.dguid,cvic.indicator,
cvic.Unlic_inter_Dollar_Value as Unlic_Cultivation_Industry_Dollar_Value, 
cvic.year_unlisc_growth as Unlic_Cultivation_Industry_Value_Growth, 
cvic.year_unlisc_value_percent_growth as Unlic_Cultivation_Industry_Percent_Growth,
cvic.lic_inter_Dollar_Value as Lic_Cultivation_industry_Dollar_Value, 
cvic.year_lisc_growth as Lic_Cultivation_industry_Value_Growth, 
cvic.year_lisc_value_percent_growth as Lic_Cultivation_Industry_Percent_Growth,
cric.Unlic_inter_Dollar_Value as Unlic_Retail_Store_Dollar_Value , 
cric.year_unlisc_growth as Unlic_Retail_Store_Value_Growth, 
cric.year_unlisc_value_percent_growth as Unlic_Retail_Store_Percent_Growth,
cric.lic_inter_Dollar_Value as Lic_Retail_Store_Dollar_Value, cric.year_lisc_growth as Lic_Retail_Store_Value_Growth,
 cric.year_lisc_value_percent_growth as Lic_Retail_Store_Percent_Growth,
(cvic.Unlic_inter_Dollar_Value + cvic.lic_inter_Dollar_Value+cric.Unlic_inter_Dollar_Value +cric.lic_inter_Dollar_Value) as Total_Production_Value,
(cvic.Unlic_inter_Dollar_Value +cric.Unlic_inter_Dollar_Value)/(cvic.Unlic_inter_Dollar_Value + cvic.lic_inter_Dollar_Value+cric.Unlic_inter_Dollar_Value +cric.lic_inter_Dollar_Value) *100 as Percent_From_Unlicensed_Industry,
(cvic.lic_inter_Dollar_Value +cric.lic_inter_Dollar_Value)/(cvic.Unlic_inter_Dollar_Value + cvic.lic_inter_Dollar_Value+cric.Unlic_inter_Dollar_Value +cric.lic_inter_Dollar_Value) *100 as Percent_From_Licensed_Industry
FROM
(SELECT pic_1.ref_date,  pic_1.geo,pic_1.dguid,pic_1.indicator,pic_1.industry,
pic_1.Unlic_inter_Dollar_Value , picg.year_unlisc_growth, picg.year_unlisc_value_percent_growth,
pic_1.lic_inter_Dollar_Value, picg.year_lisc_growth, picg.year_lisc_value_percent_growth
FROM cannabis_c_p.province_int_consump pic_1 LEFT JOIN 
(SELECT pic.ref_date, pic.geo ,pic.dguid, pic.indicator , pic.industry , pic.Unlic_inter_Dollar_Value , 
(pic2.Unlic_inter_Dollar_Value -pic.Unlic_inter_Dollar_Value) as year_unlisc_growth,(pic2.Unlic_inter_Dollar_Value -pic.Unlic_inter_Dollar_Value)/pic.Unlic_inter_Dollar_Value as year_unlisc_value_percent_growth,pic.lic_inter_Dollar_Value,
 (pic2.lic_inter_Dollar_Value - pic.lic_inter_Dollar_Value) year_lisc_growth ,(pic2.lic_inter_Dollar_Value -pic.lic_inter_Dollar_Value)/pic.lic_inter_Dollar_Value as year_lisc_value_percent_growth
FROM cannabis_c_p.province_int_consump pic JOIN cannabis_c_p.province_int_consump pic2 
ON pic2.ref_date = pic.ref_date + 1  AND pic.geo = pic2.geo AND pic.dguid=pic2.dguid AND pic.industry = pic2.industry) picg 
ON  pic_1.ref_date=picg.ref_date AND pic_1.geo = picg.geo AND pic_1.dguid=picg.dguid AND pic_1.industry = picg.industry
WHERE pic_1.industry = 'Cannabis cultivation industry') cvic
JOIN
(SELECT pic_1.ref_date,  pic_1.geo,pic_1.dguid,pic_1.indicator,pic_1.industry,
pic_1.Unlic_inter_Dollar_Value , picg.year_unlisc_growth, picg.year_unlisc_value_percent_growth,
pic_1.lic_inter_Dollar_Value, picg.year_lisc_growth, picg.year_lisc_value_percent_growth
FROM cannabis_c_p.province_int_consump pic_1 LEFT JOIN 
(SELECT pic.ref_date, pic.geo ,pic.dguid, pic.indicator , pic.industry , pic.Unlic_inter_Dollar_Value , 
(pic2.Unlic_inter_Dollar_Value -pic.Unlic_inter_Dollar_Value) as year_unlisc_growth,(pic2.Unlic_inter_Dollar_Value -pic.Unlic_inter_Dollar_Value)/pic.Unlic_inter_Dollar_Value as year_unlisc_value_percent_growth,pic.lic_inter_Dollar_Value,
 (pic2.lic_inter_Dollar_Value - pic.lic_inter_Dollar_Value) year_lisc_growth ,(pic2.lic_inter_Dollar_Value -pic.lic_inter_Dollar_Value)/pic.lic_inter_Dollar_Value as year_lisc_value_percent_growth
FROM cannabis_c_p.province_int_consump pic JOIN cannabis_c_p.province_int_consump pic2 
ON pic2.ref_date = pic.ref_date + 1  AND pic.geo = pic2.geo AND pic.dguid=pic2.dguid AND pic.industry = pic2.industry) picg 
ON  pic_1.ref_date=picg.ref_date AND pic_1.geo = picg.geo AND pic_1.dguid=picg.dguid AND pic_1.industry = picg.industry
WHERE pic_1.industry = 'Cannabis retail stores') cric
ON cvic.ref_date = cric.ref_date AND cvic.geo = cric.geo  AND cvic.indicator = cric.indicator
ORDER BY 2,1;

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
-- Join gross value and calculations
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

-- Self join above query and seperate gross value by undustries
SELECT  ccgv.ref_date,  ccgv.geo, ccgv.dguid,ccgv.indicator, 
ccgv.gross_unlic_Dollar_Value as Unlic_Cultivation_Industry_Dollar_Value,  
ccgv.unlic_value_growth_in_year as Unlic_Cultivation_Industry_Value_Growth , 
ccgv.percent_unlic_value_growth_in_year as Unlic_Cultivation_Industry_Percent_Growth,
ccgv.gross_lic_Dollar_Value as Lic_Cultivation_industry_Dollar_Value, 
ccgv.lic_value_growth_in_year as Lic_Cultivation_industry_Value_Growth, 
ccgv.percent_lic_value_growth_in_year as Lic_Cultivation_Industry_Percent_Growth,
rsgv.gross_unlic_Dollar_Value as Unlic_Retail_Store_Dollar_Value,  
rsgv.unlic_value_growth_in_year as Unlic_Retail_Store_Value_Growth , 
rsgv.percent_unlic_value_growth_in_year as Unlic_Retail_Store_Percent_Growth,
rsgv.gross_lic_Dollar_Value as Lic_Retail_Store_Dollar_Value, 
rsgv.lic_value_growth_in_year as Lic_Retail_Store_Value_Growth, 
rsgv.percent_lic_value_growth_in_year as Lic_Retail_Store_Percent_Growth,
(ccgv.gross_unlic_Dollar_Value+ccgv.gross_lic_Dollar_Value +rsgv.gross_unlic_Dollar_Value +rsgv.gross_lic_Dollar_Value) as Total_Gross_Value,
(ccgv.gross_unlic_Dollar_Value+rsgv.gross_unlic_Dollar_Value)/(ccgv.gross_unlic_Dollar_Value+ccgv.gross_lic_Dollar_Value +rsgv.gross_unlic_Dollar_Value +rsgv.gross_lic_Dollar_Value) *100 as Percent_From_Unlic_Gross_Value,
(ccgv.gross_lic_Dollar_Value +rsgv.gross_lic_Dollar_Value)/(ccgv.gross_unlic_Dollar_Value+ccgv.gross_lic_Dollar_Value +rsgv.gross_unlic_Dollar_Value +rsgv.gross_lic_Dollar_Value) *100 as Percent_From_Lic_Gross_Value
FROM
(SELECT  gvar.ref_date,  gvar.geo, gvar.dguid, gvar.industry,gvar.indicator, gvar.gross_unlic_Dollar_Value,  ggvap.unlic_value_growth_in_year , ggvap.percent_unlic_value_growth_in_year,
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
WHERE gvar.industry = 'Cannabis cultivation industry' )ccgv
JOIN 
(SELECT  gvar.ref_date,  gvar.geo, gvar.dguid, gvar.industry,gvar.indicator, gvar.gross_unlic_Dollar_Value,  ggvap.unlic_value_growth_in_year , ggvap.percent_unlic_value_growth_in_year,
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
WHERE gvar.industry != 'Cannabis cultivation industry' ) rsgv
ON ccgv.ref_date = rsgv.ref_date AND  ccgv.indicator =  rsgv.indicator AND ccgv.geo = rsgv.geo
ORDER BY 2,1;


-- CREATE VIEW WITH ABOVE QUERY
DROP VIEW IF EXISTS cannabis_c_p.province_gross_val;
CREATE VIEW  cannabis_c_p.province_gross_val as 
SELECT  ccgv.ref_date,  ccgv.geo, ccgv.dguid,ccgv.indicator, 
ccgv.gross_unlic_Dollar_Value as Unlic_Cultivation_Industry_Dollar_Value,  
ccgv.unlic_value_growth_in_year as Unlic_Cultivation_Industry_Value_Growth , 
ccgv.percent_unlic_value_growth_in_year as Unlic_Cultivation_Industry_Percent_Growth,
ccgv.gross_lic_Dollar_Value as Lic_Cultivation_industry_Dollar_Value, 
ccgv.lic_value_growth_in_year as Lic_Cultivation_industry_Value_Growth, 
ccgv.percent_lic_value_growth_in_year as Lic_Cultivation_Industry_Percent_Growth,
rsgv.gross_unlic_Dollar_Value as Unlic_Retail_Store_Dollar_Value,  
rsgv.unlic_value_growth_in_year as Unlic_Retail_Store_Value_Growth , 
rsgv.percent_unlic_value_growth_in_year as Unlic_Retail_Store_Percent_Growth,
rsgv.gross_lic_Dollar_Value as Lic_Retail_Store_Dollar_Value, 
rsgv.lic_value_growth_in_year as Lic_Retail_Store_Value_Growth, 
rsgv.percent_lic_value_growth_in_year as Lic_Retail_Store_Percent_Growth,
(ccgv.gross_unlic_Dollar_Value+ccgv.gross_lic_Dollar_Value +rsgv.gross_unlic_Dollar_Value +rsgv.gross_lic_Dollar_Value) as Total_Gross_Value,
(ccgv.gross_unlic_Dollar_Value+rsgv.gross_unlic_Dollar_Value)/(ccgv.gross_unlic_Dollar_Value+ccgv.gross_lic_Dollar_Value +rsgv.gross_unlic_Dollar_Value +rsgv.gross_lic_Dollar_Value) *100 as Percent_From_Unlic_Gross_Value,
(ccgv.gross_lic_Dollar_Value +rsgv.gross_lic_Dollar_Value)/(ccgv.gross_unlic_Dollar_Value+ccgv.gross_lic_Dollar_Value +rsgv.gross_unlic_Dollar_Value +rsgv.gross_lic_Dollar_Value) *100 as Percent_From_Lic_Gross_Value
FROM
(SELECT  gvar.ref_date,  gvar.geo, gvar.dguid, gvar.industry,gvar.indicator, gvar.gross_unlic_Dollar_Value,  ggvap.unlic_value_growth_in_year , ggvap.percent_unlic_value_growth_in_year,
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
WHERE gvar.industry = 'Cannabis cultivation industry' )ccgv
JOIN 
(SELECT  gvar.ref_date,  gvar.geo, gvar.dguid, gvar.industry,gvar.indicator, gvar.gross_unlic_Dollar_Value,  ggvap.unlic_value_growth_in_year , ggvap.percent_unlic_value_growth_in_year,
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
WHERE gvar.industry != 'Cannabis cultivation industry' ) rsgv
ON ccgv.ref_date = rsgv.ref_date AND  ccgv.indicator =  rsgv.indicator AND ccgv.geo = rsgv.geo
ORDER BY 2,1;

-- Province domestic market value

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
AND licensed.geo <> "Canada"
AND unlicensed.geo <> "Canada"
ORDER BY  3,4,2,1;

Drop Table if exists cannabis_c_p.dom_market_province;
CREATE TABLE cannabis_c_p.dom_market_province 
(ref_date int,geo varchar(100), dguid varchar(100), industry varchar(100), indicator varchar(100), Dom_market_prod_Unlic_Dollar_Value int,
Dom_market_prod_lic_Dollar_Value int);

INSERT INTO cannabis_c_p.dom_market_province 
SELECT unlicensed.ref_date, unlicensed.geo, unlicensed.dguid, unlicensed.industry, unlicensed.indicator, 
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
AND licensed.geo <> "Canada"
AND unlicensed.geo <> "Canada"
ORDER BY  3,4,2,1;

SELECT * FROM cannabis_c_p.dom_market_province;

-- Join to calculate yearly increase
SELECT dmp1.ref_date, dmp1.geo, dmp1.industry,dmp1.indicator, dmp1.Dom_market_prod_Unlic_Dollar_Value, 
dmp2.Dom_market_prod_Unlic_Dollar_Value - dmp1.Dom_market_prod_Unlic_Dollar_Value as unlic_value_growth_in_year, 
(dmp2.Dom_market_prod_Unlic_Dollar_Value -dmp1.Dom_market_prod_Unlic_Dollar_Value)/dmp1.Dom_market_prod_Unlic_Dollar_Value as percent_unlic_value_growth_in_year,
dmp1.Dom_market_prod_lic_Dollar_Value, dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value as lic_value_growth_in_year, 
(dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value)/dmp1.Dom_market_prod_lic_Dollar_Value as percent_lic_value_growth_in_year
FROM cannabis_c_p.dom_market_province dmp1 
JOIN
cannabis_c_p.dom_market_province dmp2
ON dmp2.ref_date = dmp1.ref_date + 1 AND dmp1.industry = dmp2.industry AND dmp1.geo=dmp2.geo
ORDER BY 3,2,1;


-- Self Left join to represent full data 

SELECT dmp.ref_date, dmp.geo, dmp.dguid, dmp.indicator, dmp.industry, 
 dmp.Dom_market_prod_Unlic_Dollar_Value,  dmp.Dom_market_prod_lic_Dollar_Value,
 dmpc.ref_date, dmpc.geo, dmpc.industry,dmpc.indicator, dmpc.Dom_market_prod_Unlic_Dollar_Value, 
dmpc.unlic_value_growth_in_year, dmpc.percent_unlic_value_growth_in_year,
dmpc.Dom_market_prod_lic_Dollar_Value, dmpc.lic_value_growth_in_year, dmpc.percent_lic_value_growth_in_year
FROM
cannabis_c_p.dom_market_province  dmp 
LEFT JOIN
(SELECT dmp1.ref_date, dmp1.geo, dmp1.industry,dmp1.indicator, dmp1.Dom_market_prod_Unlic_Dollar_Value, 
dmp2.Dom_market_prod_Unlic_Dollar_Value - dmp1.Dom_market_prod_Unlic_Dollar_Value as unlic_value_growth_in_year, 
(dmp2.Dom_market_prod_Unlic_Dollar_Value -dmp1.Dom_market_prod_Unlic_Dollar_Value)/dmp1.Dom_market_prod_Unlic_Dollar_Value as percent_unlic_value_growth_in_year,
dmp1.Dom_market_prod_lic_Dollar_Value, dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value as lic_value_growth_in_year, 
(dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value)/dmp1.Dom_market_prod_lic_Dollar_Value as percent_lic_value_growth_in_year
FROM cannabis_c_p.dom_market_province dmp1 
JOIN
cannabis_c_p.dom_market_province dmp2
ON dmp2.ref_date = dmp1.ref_date + 1 AND dmp1.industry = dmp2.industry AND dmp1.geo=dmp2.geo
)dmpc
ON
dmp.ref_date = dmpc.ref_date AND dmp.geo = dmpc.geo AND dmp.industry = dmpc.industry
ORDER BY 5,2,1;

-- SELF JOIN AND seperate by industry

SELECT cidmp.ref_date, cidmp.geo, cidmp.dguid, cidmp.indicator, cidmp.industry, 
cidmp.Dom_market_prod_Unlic_Dollar_Value as Unlic_Cultivation_Industry_Dollar_Value, 
cidmp.unlic_value_growth_in_year as Unlic_Cultivation_Industry_Value_Growth, 
cidmp.percent_unlic_value_growth_in_year as Unlic_Cultivation_Industry_Percent_Growth,
cidmp.Dom_market_prod_lic_Dollar_Value as Lic_Cultivation_industry_Dollar_Value, 
cidmp.lic_value_growth_in_year as Lic_Cultivation_industry_Value_Growth, 
cidmp.percent_lic_value_growth_in_year as Lic_Cultivation_Industry_Percent_Growth ,
rsdmp.Dom_market_prod_Unlic_Dollar_Value as Unlic_Retail_Store_Dollar_Value, 
rsdmp.unlic_value_growth_in_year as Unlic_Retail_Store_Value_Growth, 
rsdmp.percent_unlic_value_growth_in_year as Unlic_Retail_Store_Percent_Growth,
rsdmp.Dom_market_prod_lic_Dollar_Value as Lic_Retail_Store_Dollar_Value, 
rsdmp.lic_value_growth_in_year as Lic_Retail_Store_Value_Growth, 
rsdmp.percent_lic_value_growth_in_year as Lic_Retail_Store_Percent_Growth,
(cidmp.unlic_value_growth_in_year + cidmp.Dom_market_prod_lic_Dollar_Value + rsdmp.Dom_market_prod_Unlic_Dollar_Value+rsdmp.Dom_market_prod_lic_Dollar_Value  ) as Total_Production_Value,
(cidmp.unlic_value_growth_in_year +  rsdmp.Dom_market_prod_Unlic_Dollar_Value)/(cidmp.unlic_value_growth_in_year + cidmp.Dom_market_prod_lic_Dollar_Value + rsdmp.Dom_market_prod_Unlic_Dollar_Value+rsdmp.Dom_market_prod_lic_Dollar_Value  ) as Percent_From_Unlicensed_Industry, 
( cidmp.Dom_market_prod_lic_Dollar_Value + rsdmp.Dom_market_prod_lic_Dollar_Value)/(cidmp.unlic_value_growth_in_year + cidmp.Dom_market_prod_lic_Dollar_Value + rsdmp.Dom_market_prod_Unlic_Dollar_Value+ rsdmp.Dom_market_prod_lic_Dollar_Value  ) as Percent_From_Licensed_Industry
FROM
(SELECT dmp.ref_date, dmp.geo, dmp.dguid, dmp.indicator, dmp.industry, 
 dmp.Dom_market_prod_Unlic_Dollar_Value,  dmp.Dom_market_prod_lic_Dollar_Value,
dmpc.unlic_value_growth_in_year, dmpc.percent_unlic_value_growth_in_year,
 dmpc.lic_value_growth_in_year, dmpc.percent_lic_value_growth_in_year
FROM
cannabis_c_p.dom_market_Province  dmp 
LEFT JOIN
(SELECT dmp1.ref_date, dmp1.geo, dmp1.industry,dmp1.indicator, dmp1.Dom_market_prod_Unlic_Dollar_Value, 
dmp2.Dom_market_prod_Unlic_Dollar_Value - dmp1.Dom_market_prod_Unlic_Dollar_Value as unlic_value_growth_in_year, 
(dmp2.Dom_market_prod_Unlic_Dollar_Value -dmp1.Dom_market_prod_Unlic_Dollar_Value)/dmp1.Dom_market_prod_Unlic_Dollar_Value as percent_unlic_value_growth_in_year,
dmp1.Dom_market_prod_lic_Dollar_Value, dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value as lic_value_growth_in_year, 
(dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value)/dmp1.Dom_market_prod_lic_Dollar_Value as percent_lic_value_growth_in_year
FROM cannabis_c_p.dom_market_province dmp1 
JOIN
cannabis_c_p.dom_market_province dmp2
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
cannabis_c_p.dom_market_Province  dmp 
LEFT JOIN
(SELECT dmp1.ref_date, dmp1.geo, dmp1.industry,dmp1.indicator, dmp1.Dom_market_prod_Unlic_Dollar_Value, 
dmp2.Dom_market_prod_Unlic_Dollar_Value - dmp1.Dom_market_prod_Unlic_Dollar_Value as unlic_value_growth_in_year, 
(dmp2.Dom_market_prod_Unlic_Dollar_Value -dmp1.Dom_market_prod_Unlic_Dollar_Value)/dmp1.Dom_market_prod_Unlic_Dollar_Value as percent_unlic_value_growth_in_year,
dmp1.Dom_market_prod_lic_Dollar_Value, dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value as lic_value_growth_in_year, 
(dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value)/dmp1.Dom_market_prod_lic_Dollar_Value as percent_lic_value_growth_in_year
FROM cannabis_c_p.dom_market_province dmp1 
JOIN
cannabis_c_p.dom_market_province dmp2
ON dmp2.ref_date = dmp1.ref_date + 1 AND dmp1.industry = dmp2.industry AND dmp1.geo=dmp2.geo
)dmpc
ON
dmp.ref_date = dmpc.ref_date AND dmp.geo = dmpc.geo AND dmp.industry = dmpc.industry
WHERE dmp.industry != 'Cannabis cultivation industry')rsdmp
ON 
cidmp.ref_date= rsdmp.ref_date AND cidmp.geo = rsdmp.geo AND cidmp.indicator = rsdmp.indicator
Order by 2,1;

Drop view if exists cannabis_c_p.province_domestic_market;
CREATE VIEW cannabis_c_p.province_domestic_market AS
SELECT cidmp.ref_date, cidmp.geo, cidmp.dguid, cidmp.indicator, cidmp.industry, 
cidmp.Dom_market_prod_Unlic_Dollar_Value as Unlic_Cultivation_Industry_Dollar_Value, 
cidmp.unlic_value_growth_in_year as Unlic_Cultivation_Industry_Value_Growth, 
cidmp.percent_unlic_value_growth_in_year as Unlic_Cultivation_Industry_Percent_Growth,
cidmp.Dom_market_prod_lic_Dollar_Value as Lic_Cultivation_industry_Dollar_Value, 
cidmp.lic_value_growth_in_year as Lic_Cultivation_industry_Value_Growth, 
cidmp.percent_lic_value_growth_in_year as Lic_Cultivation_Industry_Percent_Growth ,
rsdmp.Dom_market_prod_Unlic_Dollar_Value as Unlic_Retail_Store_Dollar_Value, 
rsdmp.unlic_value_growth_in_year as Unlic_Retail_Store_Value_Growth, 
rsdmp.percent_unlic_value_growth_in_year as Unlic_Retail_Store_Percent_Growth,
rsdmp.Dom_market_prod_lic_Dollar_Value as Lic_Retail_Store_Dollar_Value, 
rsdmp.lic_value_growth_in_year as Lic_Retail_Store_Value_Growth, 
rsdmp.percent_lic_value_growth_in_year as Lic_Retail_Store_Percent_Growth,
(cidmp.unlic_value_growth_in_year + cidmp.Dom_market_prod_lic_Dollar_Value + rsdmp.Dom_market_prod_Unlic_Dollar_Value+rsdmp.Dom_market_prod_lic_Dollar_Value  ) as Total_Production_Value,
(cidmp.unlic_value_growth_in_year +  rsdmp.Dom_market_prod_Unlic_Dollar_Value)/(cidmp.unlic_value_growth_in_year + cidmp.Dom_market_prod_lic_Dollar_Value + rsdmp.Dom_market_prod_Unlic_Dollar_Value+rsdmp.Dom_market_prod_lic_Dollar_Value  ) as Percent_From_Unlicensed_Industry, 
( cidmp.Dom_market_prod_lic_Dollar_Value + rsdmp.Dom_market_prod_lic_Dollar_Value  )/(cidmp.unlic_value_growth_in_year + cidmp.Dom_market_prod_lic_Dollar_Value + rsdmp.Dom_market_prod_Unlic_Dollar_Value+ rsdmp.Dom_market_prod_lic_Dollar_Value  ) as Percent_From_Licensed_Industry
FROM
(SELECT dmp.ref_date, dmp.geo, dmp.dguid, dmp.indicator, dmp.industry, 
 dmp.Dom_market_prod_Unlic_Dollar_Value,  dmp.Dom_market_prod_lic_Dollar_Value,
dmpc.unlic_value_growth_in_year, dmpc.percent_unlic_value_growth_in_year,
 dmpc.lic_value_growth_in_year, dmpc.percent_lic_value_growth_in_year
FROM
cannabis_c_p.dom_market_Province  dmp 
LEFT JOIN
(SELECT dmp1.ref_date, dmp1.geo, dmp1.industry,dmp1.indicator, dmp1.Dom_market_prod_Unlic_Dollar_Value, 
dmp2.Dom_market_prod_Unlic_Dollar_Value - dmp1.Dom_market_prod_Unlic_Dollar_Value as unlic_value_growth_in_year, 
(dmp2.Dom_market_prod_Unlic_Dollar_Value -dmp1.Dom_market_prod_Unlic_Dollar_Value)/dmp1.Dom_market_prod_Unlic_Dollar_Value as percent_unlic_value_growth_in_year,
dmp1.Dom_market_prod_lic_Dollar_Value, dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value as lic_value_growth_in_year, 
(dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value)/dmp1.Dom_market_prod_lic_Dollar_Value as percent_lic_value_growth_in_year
FROM cannabis_c_p.dom_market_province dmp1 
JOIN
cannabis_c_p.dom_market_province dmp2
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
cannabis_c_p.dom_market_Province  dmp 
LEFT JOIN
(SELECT dmp1.ref_date, dmp1.geo, dmp1.industry,dmp1.indicator, dmp1.Dom_market_prod_Unlic_Dollar_Value, 
dmp2.Dom_market_prod_Unlic_Dollar_Value - dmp1.Dom_market_prod_Unlic_Dollar_Value as unlic_value_growth_in_year, 
(dmp2.Dom_market_prod_Unlic_Dollar_Value -dmp1.Dom_market_prod_Unlic_Dollar_Value)/dmp1.Dom_market_prod_Unlic_Dollar_Value as percent_unlic_value_growth_in_year,
dmp1.Dom_market_prod_lic_Dollar_Value, dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value as lic_value_growth_in_year, 
(dmp2.Dom_market_prod_lic_Dollar_Value - dmp1.Dom_market_prod_lic_Dollar_Value)/dmp1.Dom_market_prod_lic_Dollar_Value as percent_lic_value_growth_in_year
FROM cannabis_c_p.dom_market_province dmp1 
JOIN
cannabis_c_p.dom_market_province dmp2
ON dmp2.ref_date = dmp1.ref_date + 1 AND dmp1.industry = dmp2.industry AND dmp1.geo=dmp2.geo
)dmpc
ON
dmp.ref_date = dmpc.ref_date AND dmp.geo = dmpc.geo AND dmp.industry = dmpc.industry
WHERE dmp.industry != 'Cannabis cultivation industry')rsdmp
ON 
cidmp.ref_date= rsdmp.ref_date AND cidmp.geo = rsdmp.geo AND cidmp.indicator = rsdmp.indicator
Order by 2,1;