SELECT * FROM cannabis_c_p.`industr_ prod`;

-- Cultivation industry licesed
SELECT * FROM cannabis_c_p.`industr_ prod`
Where industry = "Cannabis cultivation industry" AND authority = 'Licensed source' and geo = 'Canada';

SELECT ref_date, geo, dguid, indicator, industry, authority,value * 1000000 as value
FROM cannabis_c_p.`industr_ prod`
Where industry = "Cannabis cultivation industry" AND authority = 'Licensed source' and geo = 'Canada'
Order by 4,1;
-- This segment of code breaks down the licensed cannabis cultivation industry and calculates the yearly increase or change in value for each indicator i
Drop table if exists cannabis_c_p.canada_indus_cult_lic_value_growth;
CREATE TABLE cannabis_c_p.canada_indus_cult_lic_value_growth 
(ref_date int, geo varchar (25), dguid varchar (100), indicator varchar (100), industry varchar (100), 
authority varchar (100),value double, value_growth double);
INSERT INTO cannabis_c_p.canada_indus_cult_lic_value_growth
Select lic_cci1.ref_date, lic_cci1.geo, lic_cci1.dguid, lic_cci1.indicator, lic_cci1.industry, lic_cci1.authority,lic_cci2.value, lic_cci2.value - lic_cci1.value as value_growth
From
(SELECT ref_date, geo, dguid, indicator, industry, authority,value * 1000000 as value
FROM cannabis_c_p.`industr_ prod`
Where industry = "Cannabis cultivation industry" AND authority = 'Licensed source' and geo = 'Canada'
Order by 4,1) lic_cci1
JOIN
(SELECT ref_date, geo, dguid, indicator, industry, authority,value * 1000000 as value
FROM cannabis_c_p.`industr_ prod`
Where industry = "Cannabis cultivation industry" AND authority = 'Licensed source' and geo = 'Canada'
Order by 4,1) lic_cci2
ON lic_cci2.ref_date = lic_cci1.ref_date + 1 and lic_cci1.indicator = lic_cci2.indicator
ORDER BY 4,1;

-- The licensed cultivation industry will be jouned with the calculated changes in each year using a Left Join
SELECT l_cci.ref_date, l_cci.geo, l_cci.dguid, l_cci.indicator, l_cci.industry, l_cci.authority,l_cci.value, l_ccig.value_growth
FROM
(SELECT ref_date, geo, dguid, indicator, industry, authority,value * 1000000 as value
FROM cannabis_c_p.`industr_ prod`
Where industry = "Cannabis cultivation industry" AND authority = 'Licensed source' and geo = 'Canada'
Order by 4,1) l_cci
LEFT JOIN
cannabis_c_p.canada_indus_cult_lic_value_growth l_ccig
on l_ccig.ref_date = l_cci.ref_date and l_cci.indicator = l_ccig.indicator
ORDER BY 4,1;


-- Cultivation industry unlicesed data manipulation. 
SELECT * FROM cannabis_c_p.`industr_ prod`
Where industry = "Cannabis cultivation industry" AND authority != 'Licensed source' and geo = 'Canada';

SELECT ref_date, geo, dguid, indicator, industry, authority,value * 1000000 as value
FROM cannabis_c_p.`industr_ prod`
Where industry = "Cannabis cultivation industry" AND authority != 'Licensed source' and geo = 'Canada'
Order by 4,1;
-- This segment of code breaks down the unlicensed cannabis cultivation industry and calculates the yearly increase or change in value for each indicator.
Drop table if exists cannabis_c_p.canada_cult_indus_unlic_value_growth;
CREATE TABLE cannabis_c_p.canada_cult_indus_unlic_value_growth 
(ref_date int, geo varchar (25), dguid varchar (100), indicator varchar (100), industry varchar (100), 
authority varchar (100),value double, value_growth double);
INSERT INTO cannabis_c_p.canada_cult_indus_unlic_value_growth
Select unlic_cci1.ref_date, unlic_cci1.geo, unlic_cci1.dguid, unlic_cci1.indicator, unlic_cci1.industry, unlic_cci1.authority,
unlic_cci2.value, unlic_cci2.value - unlic_cci1.value as value_growth
From
(SELECT ref_date, geo, dguid, indicator, industry, authority,value * 1000000 as value
FROM cannabis_c_p.`industr_ prod`
Where industry = "Cannabis cultivation industry" AND authority != 'Licensed source' and geo = 'Canada'
Order by 4,1) unlic_cci1
JOIN
(SELECT ref_date, geo, dguid, indicator, industry, authority,value * 1000000 as value
FROM cannabis_c_p.`industr_ prod`
Where industry = "Cannabis cultivation industry" AND authority != 'Licensed source' and geo = 'Canada'
Order by 4,1) unlic_cci2
ON unlic_cci2.ref_date = unlic_cci1.ref_date + 1 and unlic_cci1.indicator = unlic_cci2.indicator
ORDER BY 4,1;

-- The unlicensed cultivation industry will be jouned with the calculated changes in each year using a Left Join
SELECT ul_cci.ref_date, ul_cci.geo, ul_cci.dguid, ul_cci.indicator, ul_cci.industry, ul_cci.authority,ul_cci.value, ul_ccig.value_growth
FROM
(SELECT ref_date, geo, dguid, indicator, industry, authority,value * 1000000 as value
FROM cannabis_c_p.`industr_ prod`
Where industry = "Cannabis cultivation industry" AND authority != 'Licensed source' and geo = 'Canada'
Order by 4,1) ul_cci
LEFT JOIN
cannabis_c_p.canada_cult_indus_unlic_value_growth ul_ccig
on ul_ccig.ref_date = ul_cci.ref_date and ul_cci.indicator = ul_ccig.indicator
ORDER BY 4,1;

-- Retail industry 
SELECT * FROM cannabis_c_p.`industr_ prod`
Where industry != "Cannabis cultivation industry" AND authority = 'Licensed source' and geo = 'Canada';

-- This segment of code breaks down the licensed cannabis retail industry and calculates the yearly increase or change in value for each indicator i
Drop table if exists cannabis_c_p.canada_indus_retail_lic_value_growth;
CREATE TABLE cannabis_c_p.canada_indus_retail_lic_value_growth 
(ref_date int, geo varchar (25), dguid varchar (100), indicator varchar (100), industry varchar (100), 
authority varchar (100),value double, value_growth double);
INSERT INTO cannabis_c_p.canada_indus_retail_lic_value_growth
Select lic_ri1.ref_date, lic_ri1.geo, lic_ri1.dguid, lic_ri1.indicator, lic_ri1.industry, lic_ri1.authority,
lic_ri2.value, lic_ri2.value - lic_ri1.value as value_growth
From
(SELECT ref_date, geo, dguid, indicator, industry, authority,value * 1000000 as value
FROM cannabis_c_p.`industr_ prod`
Where industry != "Cannabis cultivation industry" AND authority = 'Licensed source' and geo = 'Canada'
Order by 4,1) lic_ri1
JOIN
(SELECT ref_date, geo, dguid, indicator, industry, authority,value * 1000000 as value
FROM cannabis_c_p.`industr_ prod`
Where industry != "Cannabis cultivation industry" AND authority = 'Licensed source' and geo = 'Canada'
Order by 4,1) lic_ri2
ON lic_ri2.ref_date = lic_ri1.ref_date + 1 and lic_ri1.indicator = lic_ri2.indicator
ORDER BY 4,1;
select * from cannabis_c_p.canada_indus_retail_lic_value_growth ;

-- join 
SELECT lic_ri.ref_date, lic_ri.geo, lic_ri.dguid, lic_ri.indicator, lic_ri.industry, lic_ri.authority,lic_ri.value, lic_rig.value_growth
FROM
(SELECT ref_date, geo, dguid, indicator, industry, authority,value * 1000000 as value
FROM cannabis_c_p.`industr_ prod`
Where industry != "Cannabis cultivation industry" AND authority = 'Licensed source' and geo = 'Canada'
Order by 4,1)lic_ri
Left JOin
cannabis_c_p.canada_indus_retail_lic_value_growth lic_rig
ON lic_rig.ref_date = lic_ri.ref_date and lic_ri.indicator = lic_rig.indicator
ORDER BY 4,1;

-- unlicensed retail store
SELECT * FROM cannabis_c_p.`industr_ prod`
Where industry != "Cannabis cultivation industry" AND authority != 'Licensed source' and geo = 'Canada';

-- This segment of code breaks down the licensed cannabis retail industry and calculates the yearly increase or change in value for each indicator i
Drop table if exists cannabis_c_p.canada_indus_retail_unlic_value_growth;
CREATE TABLE cannabis_c_p.canada_indus_retail_unlic_value_growth 
(ref_date int, geo varchar (25), dguid varchar (100), indicator varchar (100), industry varchar (100), 
authority varchar (100),value double, value_growth double);
INSERT INTO cannabis_c_p.canada_indus_retail_unlic_value_growth
Select unlic_ri1.ref_date, unlic_ri1.geo, unlic_ri1.dguid, unlic_ri1.indicator, unlic_ri1.industry, unlic_ri1.authority,
unlic_ri1.value, unlic_ri2.value - unlic_ri1.value as value_growth
From
(SELECT ref_date, geo, dguid, indicator, industry, authority,value * 1000000 as value
FROM cannabis_c_p.`industr_ prod`
Where industry != "Cannabis cultivation industry" AND authority != 'Licensed source' and geo = 'Canada'
Order by 4,1) unlic_ri1
JOIN
(SELECT ref_date, geo, dguid, indicator, industry, authority,value * 1000000 as value
FROM cannabis_c_p.`industr_ prod`
Where industry != "Cannabis cultivation industry" AND authority != 'Licensed source' and geo = 'Canada'
Order by 4,1) unlic_ri2
ON unlic_ri2.ref_date = unlic_ri1.ref_date + 1 and unlic_ri1.indicator = unlic_ri2.indicator
ORDER BY 4,1;
select * from cannabis_c_p.canada_indus_retail_unlic_value_growth ;

-- join unlicensed retail with growth
SELECT unlic_ri.ref_date, unlic_ri.geo, unlic_ri.dguid, unlic_ri.indicator, unlic_ri.industry, unlic_ri.authority,
unlic_ri.value, unlic_rig.value_growth
FROM
(SELECT ref_date, geo, dguid, indicator, industry, authority,value * 1000000 as value
FROM cannabis_c_p.`industr_ prod`
Where industry != "Cannabis cultivation industry" AND authority != 'Licensed source' and geo = 'Canada'
Order by 4,1)unlic_ri
Left JOin
cannabis_c_p.canada_indus_retail_unlic_value_growth unlic_rig
ON unlic_rig.ref_date = unlic_ri.ref_date and unlic_ri.indicator = unlic_rig.indicator
ORDER BY 4,1;


-- Union of licensed and unlicensed retail and culivations
SELECT l_cci.ref_date, l_cci.geo, l_cci.dguid, l_cci.indicator, l_cci.industry, l_cci.authority,
l_cci.value, l_ccig.value_growth, (l_ccig.value_growth)/l_cci.value as year_percent_growth
FROM
(SELECT ref_date, geo, dguid, indicator, industry, authority,value * 1000000 as value
FROM cannabis_c_p.`industr_ prod`
Where industry = "Cannabis cultivation industry" AND authority = 'Licensed source' and geo = 'Canada'
Order by 4,1) l_cci
LEFT JOIN
cannabis_c_p.canada_indus_cult_lic_value_growth l_ccig
on l_ccig.ref_date = l_cci.ref_date and l_cci.indicator = l_ccig.indicator
UNION
SELECT ul_cci.ref_date, ul_cci.geo, ul_cci.dguid, ul_cci.indicator, ul_cci.industry, ul_cci.authority,
ul_cci.value, ul_ccig.value_growth, (ul_ccig.value_growth)/ul_cci.value as percent_growth
FROM
(SELECT ref_date, geo, dguid, indicator, industry, authority,value * 1000000 as value
FROM cannabis_c_p.`industr_ prod`
Where industry = "Cannabis cultivation industry" AND authority != 'Licensed source' and geo = 'Canada'
Order by 4,1) ul_cci
LEFT JOIN
cannabis_c_p.canada_cult_indus_unlic_value_growth ul_ccig
on ul_ccig.ref_date = ul_cci.ref_date and ul_cci.indicator = ul_ccig.indicator
UNION
SELECT lic_ri.ref_date, lic_ri.geo, lic_ri.dguid, lic_ri.indicator, lic_ri.industry, lic_ri.authority,
lic_ri.value, lic_rig.value_growth,(lic_rig.value_growth)/lic_ri.value as percent_growth
FROM
(SELECT ref_date, geo, dguid, indicator, industry, authority,value * 1000000 as value
FROM cannabis_c_p.`industr_ prod`
Where industry != "Cannabis cultivation industry" AND authority = 'Licensed source' and geo = 'Canada'
Order by 4,1)lic_ri
Left JOin
cannabis_c_p.canada_indus_retail_lic_value_growth lic_rig
ON lic_rig.ref_date = lic_ri.ref_date and lic_ri.indicator = lic_rig.indicator
UNION
SELECT unlic_ri.ref_date, unlic_ri.geo, unlic_ri.dguid, unlic_ri.indicator, unlic_ri.industry, unlic_ri.authority,
unlic_ri.value, unlic_rig.value_growth, (unlic_rig.value_growth)/unlic_ri.value as percent_growth 
FROM
(SELECT ref_date, geo, dguid, indicator, industry, authority,value * 1000000 as value
FROM cannabis_c_p.`industr_ prod`
Where industry != "Cannabis cultivation industry" AND authority != 'Licensed source' and geo = 'Canada'
Order by 4,1)unlic_ri
Left JOin
cannabis_c_p.canada_indus_retail_unlic_value_growth unlic_rig
ON unlic_rig.ref_date = unlic_ri.ref_date and unlic_ri.indicator = unlic_rig.indicator
ORDER BY 4,5,6,1;