SELECT * 
from cannabis_c_p.income
ORDER by 1;
SELECT  DISTINCT(dguid)
FROM cannabis_c_p.income;
SELECT DISTINCT(estimate)
FROM cannabis_c_p.income;
SELECT distinct(industry) FROM cannabis_c_p.income;
-- Medical cannabis industry Non-medical cannabis industry
SELECT * 
from cannabis_c_p.income
WHERE value > 0
ORDER by 1 ASC;
## estimate types
-- Gross domestic product (GDP) medical vs non-medical industries
SELECT ygdp.ref_date,ygdp.geo, ygdp.yearly_GDP_Medical_Cannabis_industry ,gdp_growth.Medical_Cannabis_GDP_Growth, gdp_growth.Medical_cannabis_GDP_percentage_increase ,
 ygdp.yearly_GDP_Non_Medical_Cannabis_industry,gdp_growth.Non_Medical_Cannabis_GDP_Growth, gdp_growth.Non_Medical_cannabis_GDP_percentage_increase 
FROM cannabis_c_p.yearly_GDP ygdp LEFT JOIN (SELECT gdp1.ref_date, gdp1.geo, gdp1.estimate, gdp1.yearly_GDP_Medical_Cannabis_industry,
(gdp2.yearly_GDP_Medical_Cannabis_industry-gdp1.yearly_GDP_Medical_Cannabis_industry) as Medical_Cannabis_GDP_Growth,round(((gdp2.yearly_GDP_Medical_Cannabis_industry-gdp1.yearly_GDP_Medical_Cannabis_industry)/gdp1.yearly_GDP_Medical_Cannabis_industry),2) as Medical_cannabis_GDP_percentage_increase,
gdp1.yearly_GDP_Non_Medical_Cannabis_industry,(gdp2.yearly_GDP_Non_Medical_Cannabis_industry-gdp1.yearly_GDP_Non_Medical_Cannabis_industry) 
as Non_Medical_Cannabis_GDP_Growth, round(((gdp2.yearly_GDP_Non_Medical_Cannabis_industry-gdp1.yearly_GDP_Non_Medical_Cannabis_industry)/gdp1.yearly_GDP_Non_Medical_Cannabis_industry),2) as Non_Medical_cannabis_GDP_percentage_increase 
FROM cannabis_c_p.yearly_GDP gdp1
JOIN cannabis_c_p.yearly_GDP gdp2
ON gdp2.ref_date = gdp1.ref_date +1
AND gdp1.estimate = gdp2.estimate) gdp_growth
ON ygdp.ref_date = gdp_growth.ref_date ;

-- Compensation of employees medical vs non-medical industries
SELECT ec1.ref_date, ec1.geo, ec1.estimate, ec1.Medical_Cannabis_industry_Employee_Comp, 
emdp_dif.medical_industry_compensation_growth, (emdp_dif.medical_industry_compensation_growth/ec1.Medical_Cannabis_industry_Employee_Comp) as percentage_comp_growth_medical,
ec1.Non_Medical_Cannabis_industry_Employee_Comp, emdp_dif.non_medical_industry_compensation_growth, 
(emdp_dif.non_medical_industry_compensation_growth/ec1.Non_Medical_Cannabis_industry_Employee_Comp) as percentage_comp_growth_non_medical
FROM cannabis_c_p.employee_comp ec1 LEFT JOIN (SELECT emp_comp1.ref_date, emp_comp1.geo, emp_comp1.estimate, emp_comp1.Medical_Cannabis_industry_Employee_Comp,
(emp_comp2.Medical_Cannabis_industry_Employee_Comp - emp_comp1.Medical_Cannabis_industry_Employee_Comp) as medical_industry_compensation_growth,
emp_comp1.Non_Medical_Cannabis_industry_Employee_Comp,
(emp_comp2.Non_Medical_Cannabis_industry_Employee_Comp - emp_comp1.Non_Medical_Cannabis_industry_Employee_Comp) as non_medical_industry_compensation_growth
FROM cannabis_c_p.employee_comp emp_comp1
JOIN cannabis_c_p.employee_comp emp_comp2
ON emp_comp2.ref_date = emp_comp1.ref_date +1
AND emp_comp1.estimate = emp_comp2.estimate) emdp_dif
ON ec1.ref_date=emdp_dif.ref_date;

-- GDP and Employee Compensation
SELECT gdpcan.ref_date, gdpcan.geo, gdpcan.yearly_GDP_Medical_Cannabis_industry, gdpcan.Medical_Cannabis_GDP_Growth, gdpcan.Medical_cannabis_GDP_percentage_increase,
comp_can.Medical_Cannabis_industry_Employee_Comp, comp_can.medical_industry_compensation_growth, comp_can.percentage_comp_growth_medical,
gdpcan.yearly_GDP_Non_Medical_Cannabis_industry, gdpcan.Non_Medical_Cannabis_GDP_Growth , gdpcan.Non_Medical_cannabis_GDP_percentage_increase, comp_can.Non_Medical_Cannabis_industry_Employee_Comp , comp_can.non_medical_industry_compensation_growth , comp_can.percentage_comp_growth_non_medical
 FROM (SELECT ygdp.ref_date,ygdp.geo, ygdp.yearly_GDP_Medical_Cannabis_industry ,gdp_growth.Medical_Cannabis_GDP_Growth, gdp_growth.Medical_cannabis_GDP_percentage_increase ,
 ygdp.yearly_GDP_Non_Medical_Cannabis_industry,gdp_growth.Non_Medical_Cannabis_GDP_Growth, gdp_growth.Non_Medical_cannabis_GDP_percentage_increase 
FROM cannabis_c_p.yearly_GDP ygdp LEFT JOIN (SELECT gdp1.ref_date, gdp1.geo, gdp1.estimate, gdp1.yearly_GDP_Medical_Cannabis_industry,
(gdp2.yearly_GDP_Medical_Cannabis_industry-gdp1.yearly_GDP_Medical_Cannabis_industry) as Medical_Cannabis_GDP_Growth,round(((gdp2.yearly_GDP_Medical_Cannabis_industry-gdp1.yearly_GDP_Medical_Cannabis_industry)/gdp1.yearly_GDP_Medical_Cannabis_industry),2) as Medical_cannabis_GDP_percentage_increase,
gdp1.yearly_GDP_Non_Medical_Cannabis_industry,(gdp2.yearly_GDP_Non_Medical_Cannabis_industry-gdp1.yearly_GDP_Non_Medical_Cannabis_industry) 
as Non_Medical_Cannabis_GDP_Growth, round(((gdp2.yearly_GDP_Non_Medical_Cannabis_industry-gdp1.yearly_GDP_Non_Medical_Cannabis_industry)/gdp1.yearly_GDP_Non_Medical_Cannabis_industry),2) as Non_Medical_cannabis_GDP_percentage_increase 
FROM cannabis_c_p.yearly_GDP gdp1
JOIN cannabis_c_p.yearly_GDP gdp2
ON gdp2.ref_date = gdp1.ref_date +1
AND gdp1.estimate = gdp2.estimate) gdp_growth
ON ygdp.ref_date = gdp_growth.ref_date) gdpcan JOIN (SELECT ec1.ref_date, ec1.geo, ec1.estimate, ec1.Medical_Cannabis_industry_Employee_Comp, 
emdp_dif.medical_industry_compensation_growth, (emdp_dif.medical_industry_compensation_growth/ec1.Medical_Cannabis_industry_Employee_Comp) as percentage_comp_growth_medical,
ec1.Non_Medical_Cannabis_industry_Employee_Comp, emdp_dif.non_medical_industry_compensation_growth, 
(emdp_dif.non_medical_industry_compensation_growth/ec1.Non_Medical_Cannabis_industry_Employee_Comp) as percentage_comp_growth_non_medical
FROM cannabis_c_p.employee_comp ec1 LEFT JOIN (SELECT emp_comp1.ref_date, emp_comp1.geo, emp_comp1.estimate, emp_comp1.Medical_Cannabis_industry_Employee_Comp,
(emp_comp2.Medical_Cannabis_industry_Employee_Comp - emp_comp1.Medical_Cannabis_industry_Employee_Comp) as medical_industry_compensation_growth,
emp_comp1.Non_Medical_Cannabis_industry_Employee_Comp,
(emp_comp2.Non_Medical_Cannabis_industry_Employee_Comp - emp_comp1.Non_Medical_Cannabis_industry_Employee_Comp) as non_medical_industry_compensation_growth
FROM cannabis_c_p.employee_comp emp_comp1
JOIN cannabis_c_p.employee_comp emp_comp2
ON emp_comp2.ref_date = emp_comp1.ref_date +1
AND emp_comp1.estimate = emp_comp2.estimate) emdp_dif
ON ec1.ref_date=emdp_dif.ref_date) comp_can ON 
gdpcan.ref_date = comp_can.ref_date;

-- Gross operating surplus medical vs non-medical industries

-- Mixed income medical vs non-medical industries
SELECT medical.ref_date,medical.geo,medical.estimate, medical.value *1000000 as Medical_Cannabis_Industry_Total_Mixed_Income, 
non_medical.industry, non_medical.value *1000000 as Non_Medical_Cannabis_Industry_Total_Mixed_Income
FROM cannabis_c_p.income medical
JOIN cannabis_c_p.income non_medical
ON medical.ref_date = non_medical.ref_date
AND medical.estimate = non_medical.estimate
WHERE 
medical.estimate = "Mixed income" AND non_medical.estimate = "Mixed income"
AND medical.industry = "Medical cannabis industry" AND non_medical.industry = "Non-medical cannabis industry"
ORDER BY 1;

## Create CTE and join with self and calculate difference in Mixed income per year to show yearly income growth
WITH mixed_income (ref_date,geo,estimate, Medical_Cannabis_Industry_Total_Mixed_Income, industry, Non_Medical_Cannabis_Industry_Total_Mixed_Income) 
as 
(SELECT medical.ref_date,medical.geo,medical.estimate, medical.value *1000000 as Medical_Cannabis_Industry_Total_Mixed_Income, 
non_medical.industry, non_medical.value *1000000 as Non_Medical_Cannabis_Industry_Total_Mixed_Income
FROM cannabis_c_p.income medical
JOIN cannabis_c_p.income non_medical
ON medical.ref_date = non_medical.ref_date
AND medical.estimate = non_medical.estimate
WHERE 
medical.estimate = "Mixed income" AND non_medical.estimate = "Mixed income"
AND medical.industry = "Medical cannabis industry" AND non_medical.industry = "Non-medical cannabis industry")
SELECT mi_1.ref_date,mi_1.geo,mi_1.estimate, mi_1.Medical_Cannabis_Industry_Total_Mixed_Income,
(mi_2.Medical_Cannabis_Industry_Total_Mixed_Income-mi_1.Medical_Cannabis_Industry_Total_Mixed_Income) as Med_cannabis_income_change, round((mi_2.Medical_Cannabis_Industry_Total_Mixed_Income-mi_1.Medical_Cannabis_Industry_Total_Mixed_Income)/mi_1.Medical_Cannabis_Industry_Total_Mixed_Income ,2) as Medical_Cannabis_income_percent_change,
mi_1.Non_Medical_Cannabis_Industry_Total_Mixed_Income,
(mi_2.Non_Medical_Cannabis_Industry_Total_Mixed_Income-mi_1.Non_Medical_Cannabis_Industry_Total_Mixed_Income) as Non_Med_cannabis_income_change, round((mi_2.Non_Medical_Cannabis_Industry_Total_Mixed_Income-mi_1.Non_Medical_Cannabis_Industry_Total_Mixed_Income)/mi_1.Non_Medical_Cannabis_Industry_Total_Mixed_Income,2) as Non_Medical_Cannabis_income_percent_change 
FROM mixed_income mi_1
JOIN mixed_income mi_2
ON mi_2.ref_date = mi_1.ref_date + 1
AND mi_1.estimate = mi_2.estimate;

SELECT *
FROM (SELECT medical.ref_date,medical.geo,medical.estimate, medical.value *1000000 as Medical_Cannabis_Industry_Total_Mixed_Income, 
non_medical.industry, non_medical.value *1000000 as Non_Medical_Cannabis_Industry_Total_Mixed_Income
FROM cannabis_c_p.income medical
JOIN cannabis_c_p.income non_medical
ON medical.ref_date = non_medical.ref_date
AND medical.estimate = non_medical.estimate
WHERE 
medical.estimate = "Mixed income" AND non_medical.estimate = "Mixed income"
AND medical.industry = "Medical cannabis industry" AND non_medical.industry = "Non-medical cannabis industry") m_incom
LEFT JOIN
(SELECT  mixed_inc.ref_date,mixed_inc.geo,mixed_inc.estimate, mixed_inc.Medical_Cannabis_Industry_Total_Mixed_Income,
(mixed_inc2.Medical_Cannabis_Industry_Total_Mixed_Income - mixed_inc.Medical_Cannabis_Industry_Total_Mixed_Income) as Medical_Canna_industr_income_growth,
 mixed_inc.Non_Medical_Cannabis_Industry_Total_Mixed_Income, 
 (mixed_inc2.Non_Medical_Cannabis_Industry_Total_Mixed_Income - mixed_inc.Non_Medical_Cannabis_Industry_Total_Mixed_Income) Non_Medical_Canna_industr_income_growth
FROM (SELECT medical.ref_date,medical.geo,medical.estimate, medical.value *1000000 as Medical_Cannabis_Industry_Total_Mixed_Income, 
non_medical.industry, non_medical.value *1000000 as Non_Medical_Cannabis_Industry_Total_Mixed_Income
FROM cannabis_c_p.income medical
JOIN cannabis_c_p.income non_medical
ON medical.ref_date = non_medical.ref_date
AND medical.estimate = non_medical.estimate
WHERE 
medical.estimate = "Mixed income" AND non_medical.estimate = "Mixed income"
AND medical.industry = "Medical cannabis industry" AND non_medical.industry = "Non-medical cannabis industry") mixed_inc 
join 
(SELECT medical.ref_date,medical.geo,medical.estimate, medical.value *1000000 as Medical_Cannabis_Industry_Total_Mixed_Income, 
non_medical.industry, non_medical.value *1000000 as Non_Medical_Cannabis_Industry_Total_Mixed_Income
FROM cannabis_c_p.income medical
JOIN cannabis_c_p.income non_medical
ON medical.ref_date = non_medical.ref_date
AND medical.estimate = non_medical.estimate
WHERE 
medical.estimate = "Mixed income" AND non_medical.estimate = "Mixed income"
AND medical.industry = "Medical cannabis industry" AND non_medical.industry = "Non-medical cannabis industry") mixed_inc2 ON 
mixed_inc2.ref_date = mixed_inc.ref_date + 1) mincome_g
ON  mincome_g.ref_date = m_incom.ref_date;

-- Unable to do a left join so creating table for mixed income
DROP TABLE if exists cannabis_c_p.mixed_income;
CREATE TABLE cannabis_c_p.mixed_income
(ref_date int , geo varchar (100),estimate varchar (100), Medical_Cannabis_Industry_Total_Mixed_Income double, Non_Medical_Cannabis_Industry_Total_Mixed_Income double);

INSERT INTO cannabis_c_p.mixed_income
SELECT medical.ref_date,medical.geo,medical.estimate, medical.value *1000000 as Medical_Cannabis_Industry_Total_Mixed_Income,  non_medical.value *1000000 as Non_Medical_Cannabis_Industry_Total_Mixed_Income
FROM cannabis_c_p.income medical
JOIN cannabis_c_p.income non_medical
ON medical.ref_date = non_medical.ref_date
AND medical.estimate = non_medical.estimate
WHERE 
medical.estimate = "Mixed income" AND non_medical.estimate = "Mixed income"
AND medical.industry = "Medical cannabis industry" AND non_medical.industry = "Non-medical cannabis industry";

SELECT m_incom.ref_date, m_incom.geo , m_incom.estimate , m_incom.Medical_Cannabis_Industry_Total_Mixed_Income ,mincome_g.Medical_Canna_industr_income_growth ,
 m_incom.Non_Medical_Cannabis_Industry_Total_Mixed_Income ,mincome_g.Non_Medical_Canna_industr_income_growth
FROM cannabis_c_p.mixed_income m_incom
LEFT JOIN
(SELECT  mixed_inc.ref_date,mixed_inc.geo,mixed_inc.estimate, mixed_inc.Medical_Cannabis_Industry_Total_Mixed_Income,
(mixed_inc2.Medical_Cannabis_Industry_Total_Mixed_Income - mixed_inc.Medical_Cannabis_Industry_Total_Mixed_Income) as Medical_Canna_industr_income_growth,
 mixed_inc.Non_Medical_Cannabis_Industry_Total_Mixed_Income, 
 (mixed_inc2.Non_Medical_Cannabis_Industry_Total_Mixed_Income - mixed_inc.Non_Medical_Cannabis_Industry_Total_Mixed_Income) Non_Medical_Canna_industr_income_growth
FROM cannabis_c_p.mixed_income mixed_inc 
join
cannabis_c_p.mixed_income mixed_inc2
 ON 
mixed_inc2.ref_date = mixed_inc.ref_date + 1) mincome_g
ON  mincome_g.ref_date = m_incom.ref_date 
Order by 1;

-- MIXED Income and gdp join

SELECT gdp.ref_date , gdp.geo ,
gdp.yearly_GDP_Medical_Cannabis_industry , gdp.Medical_Cannabis_GDP_Growth ,gdp.Medical_cannabis_GDP_percentage_increase,
 m_income.Medical_Cannabis_Industry_Total_Mixed_Income, m_income.Medical_Canna_industr_income_growth , 
 gdp.yearly_GDP_Non_Medical_Cannabis_industry , gdp.Non_Medical_Cannabis_GDP_Growth , gdp.Non_Medical_cannabis_GDP_percentage_increase , m_income.Non_Medical_Cannabis_Industry_Total_Mixed_Income , m_income.Non_Medical_Canna_industr_income_growth
FROM (SELECT ygdp.ref_date,ygdp.geo, ygdp.yearly_GDP_Medical_Cannabis_industry ,gdp_growth.Medical_Cannabis_GDP_Growth, gdp_growth.Medical_cannabis_GDP_percentage_increase ,
 ygdp.yearly_GDP_Non_Medical_Cannabis_industry,gdp_growth.Non_Medical_Cannabis_GDP_Growth, gdp_growth.Non_Medical_cannabis_GDP_percentage_increase 
FROM cannabis_c_p.yearly_GDP ygdp LEFT JOIN (SELECT gdp1.ref_date, gdp1.geo, gdp1.estimate, gdp1.yearly_GDP_Medical_Cannabis_industry,
(gdp2.yearly_GDP_Medical_Cannabis_industry-gdp1.yearly_GDP_Medical_Cannabis_industry) as Medical_Cannabis_GDP_Growth,round(((gdp2.yearly_GDP_Medical_Cannabis_industry-gdp1.yearly_GDP_Medical_Cannabis_industry)/gdp1.yearly_GDP_Medical_Cannabis_industry),2) as Medical_cannabis_GDP_percentage_increase,
gdp1.yearly_GDP_Non_Medical_Cannabis_industry,(gdp2.yearly_GDP_Non_Medical_Cannabis_industry-gdp1.yearly_GDP_Non_Medical_Cannabis_industry) 
as Non_Medical_Cannabis_GDP_Growth, round(((gdp2.yearly_GDP_Non_Medical_Cannabis_industry-gdp1.yearly_GDP_Non_Medical_Cannabis_industry)/gdp1.yearly_GDP_Non_Medical_Cannabis_industry),2) as Non_Medical_cannabis_GDP_percentage_increase 
FROM cannabis_c_p.yearly_GDP gdp1
JOIN cannabis_c_p.yearly_GDP gdp2
ON gdp2.ref_date = gdp1.ref_date +1
AND gdp1.estimate = gdp2.estimate) gdp_growth
ON ygdp.ref_date = gdp_growth.ref_date) gdp 
JOIN
(SELECT m_incom.ref_date, m_incom.geo , m_incom.estimate , m_incom.Medical_Cannabis_Industry_Total_Mixed_Income ,mincome_g.Medical_Canna_industr_income_growth ,
 m_incom.Non_Medical_Cannabis_Industry_Total_Mixed_Income ,mincome_g.Non_Medical_Canna_industr_income_growth
FROM cannabis_c_p.mixed_income m_incom
LEFT JOIN
(SELECT  mixed_inc.ref_date,mixed_inc.geo,mixed_inc.estimate, mixed_inc.Medical_Cannabis_Industry_Total_Mixed_Income,
(mixed_inc2.Medical_Cannabis_Industry_Total_Mixed_Income - mixed_inc.Medical_Cannabis_Industry_Total_Mixed_Income) as Medical_Canna_industr_income_growth,
 mixed_inc.Non_Medical_Cannabis_Industry_Total_Mixed_Income, 
 (mixed_inc2.Non_Medical_Cannabis_Industry_Total_Mixed_Income - mixed_inc.Non_Medical_Cannabis_Industry_Total_Mixed_Income) Non_Medical_Canna_industr_income_growth
FROM cannabis_c_p.mixed_income mixed_inc 
join
cannabis_c_p.mixed_income mixed_inc2
 ON 
mixed_inc2.ref_date = mixed_inc.ref_date + 1) mincome_g
ON  mincome_g.ref_date = m_incom.ref_date
) m_income 
ON   m_income.ref_date =  gdp.ref_date;

-- create view for above query 

-- Yearly GDP + Yearly income + staff compensation
SELECT gdp_income.ref_date ,gdp_income.geo , 
gdp_income.yearly_GDP_Medical_Cannabis_industry , gdp_income.Medical_Cannabis_GDP_Growth , gdp_income.Medical_cannabis_GDP_percentage_increase , 
gdp_income.Medical_Cannabis_Industry_Total_Mixed_Income , gdp_income.Medical_Canna_industr_income_growth ,
gdp_comp.Medical_Cannabis_industry_Employee_Comp ,gdp_comp.medical_industry_compensation_growth , gdp_comp.percentage_comp_growth_medical,
 gdp_income.yearly_GDP_Non_Medical_Cannabis_industry, gdp_income.Non_Medical_Cannabis_GDP_Growth , gdp_income.Non_Medical_cannabis_GDP_percentage_increase ,
 gdp_income.Non_Medical_Cannabis_Industry_Total_Mixed_Income, gdp_income.Non_Medical_Canna_industr_income_growth , gdp_comp.Non_Medical_Cannabis_industry_Employee_Comp , gdp_comp.non_medical_industry_compensation_growth , gdp_comp.percentage_comp_growth_non_medical
FROM 
(SELECT gdp.ref_date , gdp.geo ,
gdp.yearly_GDP_Medical_Cannabis_industry , gdp.Medical_Cannabis_GDP_Growth ,gdp.Medical_cannabis_GDP_percentage_increase,
 m_income.Medical_Cannabis_Industry_Total_Mixed_Income, m_income.Medical_Canna_industr_income_growth , 
 gdp.yearly_GDP_Non_Medical_Cannabis_industry , gdp.Non_Medical_Cannabis_GDP_Growth , gdp.Non_Medical_cannabis_GDP_percentage_increase , m_income.Non_Medical_Cannabis_Industry_Total_Mixed_Income , m_income.Non_Medical_Canna_industr_income_growth
FROM (SELECT ygdp.ref_date,ygdp.geo, ygdp.yearly_GDP_Medical_Cannabis_industry ,gdp_growth.Medical_Cannabis_GDP_Growth, gdp_growth.Medical_cannabis_GDP_percentage_increase ,
 ygdp.yearly_GDP_Non_Medical_Cannabis_industry,gdp_growth.Non_Medical_Cannabis_GDP_Growth, gdp_growth.Non_Medical_cannabis_GDP_percentage_increase 
FROM cannabis_c_p.yearly_GDP ygdp LEFT JOIN (SELECT gdp1.ref_date, gdp1.geo, gdp1.estimate, gdp1.yearly_GDP_Medical_Cannabis_industry,
(gdp2.yearly_GDP_Medical_Cannabis_industry-gdp1.yearly_GDP_Medical_Cannabis_industry) as Medical_Cannabis_GDP_Growth,round(((gdp2.yearly_GDP_Medical_Cannabis_industry-gdp1.yearly_GDP_Medical_Cannabis_industry)/gdp1.yearly_GDP_Medical_Cannabis_industry),2) as Medical_cannabis_GDP_percentage_increase,
gdp1.yearly_GDP_Non_Medical_Cannabis_industry,(gdp2.yearly_GDP_Non_Medical_Cannabis_industry-gdp1.yearly_GDP_Non_Medical_Cannabis_industry) 
as Non_Medical_Cannabis_GDP_Growth, round(((gdp2.yearly_GDP_Non_Medical_Cannabis_industry-gdp1.yearly_GDP_Non_Medical_Cannabis_industry)/gdp1.yearly_GDP_Non_Medical_Cannabis_industry),2) as Non_Medical_cannabis_GDP_percentage_increase 
FROM cannabis_c_p.yearly_GDP gdp1
JOIN cannabis_c_p.yearly_GDP gdp2
ON gdp2.ref_date = gdp1.ref_date +1
AND gdp1.estimate = gdp2.estimate) gdp_growth
ON ygdp.ref_date = gdp_growth.ref_date) gdp 
JOIN
(SELECT m_incom.ref_date, m_incom.geo , m_incom.estimate , m_incom.Medical_Cannabis_Industry_Total_Mixed_Income ,mincome_g.Medical_Canna_industr_income_growth ,
 m_incom.Non_Medical_Cannabis_Industry_Total_Mixed_Income ,mincome_g.Non_Medical_Canna_industr_income_growth
FROM cannabis_c_p.mixed_income m_incom
LEFT JOIN
(SELECT  mixed_inc.ref_date,mixed_inc.geo,mixed_inc.estimate, mixed_inc.Medical_Cannabis_Industry_Total_Mixed_Income,
(mixed_inc2.Medical_Cannabis_Industry_Total_Mixed_Income - mixed_inc.Medical_Cannabis_Industry_Total_Mixed_Income) as Medical_Canna_industr_income_growth,
 mixed_inc.Non_Medical_Cannabis_Industry_Total_Mixed_Income, 
 (mixed_inc2.Non_Medical_Cannabis_Industry_Total_Mixed_Income - mixed_inc.Non_Medical_Cannabis_Industry_Total_Mixed_Income) Non_Medical_Canna_industr_income_growth
FROM cannabis_c_p.mixed_income mixed_inc 
join
cannabis_c_p.mixed_income mixed_inc2
 ON 
mixed_inc2.ref_date = mixed_inc.ref_date + 1) mincome_g
ON  mincome_g.ref_date = m_incom.ref_date
) m_income 
ON   m_income.ref_date =  gdp.ref_date
) gdp_income
JOIN
(SELECT gdpcan.ref_date, gdpcan.geo, gdpcan.yearly_GDP_Medical_Cannabis_industry, gdpcan.Medical_Cannabis_GDP_Growth, gdpcan.Medical_cannabis_GDP_percentage_increase,
comp_can.Medical_Cannabis_industry_Employee_Comp, comp_can.medical_industry_compensation_growth, comp_can.percentage_comp_growth_medical,
gdpcan.yearly_GDP_Non_Medical_Cannabis_industry, gdpcan.Non_Medical_Cannabis_GDP_Growth , gdpcan.Non_Medical_cannabis_GDP_percentage_increase, comp_can.Non_Medical_Cannabis_industry_Employee_Comp , comp_can.non_medical_industry_compensation_growth , comp_can.percentage_comp_growth_non_medical
 FROM (SELECT ygdp.ref_date,ygdp.geo, ygdp.yearly_GDP_Medical_Cannabis_industry ,gdp_growth.Medical_Cannabis_GDP_Growth, gdp_growth.Medical_cannabis_GDP_percentage_increase ,
 ygdp.yearly_GDP_Non_Medical_Cannabis_industry,gdp_growth.Non_Medical_Cannabis_GDP_Growth, gdp_growth.Non_Medical_cannabis_GDP_percentage_increase 
FROM cannabis_c_p.yearly_GDP ygdp LEFT JOIN (SELECT gdp1.ref_date, gdp1.geo, gdp1.estimate, gdp1.yearly_GDP_Medical_Cannabis_industry,
(gdp2.yearly_GDP_Medical_Cannabis_industry-gdp1.yearly_GDP_Medical_Cannabis_industry) as Medical_Cannabis_GDP_Growth,round(((gdp2.yearly_GDP_Medical_Cannabis_industry-gdp1.yearly_GDP_Medical_Cannabis_industry)/gdp1.yearly_GDP_Medical_Cannabis_industry)*100,2) as Medical_cannabis_GDP_percentage_increase,
gdp1.yearly_GDP_Non_Medical_Cannabis_industry,(gdp2.yearly_GDP_Non_Medical_Cannabis_industry-gdp1.yearly_GDP_Non_Medical_Cannabis_industry) 
as Non_Medical_Cannabis_GDP_Growth, round(((gdp2.yearly_GDP_Non_Medical_Cannabis_industry-gdp1.yearly_GDP_Non_Medical_Cannabis_industry)/gdp1.yearly_GDP_Non_Medical_Cannabis_industry)*100,2) as Non_Medical_cannabis_GDP_percentage_increase 
FROM cannabis_c_p.yearly_GDP gdp1
JOIN cannabis_c_p.yearly_GDP gdp2
ON gdp2.ref_date = gdp1.ref_date +1
AND gdp1.estimate = gdp2.estimate) gdp_growth
ON ygdp.ref_date = gdp_growth.ref_date) gdpcan JOIN (SELECT ec1.ref_date, ec1.geo, ec1.estimate, ec1.Medical_Cannabis_industry_Employee_Comp, 
emdp_dif.medical_industry_compensation_growth, (emdp_dif.medical_industry_compensation_growth/ec1.Medical_Cannabis_industry_Employee_Comp ) as percentage_comp_growth_medical,
ec1.Non_Medical_Cannabis_industry_Employee_Comp, emdp_dif.non_medical_industry_compensation_growth, 
(emdp_dif.non_medical_industry_compensation_growth/ec1.Non_Medical_Cannabis_industry_Employee_Comp) as percentage_comp_growth_non_medical
FROM cannabis_c_p.employee_comp ec1 LEFT JOIN (SELECT emp_comp1.ref_date, emp_comp1.geo, emp_comp1.estimate, emp_comp1.Medical_Cannabis_industry_Employee_Comp,
(emp_comp2.Medical_Cannabis_industry_Employee_Comp - emp_comp1.Medical_Cannabis_industry_Employee_Comp) as medical_industry_compensation_growth,
emp_comp1.Non_Medical_Cannabis_industry_Employee_Comp,
(emp_comp2.Non_Medical_Cannabis_industry_Employee_Comp - emp_comp1.Non_Medical_Cannabis_industry_Employee_Comp) as non_medical_industry_compensation_growth
FROM cannabis_c_p.employee_comp emp_comp1
JOIN cannabis_c_p.employee_comp emp_comp2
ON emp_comp2.ref_date = emp_comp1.ref_date +1
AND emp_comp1.estimate = emp_comp2.estimate) emdp_dif
ON ec1.ref_date=emdp_dif.ref_date) comp_can ON 
gdpcan.ref_date = comp_can.ref_date) gdp_comp
on gdp_income.ref_date = gdp_comp.ref_date;
-- create view for above query 
DROP VIEW IF EXISTS cannabis_c_p.canada_cannabis_income;
CREATE VIEW cannabis_c_p.canada_cannabis_income as
SELECT gdp_income.ref_date ,gdp_income.geo , 
gdp_income.yearly_GDP_Medical_Cannabis_industry , gdp_income.Medical_Cannabis_GDP_Growth , gdp_income.Medical_cannabis_GDP_percentage_increase , 
gdp_income.Medical_Cannabis_Industry_Total_Mixed_Income , gdp_income.Medical_Canna_industr_income_growth ,
gdp_comp.Medical_Cannabis_industry_Employee_Comp ,gdp_comp.medical_industry_compensation_growth , gdp_comp.percentage_comp_growth_medical,
 gdp_income.yearly_GDP_Non_Medical_Cannabis_industry, gdp_income.Non_Medical_Cannabis_GDP_Growth , gdp_income.Non_Medical_cannabis_GDP_percentage_increase ,
 gdp_income.Non_Medical_Cannabis_Industry_Total_Mixed_Income, gdp_income.Non_Medical_Canna_industr_income_growth , gdp_comp.Non_Medical_Cannabis_industry_Employee_Comp , gdp_comp.non_medical_industry_compensation_growth , gdp_comp.percentage_comp_growth_non_medical
FROM 
(SELECT gdp.ref_date , gdp.geo ,
gdp.yearly_GDP_Medical_Cannabis_industry , gdp.Medical_Cannabis_GDP_Growth ,gdp.Medical_cannabis_GDP_percentage_increase,
 m_income.Medical_Cannabis_Industry_Total_Mixed_Income, m_income.Medical_Canna_industr_income_growth , 
 gdp.yearly_GDP_Non_Medical_Cannabis_industry , gdp.Non_Medical_Cannabis_GDP_Growth , gdp.Non_Medical_cannabis_GDP_percentage_increase , m_income.Non_Medical_Cannabis_Industry_Total_Mixed_Income , m_income.Non_Medical_Canna_industr_income_growth
FROM (SELECT ygdp.ref_date,ygdp.geo, ygdp.yearly_GDP_Medical_Cannabis_industry ,gdp_growth.Medical_Cannabis_GDP_Growth, gdp_growth.Medical_cannabis_GDP_percentage_increase ,
 ygdp.yearly_GDP_Non_Medical_Cannabis_industry,gdp_growth.Non_Medical_Cannabis_GDP_Growth, gdp_growth.Non_Medical_cannabis_GDP_percentage_increase 
FROM cannabis_c_p.yearly_GDP ygdp LEFT JOIN (SELECT gdp1.ref_date, gdp1.geo, gdp1.estimate, gdp1.yearly_GDP_Medical_Cannabis_industry,
(gdp2.yearly_GDP_Medical_Cannabis_industry-gdp1.yearly_GDP_Medical_Cannabis_industry) as Medical_Cannabis_GDP_Growth,round(((gdp2.yearly_GDP_Medical_Cannabis_industry-gdp1.yearly_GDP_Medical_Cannabis_industry)/gdp1.yearly_GDP_Medical_Cannabis_industry),2) as Medical_cannabis_GDP_percentage_increase,
gdp1.yearly_GDP_Non_Medical_Cannabis_industry,(gdp2.yearly_GDP_Non_Medical_Cannabis_industry-gdp1.yearly_GDP_Non_Medical_Cannabis_industry) 
as Non_Medical_Cannabis_GDP_Growth, round(((gdp2.yearly_GDP_Non_Medical_Cannabis_industry-gdp1.yearly_GDP_Non_Medical_Cannabis_industry)/gdp1.yearly_GDP_Non_Medical_Cannabis_industry),2) as Non_Medical_cannabis_GDP_percentage_increase 
FROM cannabis_c_p.yearly_GDP gdp1
JOIN cannabis_c_p.yearly_GDP gdp2
ON gdp2.ref_date = gdp1.ref_date +1
AND gdp1.estimate = gdp2.estimate) gdp_growth
ON ygdp.ref_date = gdp_growth.ref_date) gdp 
JOIN
(SELECT m_incom.ref_date, m_incom.geo , m_incom.estimate , m_incom.Medical_Cannabis_Industry_Total_Mixed_Income ,mincome_g.Medical_Canna_industr_income_growth ,
 m_incom.Non_Medical_Cannabis_Industry_Total_Mixed_Income ,mincome_g.Non_Medical_Canna_industr_income_growth
FROM cannabis_c_p.mixed_income m_incom
LEFT JOIN
(SELECT  mixed_inc.ref_date,mixed_inc.geo,mixed_inc.estimate, mixed_inc.Medical_Cannabis_Industry_Total_Mixed_Income,
(mixed_inc2.Medical_Cannabis_Industry_Total_Mixed_Income - mixed_inc.Medical_Cannabis_Industry_Total_Mixed_Income) as Medical_Canna_industr_income_growth,
 mixed_inc.Non_Medical_Cannabis_Industry_Total_Mixed_Income, 
 (mixed_inc2.Non_Medical_Cannabis_Industry_Total_Mixed_Income - mixed_inc.Non_Medical_Cannabis_Industry_Total_Mixed_Income) Non_Medical_Canna_industr_income_growth
FROM cannabis_c_p.mixed_income mixed_inc 
join
cannabis_c_p.mixed_income mixed_inc2
 ON 
mixed_inc2.ref_date = mixed_inc.ref_date + 1) mincome_g
ON  mincome_g.ref_date = m_incom.ref_date
) m_income 
ON   m_income.ref_date =  gdp.ref_date
) gdp_income
JOIN
(SELECT gdpcan.ref_date, gdpcan.geo, gdpcan.yearly_GDP_Medical_Cannabis_industry, gdpcan.Medical_Cannabis_GDP_Growth, gdpcan.Medical_cannabis_GDP_percentage_increase,
comp_can.Medical_Cannabis_industry_Employee_Comp, comp_can.medical_industry_compensation_growth, comp_can.percentage_comp_growth_medical,
gdpcan.yearly_GDP_Non_Medical_Cannabis_industry, gdpcan.Non_Medical_Cannabis_GDP_Growth , gdpcan.Non_Medical_cannabis_GDP_percentage_increase, comp_can.Non_Medical_Cannabis_industry_Employee_Comp , comp_can.non_medical_industry_compensation_growth , comp_can.percentage_comp_growth_non_medical
 FROM (SELECT ygdp.ref_date,ygdp.geo, ygdp.yearly_GDP_Medical_Cannabis_industry ,gdp_growth.Medical_Cannabis_GDP_Growth, gdp_growth.Medical_cannabis_GDP_percentage_increase ,
 ygdp.yearly_GDP_Non_Medical_Cannabis_industry,gdp_growth.Non_Medical_Cannabis_GDP_Growth, gdp_growth.Non_Medical_cannabis_GDP_percentage_increase 
FROM cannabis_c_p.yearly_GDP ygdp LEFT JOIN (SELECT gdp1.ref_date, gdp1.geo, gdp1.estimate, gdp1.yearly_GDP_Medical_Cannabis_industry,
(gdp2.yearly_GDP_Medical_Cannabis_industry-gdp1.yearly_GDP_Medical_Cannabis_industry) as Medical_Cannabis_GDP_Growth,round(((gdp2.yearly_GDP_Medical_Cannabis_industry-gdp1.yearly_GDP_Medical_Cannabis_industry)/gdp1.yearly_GDP_Medical_Cannabis_industry)*100,2) as Medical_cannabis_GDP_percentage_increase,
gdp1.yearly_GDP_Non_Medical_Cannabis_industry,(gdp2.yearly_GDP_Non_Medical_Cannabis_industry-gdp1.yearly_GDP_Non_Medical_Cannabis_industry) 
as Non_Medical_Cannabis_GDP_Growth, round(((gdp2.yearly_GDP_Non_Medical_Cannabis_industry-gdp1.yearly_GDP_Non_Medical_Cannabis_industry)/gdp1.yearly_GDP_Non_Medical_Cannabis_industry)*100,2) as Non_Medical_cannabis_GDP_percentage_increase 
FROM cannabis_c_p.yearly_GDP gdp1
JOIN cannabis_c_p.yearly_GDP gdp2
ON gdp2.ref_date = gdp1.ref_date +1
AND gdp1.estimate = gdp2.estimate) gdp_growth
ON ygdp.ref_date = gdp_growth.ref_date) gdpcan JOIN (SELECT ec1.ref_date, ec1.geo, ec1.estimate, ec1.Medical_Cannabis_industry_Employee_Comp, 
emdp_dif.medical_industry_compensation_growth, (emdp_dif.medical_industry_compensation_growth/ec1.Medical_Cannabis_industry_Employee_Comp ) as percentage_comp_growth_medical,
ec1.Non_Medical_Cannabis_industry_Employee_Comp, emdp_dif.non_medical_industry_compensation_growth, 
(emdp_dif.non_medical_industry_compensation_growth/ec1.Non_Medical_Cannabis_industry_Employee_Comp) as percentage_comp_growth_non_medical
FROM cannabis_c_p.employee_comp ec1 LEFT JOIN (SELECT emp_comp1.ref_date, emp_comp1.geo, emp_comp1.estimate, emp_comp1.Medical_Cannabis_industry_Employee_Comp,
(emp_comp2.Medical_Cannabis_industry_Employee_Comp - emp_comp1.Medical_Cannabis_industry_Employee_Comp) as medical_industry_compensation_growth,
emp_comp1.Non_Medical_Cannabis_industry_Employee_Comp,
(emp_comp2.Non_Medical_Cannabis_industry_Employee_Comp - emp_comp1.Non_Medical_Cannabis_industry_Employee_Comp) as non_medical_industry_compensation_growth
FROM cannabis_c_p.employee_comp emp_comp1
JOIN cannabis_c_p.employee_comp emp_comp2
ON emp_comp2.ref_date = emp_comp1.ref_date +1
AND emp_comp1.estimate = emp_comp2.estimate) emdp_dif
ON ec1.ref_date=emdp_dif.ref_date) comp_can ON 
gdpcan.ref_date = comp_can.ref_date) gdp_comp
on gdp_income.ref_date = gdp_comp.ref_date;

-- Taxes less subsidies medical vs non-medical industries
SELECT medical.ref_date,medical.geo,medical.estimate,medical.value *1000000 as Med_Industry_Total_Taxes_less_subsidies, 
 non_medical.value *1000000 as Non_Med_Industry_Total_Taxes_less_subsidies
FROM cannabis_c_p.income medical
JOIN cannabis_c_p.income non_medical
ON medical.ref_date = non_medical.ref_date
AND medical.estimate = non_medical.estimate
WHERE 
medical.estimate = "Taxes less subsidies" AND non_medical.estimate = "Taxes less subsidies"
AND medical.industry = "Medical cannabis industry" AND non_medical.industry = "Non-medical cannabis industry"
ORDER BY 1;

## JOing taxes less subsidies and yearly_gdp
