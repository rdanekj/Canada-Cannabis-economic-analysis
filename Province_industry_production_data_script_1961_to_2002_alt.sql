select*
FROM cannabis_c_p.`industr_ prod`;

select distinct(indicator)
FROM cannabis_c_p.`industr_ prod`;
select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Domestic production';

-- Domestic Production
SELECT idp1.ref_date, idp1.geo,idp1.dguid,idp1.indicator,idp1.authority,
(idp1.value *1000000) Cultivation_Industry_Value_Dollar, (idp2.value *1000000) Retail_Stores_Dollar_Value
FROM 
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Domestic production' AND `industr_ prod`.industry = 'Cannabis cultivation industry') idp1
JOIN
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Domestic production' AND `industr_ prod`.industry = 'Cannabis retail stores') idp2
ON idp1.ref_date = idp2.ref_date AND idp1.dguid = idp2.dguid AND idp1.authority = idp2.authority
ORDER BY 5,2,1;

DROP TABLE IF EXISTS cannabis_c_p.dom_prod_province;
CREATE TABLE cannabis_c_p.dom_prod_province
(ref_date int, geo varchar (100),dguid varchar (100),indicator varchar (100),authority varchar (100),
Cultivation_Industry_Value_Dollar double, Retail_Stores_Dollar_Value double);
Insert into cannabis_c_p.dom_prod_province
SELECT idp1.ref_date, idp1.geo,idp1.dguid,idp1.indicator,idp1.authority,
(idp1.value *1000000) Cultivation_Industry_Value_Dollar, (idp2.value *1000000) Retail_Stores_Dollar_Value
FROM 
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Domestic production' AND `industr_ prod`.industry = 'Cannabis cultivation industry') idp1
JOIN
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Domestic production' AND `industr_ prod`.industry = 'Cannabis retail stores') idp2
ON idp1.ref_date = idp2.ref_date AND idp1.dguid = idp2.dguid AND idp1.authority = idp2.authority
ORDER BY 5,2,1;


-- Yearly value growth of Domestic Prod
SELECT ydp1.ref_date, ydp1.geo,ydp1.dguid,ydp1.indicator,ydp1.authority,
ydp1.Cultivation_Industry_Value_Dollar, ydp2.Cultivation_Industry_Value_Dollar - ydp1.Cultivation_Industry_Value_Dollar as Cultivation_Industry_Value_Growth,
 ydp1.Retail_Stores_Dollar_Value , (ydp2.Retail_Stores_Dollar_Value - ydp1.Retail_Stores_Dollar_Value) as Retail_Stores_Dollar_Value_growth
FROM 
cannabis_c_p.dom_prod_province ydp1
JOIN 
cannabis_c_p.dom_prod_province ydp2
on 
ydp1.ref_date +1 = ydp2.ref_date AND ydp1.dguid = ydp2.dguid  AND ydp1.authority = ydp2.authority
ORDER BY 5,2,1;


-- Join Domestic Prod and Yearly Domestic Growth

SELECT dp.ref_date, dp.geo,dp.dguid,dp.indicator,dp.authority,
dp.Cultivation_Industry_Value_Dollar,ydp.Cultivation_Industry_Value_Growth,
(ydp.Cultivation_Industry_Value_Growth/dp.Cultivation_Industry_Value_Dollar) as Cultivation_Industry_Percent_value_increase,
dp.Retail_Stores_Dollar_Value, ydp.Retail_Stores_Dollar_Value_growth, 
(ydp.Retail_Stores_Dollar_Value_growth/dp.Retail_Stores_Dollar_Value) as Retail_Store_Percent_value_increase,
(dp.Cultivation_Industry_Value_Dollar+dp.Cultivation_Industry_Value_Dollar) as Total_value_for_Year
FROM 
cannabis_c_p.dom_prod_province dp
LEFT JOIN
(SELECT ydp1.ref_date, ydp1.geo,ydp1.dguid,ydp1.indicator,ydp1.authority,
ydp1.Cultivation_Industry_Value_Dollar, ydp2.Cultivation_Industry_Value_Dollar - ydp1.Cultivation_Industry_Value_Dollar as Cultivation_Industry_Value_Growth,
 ydp1.Retail_Stores_Dollar_Value , (ydp2.Retail_Stores_Dollar_Value - ydp1.Retail_Stores_Dollar_Value) as Retail_Stores_Dollar_Value_growth
FROM 
cannabis_c_p.dom_prod_province ydp1
JOIN 
cannabis_c_p.dom_prod_province ydp2
on 
ydp1.ref_date +1 = ydp2.ref_date AND ydp1.dguid = ydp2.dguid  AND ydp1.authority = ydp2.authority
ORDER BY 5,2,1)ydp
ON ydp.ref_date = dp.ref_date AND ydp.dguid = dp.dguid  AND ydp.authority = dp.authority
ORDER BY  5,2,1;

drop view if exists cannabis_c_p.province_domestic_prod;
Create view cannabis_c_p.province_domestic_prod as
SELECT dp.ref_date, dp.geo,dp.dguid,dp.indicator,dp.authority,
dp.Cultivation_Industry_Value_Dollar,ydp.Cultivation_Industry_Value_Growth,
(ydp.Cultivation_Industry_Value_Growth/dp.Cultivation_Industry_Value_Dollar) as Cultivation_Industry_Percent_value_increase,
dp.Retail_Stores_Dollar_Value, ydp.Retail_Stores_Dollar_Value_growth, 
(ydp.Retail_Stores_Dollar_Value_growth/dp.Retail_Stores_Dollar_Value) as Retail_Store_Percent_value_increase,
(dp.Cultivation_Industry_Value_Dollar+dp.Cultivation_Industry_Value_Dollar) as Total_value_for_Year
FROM 
cannabis_c_p.dom_prod_province dp
LEFT JOIN
(SELECT ydp1.ref_date, ydp1.geo,ydp1.dguid,ydp1.indicator,ydp1.authority,
ydp1.Cultivation_Industry_Value_Dollar, ydp2.Cultivation_Industry_Value_Dollar - ydp1.Cultivation_Industry_Value_Dollar as Cultivation_Industry_Value_Growth,
 ydp1.Retail_Stores_Dollar_Value , (ydp2.Retail_Stores_Dollar_Value - ydp1.Retail_Stores_Dollar_Value) as Retail_Stores_Dollar_Value_growth
FROM 
cannabis_c_p.dom_prod_province ydp1
JOIN 
cannabis_c_p.dom_prod_province ydp2
on 
ydp1.ref_date +1 = ydp2.ref_date AND ydp1.dguid = ydp2.dguid  AND ydp1.authority = ydp2.authority
ORDER BY 5,2,1)ydp
ON ydp.ref_date = dp.ref_date AND ydp.dguid = dp.dguid  AND ydp.authority = dp.authority
ORDER BY  5,2,1;

-- Domestic market production
SELECT idp1.ref_date, idp1.geo,idp1.dguid,idp1.indicator,idp1.authority,(idp1.value *1000000) Cultivation_Industry_Value, (idp2.value *1000000) Retail_Stores_Value
FROM 
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Domestic market production' AND `industr_ prod`.industry = 'Cannabis cultivation industry') idp1
JOIN
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Domestic market production' AND `industr_ prod`.industry = 'Cannabis retail stores') idp2
ON idp1.ref_date = idp2.ref_date AND idp1.dguid = idp2.dguid AND idp1.authority = idp2.authority
ORDER BY 5,1,2;

DROP TABLE IF EXISTS cannabis_c_p.dom_market_province;
CREATE TABLE cannabis_c_p.dom_market_province
(ref_date int, geo varchar (100),dguid varchar (100),indicator varchar (100),authority varchar (100),
Cultivation_Industry_Value_Dollar double, Retail_Stores_Dollar_Value double);
Insert into cannabis_c_p.dom_market_province
SELECT idp1.ref_date, idp1.geo,idp1.dguid,idp1.indicator,idp1.authority,(idp1.value *1000000) Cultivation_Industry_Value, (idp2.value *1000000) Retail_Stores_Value
FROM 
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Domestic market production' AND `industr_ prod`.industry = 'Cannabis cultivation industry') idp1
JOIN
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Domestic market production' AND `industr_ prod`.industry = 'Cannabis retail stores') idp2
ON idp1.ref_date = idp2.ref_date AND idp1.dguid = idp2.dguid AND idp1.authority = idp2.authority
ORDER BY 5,1,2;

-- Yearly value growth of Domestic market production
SELECT ydp1.ref_date, ydp1.geo,ydp1.dguid,ydp1.indicator,ydp1.authority,
ydp1.Cultivation_Industry_Value_Dollar, ydp2.Cultivation_Industry_Value_Dollar - ydp1.Cultivation_Industry_Value_Dollar as Cultivation_Industry_Value_Growth,
 ydp1.Retail_Stores_Dollar_Value , (ydp2.Retail_Stores_Dollar_Value - ydp1.Retail_Stores_Dollar_Value) as Retail_Stores_Dollar_Value_growth
FROM 
cannabis_c_p.dom_market_province ydp1
JOIN 
cannabis_c_p.dom_market_province ydp2
on 
ydp1.ref_date +1 = ydp2.ref_date AND ydp1.dguid = ydp2.dguid  AND ydp1.authority = ydp2.authority
ORDER BY 5,2,1;


-- Join Domestic Market Prod and Yearly Domestic market prod Growth

SELECT dp.ref_date, dp.geo,dp.dguid,dp.indicator,dp.authority,
dp.Cultivation_Industry_Value_Dollar,ydp.Cultivation_Industry_Value_Growth,
(ydp.Cultivation_Industry_Value_Growth/dp.Cultivation_Industry_Value_Dollar) as Cultivation_Industry_Percent_value_increase,
dp.Retail_Stores_Dollar_Value, ydp.Retail_Stores_Dollar_Value_growth, 
(ydp.Retail_Stores_Dollar_Value_growth/dp.Retail_Stores_Dollar_Value) as Retail_Store_Percent_value_increase,
(dp.Cultivation_Industry_Value_Dollar+dp.Cultivation_Industry_Value_Dollar) as Total_value_for_Year
FROM
cannabis_c_p.dom_market_province dp
LEFT JOIN
(SELECT ydp1.ref_date, ydp1.geo,ydp1.dguid,ydp1.indicator,ydp1.authority,
ydp1.Cultivation_Industry_Value_Dollar, ydp2.Cultivation_Industry_Value_Dollar - ydp1.Cultivation_Industry_Value_Dollar as Cultivation_Industry_Value_Growth,
 ydp1.Retail_Stores_Dollar_Value , (ydp2.Retail_Stores_Dollar_Value - ydp1.Retail_Stores_Dollar_Value) as Retail_Stores_Dollar_Value_growth
FROM 
cannabis_c_p.dom_market_province ydp1
JOIN 
cannabis_c_p.dom_market_province ydp2
on 
ydp1.ref_date +1 = ydp2.ref_date AND ydp1.dguid = ydp2.dguid  AND ydp1.authority = ydp2.authority
ORDER BY 5,2,1)ydp
ON ydp.ref_date = dp.ref_date AND ydp.dguid = dp.dguid  AND ydp.authority = dp.authority
ORDER BY  5,2,1;

Drop view if exists cannabis_c_p.province_domestic_market;
create view cannabis_c_p.province_domestic_market as
SELECT dp.ref_date, dp.geo,dp.dguid,dp.indicator,dp.authority,
dp.Cultivation_Industry_Value_Dollar,ydp.Cultivation_Industry_Value_Growth,
(ydp.Cultivation_Industry_Value_Growth/dp.Cultivation_Industry_Value_Dollar) as Cultivation_Industry_Percent_value_increase,
dp.Retail_Stores_Dollar_Value, ydp.Retail_Stores_Dollar_Value_growth, 
(ydp.Retail_Stores_Dollar_Value_growth/dp.Retail_Stores_Dollar_Value) as Retail_Store_Percent_value_increase,
(dp.Cultivation_Industry_Value_Dollar+dp.Cultivation_Industry_Value_Dollar) as Total_value_for_Year
FROM
cannabis_c_p.dom_market_province dp
LEFT JOIN
(SELECT ydp1.ref_date, ydp1.geo,ydp1.dguid,ydp1.indicator,ydp1.authority,
ydp1.Cultivation_Industry_Value_Dollar, ydp2.Cultivation_Industry_Value_Dollar - ydp1.Cultivation_Industry_Value_Dollar as Cultivation_Industry_Value_Growth,
 ydp1.Retail_Stores_Dollar_Value , (ydp2.Retail_Stores_Dollar_Value - ydp1.Retail_Stores_Dollar_Value) as Retail_Stores_Dollar_Value_growth
FROM 
cannabis_c_p.dom_market_province ydp1
JOIN 
cannabis_c_p.dom_market_province ydp2
on 
ydp1.ref_date +1 = ydp2.ref_date AND ydp1.dguid = ydp2.dguid  AND ydp1.authority = ydp2.authority
ORDER BY 5,2,1)ydp
ON ydp.ref_date = dp.ref_date AND ydp.dguid = dp.dguid  AND ydp.authority = dp.authority
ORDER BY  5,2,1;


-- Domestic own-use production
SELECT idp1.ref_date, idp1.geo,idp1.dguid,idp1.indicator,idp1.authority,(idp1.value *1000000) Cultivation_Industry_Value, (idp2.value *1000000) Retail_Stores_Value
FROM 
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Domestic own-use production' AND `industr_ prod`.industry = 'Cannabis cultivation industry') idp1
JOIN
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Domestic own-use production' AND `industr_ prod`.industry = 'Cannabis retail stores') idp2
ON idp1.ref_date = idp2.ref_date AND idp1.dguid = idp2.dguid AND idp1.authority = idp2.authority
ORDER BY 5,1,2;

DROP TABLE IF EXISTS cannabis_c_p.dom_own_use_province;
CREATE TABLE cannabis_c_p.dom_own_use_province
(ref_date int, geo varchar (100),dguid varchar (100),indicator varchar (100),authority varchar (100),
Cultivation_Industry_Value_Dollar double, Retail_Stores_Dollar_Value double);
INSERT INTO cannabis_c_p.dom_own_use_province
SELECT idp1.ref_date, idp1.geo,idp1.dguid,idp1.indicator,idp1.authority,(idp1.value *1000000) Cultivation_Industry_Value, (idp2.value *1000000) Retail_Stores_Value
FROM 
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Domestic own-use production' AND `industr_ prod`.industry = 'Cannabis cultivation industry') idp1
JOIN
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Domestic own-use production' AND `industr_ prod`.industry = 'Cannabis retail stores') idp2
ON idp1.ref_date = idp2.ref_date AND idp1.dguid = idp2.dguid AND idp1.authority = idp2.authority
ORDER BY 5,1,2;

-- Yearly value growth of Domestic own-use production
SELECT ydp1.ref_date, ydp1.geo,ydp1.dguid,ydp1.indicator,ydp1.authority,
ydp1.Cultivation_Industry_Value_Dollar, ydp2.Cultivation_Industry_Value_Dollar - ydp1.Cultivation_Industry_Value_Dollar as Cultivation_Industry_Value_Growth,
 ydp1.Retail_Stores_Dollar_Value , (ydp2.Retail_Stores_Dollar_Value - ydp1.Retail_Stores_Dollar_Value) as Retail_Stores_Dollar_Value_growth
FROM 
cannabis_c_p.dom_own_use_province ydp1
JOIN 
cannabis_c_p.dom_own_use_province ydp2
on 
ydp1.ref_date +1 = ydp2.ref_date AND ydp1.dguid = ydp2.dguid  AND ydp1.authority = ydp2.authority
ORDER BY 5,2,1;



-- JOin Domestic own use and yearly growth
SELECT dp.ref_date, dp.geo,dp.dguid,dp.indicator,dp.authority,
dp.Cultivation_Industry_Value_Dollar,ydp.Cultivation_Industry_Value_Growth,
(ydp.Cultivation_Industry_Value_Growth/dp.Cultivation_Industry_Value_Dollar) as Cultivation_Industry_Percent_value_increase,
dp.Retail_Stores_Dollar_Value, ydp.Retail_Stores_Dollar_Value_growth, 
(ydp.Retail_Stores_Dollar_Value_growth/dp.Retail_Stores_Dollar_Value) as Retail_Store_Percent_value_increase,
(dp.Cultivation_Industry_Value_Dollar+dp.Cultivation_Industry_Value_Dollar) as Total_value_for_Year
FROM
cannabis_c_p.dom_own_use_province dp
LEFT JOIN
(SELECT ydp1.ref_date, ydp1.geo,ydp1.dguid,ydp1.indicator,ydp1.authority,
ydp1.Cultivation_Industry_Value_Dollar, ydp2.Cultivation_Industry_Value_Dollar - ydp1.Cultivation_Industry_Value_Dollar as Cultivation_Industry_Value_Growth,
 ydp1.Retail_Stores_Dollar_Value , (ydp2.Retail_Stores_Dollar_Value - ydp1.Retail_Stores_Dollar_Value) as Retail_Stores_Dollar_Value_growth
FROM 
cannabis_c_p.dom_own_use_province ydp1
JOIN 
cannabis_c_p.dom_own_use_province ydp2
on 
ydp1.ref_date +1 = ydp2.ref_date AND ydp1.dguid = ydp2.dguid  AND ydp1.authority = ydp2.authority
ORDER BY 5,2,1)ydp
ON ydp.ref_date = dp.ref_date AND ydp.dguid = dp.dguid  AND ydp.authority = dp.authority
ORDER BY  5,2,1;

Drop view if exists cannabis_c_p.province_own_use;
create view  cannabis_c_p.province_own_use as
SELECT dp.ref_date, dp.geo,dp.dguid,dp.indicator,dp.authority,
dp.Cultivation_Industry_Value_Dollar,ydp.Cultivation_Industry_Value_Growth,
(ydp.Cultivation_Industry_Value_Growth/dp.Cultivation_Industry_Value_Dollar) as Cultivation_Industry_Percent_value_increase,
dp.Retail_Stores_Dollar_Value, ydp.Retail_Stores_Dollar_Value_growth, 
(ydp.Retail_Stores_Dollar_Value_growth/dp.Retail_Stores_Dollar_Value) as Retail_Store_Percent_value_increase,
(dp.Cultivation_Industry_Value_Dollar+dp.Cultivation_Industry_Value_Dollar) as Total_value_for_Year
FROM
cannabis_c_p.dom_own_use_province dp
LEFT JOIN
(SELECT ydp1.ref_date, ydp1.geo,ydp1.dguid,ydp1.indicator,ydp1.authority,
ydp1.Cultivation_Industry_Value_Dollar, ydp2.Cultivation_Industry_Value_Dollar - ydp1.Cultivation_Industry_Value_Dollar as Cultivation_Industry_Value_Growth,
 ydp1.Retail_Stores_Dollar_Value , (ydp2.Retail_Stores_Dollar_Value - ydp1.Retail_Stores_Dollar_Value) as Retail_Stores_Dollar_Value_growth
FROM 
cannabis_c_p.dom_own_use_province ydp1
JOIN 
cannabis_c_p.dom_own_use_province ydp2
on 
ydp1.ref_date +1 = ydp2.ref_date AND ydp1.dguid = ydp2.dguid  AND ydp1.authority = ydp2.authority
ORDER BY 5,2,1)ydp
ON ydp.ref_date = dp.ref_date AND ydp.dguid = dp.dguid  AND ydp.authority = dp.authority
ORDER BY  5,2,1;

-- Intermediate consumption
SELECT idp1.ref_date, idp1.geo,idp1.dguid,idp1.indicator,idp1.authority,(idp1.value *1000000) Cultivation_Industry_Value, (idp2.value *1000000) Retail_Stores_Value
FROM 
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Intermediate consumption' AND `industr_ prod`.industry = 'Cannabis cultivation industry') idp1
JOIN
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Intermediate consumption' AND `industr_ prod`.industry = 'Cannabis retail stores') idp2
ON idp1.ref_date = idp2.ref_date AND idp1.dguid = idp2.dguid AND idp1.authority = idp2.authority
ORDER BY 5,1,2;

DROP TABLE IF EXISTS cannabis_c_p.interm_comp_province;
CREATE TABLE cannabis_c_p.interm_comp_province
(ref_date int, geo varchar (100),dguid varchar (100),indicator varchar (100),authority varchar (100),
Cultivation_Industry_Value_Dollar double, Retail_Stores_Dollar_Value double);
INSERT INTO cannabis_c_p.interm_comp_province
SELECT idp1.ref_date, idp1.geo,idp1.dguid,idp1.indicator,idp1.authority,(idp1.value *1000000) Cultivation_Industry_Value, (idp2.value *1000000) Retail_Stores_Value
FROM 
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Intermediate consumption' AND `industr_ prod`.industry = 'Cannabis cultivation industry') idp1
JOIN
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Intermediate consumption' AND `industr_ prod`.industry = 'Cannabis retail stores') idp2
ON idp1.ref_date = idp2.ref_date AND idp1.dguid = idp2.dguid AND idp1.authority = idp2.authority
ORDER BY 5,1,2;

-- Yearly value growth of Intermediate consumption
SELECT ydp1.ref_date, ydp1.geo,ydp1.dguid,ydp1.indicator,ydp1.authority,
ydp1.Cultivation_Industry_Value_Dollar, ydp2.Cultivation_Industry_Value_Dollar - ydp1.Cultivation_Industry_Value_Dollar as Cultivation_Industry_Value_Growth,
 ydp1.Retail_Stores_Dollar_Value , (ydp2.Retail_Stores_Dollar_Value - ydp1.Retail_Stores_Dollar_Value) as Retail_Stores_Dollar_Value_growth
FROM 
cannabis_c_p.interm_comp_province ydp1
JOIN 
cannabis_c_p.interm_comp_province ydp2
on 
ydp1.ref_date +1 = ydp2.ref_date AND ydp1.dguid = ydp2.dguid  AND ydp1.authority = ydp2.authority
ORDER BY 5,2,1;

-- JOin intermediate consumption use and yearly growth
SELECT dp.ref_date, dp.geo,dp.dguid,dp.indicator,dp.authority,
dp.Cultivation_Industry_Value_Dollar,ydp.Cultivation_Industry_Value_Growth,
(ydp.Cultivation_Industry_Value_Growth/dp.Cultivation_Industry_Value_Dollar) as Cultivation_Industry_Percent_value_increase,
dp.Retail_Stores_Dollar_Value, ydp.Retail_Stores_Dollar_Value_growth, 
(ydp.Retail_Stores_Dollar_Value_growth/dp.Retail_Stores_Dollar_Value) as Retail_Store_Percent_value_increase,
(dp.Cultivation_Industry_Value_Dollar+dp.Cultivation_Industry_Value_Dollar) as Total_value_for_Year
FROM
cannabis_c_p.interm_comp_province dp
LEFT JOIN
(SELECT ydp1.ref_date, ydp1.geo,ydp1.dguid,ydp1.indicator,ydp1.authority,
ydp1.Cultivation_Industry_Value_Dollar, ydp2.Cultivation_Industry_Value_Dollar - ydp1.Cultivation_Industry_Value_Dollar as Cultivation_Industry_Value_Growth,
 ydp1.Retail_Stores_Dollar_Value , (ydp2.Retail_Stores_Dollar_Value - ydp1.Retail_Stores_Dollar_Value) as Retail_Stores_Dollar_Value_growth
FROM 
cannabis_c_p.interm_comp_province ydp1
JOIN 
cannabis_c_p.interm_comp_province ydp2
on 
ydp1.ref_date +1 = ydp2.ref_date AND ydp1.dguid = ydp2.dguid  AND ydp1.authority = ydp2.authority
ORDER BY 5,2,1)ydp
ON ydp.ref_date = dp.ref_date AND ydp.dguid = dp.dguid  AND ydp.authority = dp.authority
ORDER BY  5,2,1;

DROP VIEW IF EXISTS cannabis_c_p.province_interm_consump;
CREATE VIEW cannabis_c_p.province_interm_consump as
SELECT dp.ref_date, dp.geo,dp.dguid,dp.indicator,dp.authority,
dp.Cultivation_Industry_Value_Dollar,ydp.Cultivation_Industry_Value_Growth,
(ydp.Cultivation_Industry_Value_Growth/dp.Cultivation_Industry_Value_Dollar) as Cultivation_Industry_Percent_value_increase,
dp.Retail_Stores_Dollar_Value, ydp.Retail_Stores_Dollar_Value_growth, 
(ydp.Retail_Stores_Dollar_Value_growth/dp.Retail_Stores_Dollar_Value) as Retail_Store_Percent_value_increase,
(dp.Cultivation_Industry_Value_Dollar+dp.Cultivation_Industry_Value_Dollar) as Total_value_for_Year
FROM
cannabis_c_p.interm_comp_province dp
LEFT JOIN
(SELECT ydp1.ref_date, ydp1.geo,ydp1.dguid,ydp1.indicator,ydp1.authority,
ydp1.Cultivation_Industry_Value_Dollar, ydp2.Cultivation_Industry_Value_Dollar - ydp1.Cultivation_Industry_Value_Dollar as Cultivation_Industry_Value_Growth,
 ydp1.Retail_Stores_Dollar_Value , (ydp2.Retail_Stores_Dollar_Value - ydp1.Retail_Stores_Dollar_Value) as Retail_Stores_Dollar_Value_growth
FROM 
cannabis_c_p.interm_comp_province ydp1
JOIN 
cannabis_c_p.interm_comp_province ydp2
on 
ydp1.ref_date +1 = ydp2.ref_date AND ydp1.dguid = ydp2.dguid  AND ydp1.authority = ydp2.authority
ORDER BY 5,2,1)ydp
ON ydp.ref_date = dp.ref_date AND ydp.dguid = dp.dguid  AND ydp.authority = dp.authority
ORDER BY  5,2,1;

-- Gross value added
SELECT idp1.ref_date, idp1.geo,idp1.dguid,idp1.indicator,idp1.authority,(idp1.value *1000000) Cultivation_Industry_Value, (idp2.value *1000000) Retail_Stores_Value
FROM 
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Gross value added' AND `industr_ prod`.industry = 'Cannabis cultivation industry') idp1
JOIN
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Gross value added' AND `industr_ prod`.industry = 'Cannabis retail stores') idp2
ON idp1.ref_date = idp2.ref_date AND idp1.dguid = idp2.dguid AND idp1.authority = idp2.authority
ORDER BY 5,1,2;

DROP TABLE IF EXISTS cannabis_c_p.gross_val_added_per_region;
CREATE TABLE cannabis_c_p.gross_val_added_per_region
(ref_date int, geo varchar (100),dguid varchar (100),indicator varchar (100),authority varchar (100),
Cultivation_Industry_Value_Dollar double, Retail_Stores_Dollar_Value double);
INSERT INTO cannabis_c_p.gross_val_added_per_region
SELECT idp1.ref_date, idp1.geo,idp1.dguid,idp1.indicator,idp1.authority,(idp1.value *1000000) Cultivation_Industry_Value, (idp2.value *1000000) Retail_Stores_Value
FROM 
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Gross value added' AND `industr_ prod`.industry = 'Cannabis cultivation industry') idp1
JOIN
(select*
FROM cannabis_c_p.`industr_ prod`
WHERE `industr_ prod`.geo != 'Canada' AND `industr_ prod`.indicator = 'Gross value added' AND `industr_ prod`.industry = 'Cannabis retail stores') idp2
ON idp1.ref_date = idp2.ref_date AND idp1.dguid = idp2.dguid AND idp1.authority = idp2.authority
ORDER BY 5,1,2;


-- Yearly value growth of Gross value added
SELECT ydp1.ref_date, ydp1.geo,ydp1.dguid,ydp1.indicator,ydp1.authority,
ydp1.Cultivation_Industry_Value_Dollar, ydp2.Cultivation_Industry_Value_Dollar - ydp1.Cultivation_Industry_Value_Dollar as Cultivation_Industry_Value_Growth,
 ydp1.Retail_Stores_Dollar_Value , (ydp2.Retail_Stores_Dollar_Value - ydp1.Retail_Stores_Dollar_Value) as Retail_Stores_Dollar_Value_growth
FROM 
cannabis_c_p.gross_val_added_per_region ydp1
JOIN 
cannabis_c_p.gross_val_added_per_region ydp2
on 
ydp1.ref_date +1 = ydp2.ref_date AND ydp1.dguid = ydp2.dguid  AND ydp1.authority = ydp2.authority
ORDER BY 5,2,1;

-- Join gross value added use and yearly growth
SELECT dp.ref_date, dp.geo,dp.dguid,dp.indicator,dp.authority,
dp.Cultivation_Industry_Value_Dollar,ydp.Cultivation_Industry_Value_Growth,
(ydp.Cultivation_Industry_Value_Growth/dp.Cultivation_Industry_Value_Dollar) as Cultivation_Industry_Percent_value_increase,
dp.Retail_Stores_Dollar_Value, ydp.Retail_Stores_Dollar_Value_growth, 
(ydp.Retail_Stores_Dollar_Value_growth/dp.Retail_Stores_Dollar_Value) as Retail_Store_Percent_value_increase,
(dp.Cultivation_Industry_Value_Dollar+dp.Cultivation_Industry_Value_Dollar) as Total_value_for_Year
FROM
cannabis_c_p.gross_val_added_per_region dp
LEFT JOIN
(SELECT ydp1.ref_date, ydp1.geo,ydp1.dguid,ydp1.indicator,ydp1.authority,
ydp1.Cultivation_Industry_Value_Dollar, ydp2.Cultivation_Industry_Value_Dollar - ydp1.Cultivation_Industry_Value_Dollar as Cultivation_Industry_Value_Growth,
 ydp1.Retail_Stores_Dollar_Value , (ydp2.Retail_Stores_Dollar_Value - ydp1.Retail_Stores_Dollar_Value) as Retail_Stores_Dollar_Value_growth
FROM 
cannabis_c_p.gross_val_added_per_region ydp1
JOIN 
cannabis_c_p.gross_val_added_per_region ydp2
on 
ydp1.ref_date +1 = ydp2.ref_date AND ydp1.dguid = ydp2.dguid  AND ydp1.authority = ydp2.authority
ORDER BY 5,2,1)ydp
ON ydp.ref_date = dp.ref_date AND ydp.dguid = dp.dguid  AND ydp.authority = dp.authority
ORDER BY  5,2,1;

Drop view if exists cannabis_c_p.province_gross_val;
CREATE VIEW cannabis_c_p.province_gross_val as 
SELECT dp.ref_date, dp.geo,dp.dguid,dp.indicator,dp.authority,
dp.Cultivation_Industry_Value_Dollar,ydp.Cultivation_Industry_Value_Growth,
(ydp.Cultivation_Industry_Value_Growth/dp.Cultivation_Industry_Value_Dollar) as Cultivation_Industry_Percent_value_increase,
dp.Retail_Stores_Dollar_Value, ydp.Retail_Stores_Dollar_Value_growth, 
(ydp.Retail_Stores_Dollar_Value_growth/dp.Retail_Stores_Dollar_Value) as Retail_Store_Percent_value_increase,
(dp.Cultivation_Industry_Value_Dollar+dp.Cultivation_Industry_Value_Dollar) as Total_value_for_Year
FROM
cannabis_c_p.gross_val_added_per_region dp
LEFT JOIN
(SELECT ydp1.ref_date, ydp1.geo,ydp1.dguid,ydp1.indicator,ydp1.authority,
ydp1.Cultivation_Industry_Value_Dollar, ydp2.Cultivation_Industry_Value_Dollar - ydp1.Cultivation_Industry_Value_Dollar as Cultivation_Industry_Value_Growth,
 ydp1.Retail_Stores_Dollar_Value , (ydp2.Retail_Stores_Dollar_Value - ydp1.Retail_Stores_Dollar_Value) as Retail_Stores_Dollar_Value_growth
FROM 
cannabis_c_p.gross_val_added_per_region ydp1
JOIN 
cannabis_c_p.gross_val_added_per_region ydp2
on 
ydp1.ref_date +1 = ydp2.ref_date AND ydp1.dguid = ydp2.dguid  AND ydp1.authority = ydp2.authority
ORDER BY 5,2,1)ydp
ON ydp.ref_date = dp.ref_date AND ydp.dguid = dp.dguid  AND ydp.authority = dp.authority
ORDER BY  5,2,1;