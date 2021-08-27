SELECT * FROM cannabis_c_p.licen_indus_stats;
SELECT distinct(dguid) FROM cannabis_c_p.licen_indus_stats;
SELECT distinct(scalar_fact) FROM cannabis_c_p.licen_indus_stats;
SELECT distinct(indicator) FROM cannabis_c_p.licen_indus_stats;
SELECT distinct(uom) FROM cannabis_c_p.licen_indus_stats; ##Dollars, Kilograms, Grams per day, Number


ALTER TABLE `cannabis_c_p`.`licen_indus_stats`
CHANGE COLUMN `value` `determined_value` double NULL DEFAULT NULL;

SELECT ref_date,geo,indicator,determined_value,uom FROM cannabis_c_p.licen_indus_stats;

#cannabis weight
SELECT ref_date,geo,indicator,determined_value,uom FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%grams%";

#dollars
SELECT ref_date,geo,indicator,determined_value ,uom FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" ;

## Total Revenue $245732000
SELECT ref_date,geo,indicator,  (determined_value) FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" AND indicator not like "Total expenses" AND indicator not like "Investment" AND 
indicator not like "Construction"AND 
indicator not like "Machinery and equipment" AND 
indicator not like "Intellectual property products" AND 
indicator not like "Other investment" AND indicator not like "Producer price per gram" AND indicator not like"inventories"
AND indicator like "Total revenue";

-- calculated total revenue  - $245886619
SELECT sum(determined_value) FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" AND indicator not like "Total expenses" AND indicator not like "Investment" AND 
indicator not like "Construction"AND 
indicator not like "Machinery and equipment" AND 
indicator not like "Intellectual property products" AND 
indicator not like "Other investment" AND 
indicator not like "Producer price per gram" AND 
indicator not like"inventories" AND indicator <> "Total revenue";

## unaccounted revenue discrepencies = - 154619
SELECT ref_date,geo,indicator,(determined_value - (SELECT sum(determined_value) FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" AND indicator not like "Total expenses" AND indicator not like "Investment" AND 
indicator not like "Construction"AND 
indicator not like "Machinery and equipment" AND 
indicator not like "Intellectual property products" AND 
indicator not like "Other investment" AND 
indicator not like "Producer price per gram" AND 
indicator not like"inventories" AND indicator <> "Total revenue") ) as unaccounted_revenue,uom 
FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" AND indicator = "Total revenue"; 
-- why is - 154619 dollars missing from Total revenue recorded

SELECT  rtr.ref_date, rtr.geo , rtr.recorded_total_revenue , ctr.Calculated_total_revenue
FROM (SELECT ref_date,geo,indicator, (determined_value) recorded_total_revenue FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" AND indicator not like "Total expenses" AND indicator not like "Investment" AND 
indicator not like "Construction"AND 
indicator not like "Machinery and equipment" AND 
indicator not like "Intellectual property products" AND 
indicator not like "Other investment" AND indicator not like "Producer price per gram" AND indicator not like"inventories"
AND indicator like "Total revenue") rtr
JOIN 
(SELECT ref_date, sum(determined_value) Calculated_total_revenue FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" AND indicator not like "Total expenses" AND indicator not like "Investment" AND 
indicator not like "Construction"AND 
indicator not like "Machinery and equipment" AND 
indicator not like "Intellectual property products" AND 
indicator not like "Other investment" AND 
indicator not like "Producer price per gram" AND 
indicator not like"inventories" AND indicator <> "Total revenue") ctr
ON 
rtr.ref_date = ctr.ref_date;

##Expenses sum 267838462
SELECT ref_date, sum(determined_value) as summed_expenses FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" AND indicator not LIKE "%Cannabis for medical%" AND indicator not LIKE "Total sales"
AND indicator not LIKE "Producer%" AND indicator not LIKE "%revenue%" and indicator not LIKE "Total%" ;

-- total 302820000
SELECT ref_date,geo,indicator, determined_value as total_expense ,uom 
FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" AND indicator LIKE "Total expense%";

##Unaccounted for expenses = $34981538
SELECT ref_date,geo,indicator,(determined_value - (SELECT SUM(determined_value) as unaccounted_expenses
 FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" AND indicator not LIKE "%Cannabis for medical%" AND indicator not LIKE "Total sales"
AND indicator not LIKE "Producer%" AND indicator not LIKE "%revenue%" and indicator not LIKE "Total%" )) as unaccounted_expenses,uom 
FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" AND indicator LIKE "Total expense%";

SELECT summed_expense.ref_date ,summed_expense.geo ,summed_expense.summed_expenses , tot_expense.total_expense , tot_expense.uom
FROM (SELECT ref_date, geo, sum(determined_value) as summed_expenses, uom FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" AND indicator not LIKE "%Cannabis for medical%" AND indicator not LIKE "Total sales"
AND indicator not LIKE "Producer%" AND indicator not LIKE "%revenue%" and indicator not LIKE "Total%") summed_expense
JOIN
(SELECT ref_date,geo,indicator, determined_value as total_expense ,uom 
FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" AND indicator LIKE "Total expense%") tot_expense
ON summed_expense.ref_date = tot_expense.ref_date;

##CTE Unknown expenses
WITH unknow_expense (ref_date,geo,dguid,indicator,unaccounted_expenses,uom) 
as 
(SELECT ref_date,geo,dguid,indicator,(determined_value - (SELECT SUM(determined_value) as expenses
 FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" AND indicator not LIKE "%Cannabis for medical%" AND indicator not LIKE "Total sales"
AND indicator not LIKE "Producer%" AND indicator not LIKE "%revenue%" and indicator not LIKE "Total%" )) as unaccounted_expenses,uom 
FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" AND indicator LIKE "Total expense%")



## join revenue and expense SHowing Total revenue and expenses as well as discrepencies in calculated nd recorded value
SELECT rev.ref_date, rev.geo , rev.Calculated_total_revenue , rev.recorded_total_revenue , 
(rev.recorded_total_revenue - rev.Calculated_total_revenue ) revenue_discrepency,
exp.calculated_expenses , exp.recorded_total_expense ,
(exp.recorded_total_expense - exp.calculated_expenses) expense_discrepency , exp.uom
FROM
(SELECT  rtr.ref_date, rtr.geo , rtr.recorded_total_revenue , ctr.Calculated_total_revenue
FROM (SELECT ref_date,geo,indicator, (determined_value) recorded_total_revenue FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" AND indicator not like "Total expenses" AND indicator not like "Investment" AND 
indicator not like "Construction"AND 
indicator not like "Machinery and equipment" AND 
indicator not like "Intellectual property products" AND 
indicator not like "Other investment" AND indicator not like "Producer price per gram" AND indicator not like"inventories"
AND indicator like "Total revenue") rtr
JOIN 
(SELECT ref_date, sum(determined_value) Calculated_total_revenue FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" AND indicator not like "Total expenses" AND indicator not like "Investment" AND 
indicator not like "Construction"AND 
indicator not like "Machinery and equipment" AND 
indicator not like "Intellectual property products" AND 
indicator not like "Other investment" AND 
indicator not like "Producer price per gram" AND 
indicator not like"inventories" AND indicator <> "Total revenue") ctr
ON 
rtr.ref_date = ctr.ref_date) rev
JOIN
(SELECT summed_expense.ref_date ,summed_expense.geo ,summed_expense.calculated_expenses , tot_expense.recorded_total_expense , tot_expense.uom
FROM (SELECT ref_date, geo, sum(determined_value) as calculated_expenses, uom FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" AND indicator not LIKE "%Cannabis for medical%" AND indicator not LIKE "Total sales"
AND indicator not LIKE "Producer%" AND indicator not LIKE "%revenue%" and indicator not LIKE "Total%") summed_expense
JOIN
(SELECT ref_date,geo,indicator, determined_value as recorded_total_expense ,uom 
FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "%dollars%" AND indicator LIKE "Total expense%") tot_expense
ON summed_expense.ref_date = tot_expense.ref_date) exp
ON
rev.ref_date = exp.ref_date;



-- SELECT shipment.ref_date, shipment.dguid, shipment.geo,shipment.indicator,shipment.determined_value,shipment.uom,
-- clients.ref_date,clients.geo,clients.indicator,clients.determined_value,clients.uom,
-- liscense.ref_date,liscense.geo,liscense.indicator,liscense.determined_value,liscense.uom 
-- FROM cannabis_c_p.licen_indus_stats shipment
-- JOIN cannabis_c_p.licen_indus_stats clients 
-- ON clients.indicator = shipment.indicator
-- JOIN cannabis_c_p.licen_indus_stats liscense
-- ON liscense.indicator = clients.indicator 
-- WHERE shipment.uom LIKE "Number" AND clients.uom LIKE "Number" AND liscense.uom LIKE "Number";--
-- AND shipment.uom = liscense.uom

#number
SELECT ref_date,geo,indicator,determined_value,uom 
FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "Number";

SELECT ref_date,geo,indicator,determined_value,uom 
FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "Number" AND indicator like "Shipments to registered clients";


SELECT ref_date,geo,indicator,determined_value,uom 
FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "Number" AND indicator like "Number of cannabis for medical use licences issued";

SELECT ref_date,geo,indicator,determined_value,uom 
FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "Number" AND indicator like "Registered clients";

## join abnove three indicators 
SELECT num_ship.ref_date,num_ship.geo,
num_ship.determined_value "number_of_Shipments_to_Clients",num_lic.determined_value " Number of licensed issued"
FROM cannabis_c_p.licen_indus_stats num_ship JOIN (SELECT ref_date,geo,indicator,determined_value,uom 
FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "Number" AND indicator like "Number of cannabis for medical use licences issued")num_lic
ON num_ship.ref_date = num_lic.ref_date 
WHERE num_ship.uom LIKE "Number" AND num_ship.indicator like "Shipments to registered clients"; 

WITH client_ship (ref_date,geo,
number_of_Shipments_to_Clients, Number_of_Med_license_issued)
as 
(SELECT num_ship.ref_date,num_ship.geo,
num_ship.determined_value as number_of_Shipments_to_Clients,num_lic.determined_value as Number_of_Med_license_issued
FROM cannabis_c_p.licen_indus_stats num_ship JOIN (SELECT ref_date,geo,indicator,determined_value,uom 
FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "Number" AND indicator like "Number of cannabis for medical use licences issued")num_lic
ON num_ship.ref_date = num_lic.ref_date 
WHERE num_ship.uom LIKE "Number" AND num_ship.indicator like "Shipments to registered clients")
SELECT c_s.ref_date, c_s.geo,
 c_s.number_of_Shipments_to_Clients, rc.determined_value as number_registerd_clients, c_s.Number_of_Med_license_issued, (c_s.Number_of_Med_license_issued/rc.determined_value) as Percentage_registered_clients,
( c_s.number_of_Shipments_to_Clients/ rc.determined_value) as Approx_shipment_per_registered_cust
FROM client_ship c_s
JOIN (SELECT ref_date,geo,indicator,determined_value,uom 
FROM cannabis_c_p.licen_indus_stats
WHERE uom LIKE "Number" AND indicator like "Registered clients") rc
on rc.ref_date = c_s.ref_date
;

#medical use 2016
SELECT ref_date, geo, dguid,indicator,uom,determined_value FROM cannabis_c_p.licen_indus_stats 
WHERE indicator LIKE "%medical%" ;

SELECT weight_kg.ref_date, weight_kg.geo, weight_kg.dguid, weight_kg.indicator, 
weight_kg.determined_value as determined_weight_in_Kg, weight_kg.uom, 
monetary_val.determined_value as Approximated_$_value, round((weight_kg.determined_value/monetary_val.determined_value),3) as $_Cost_per_kg
FROM cannabis_c_p.licen_indus_stats weight_kg JOIN cannabis_c_p.licen_indus_stats monetary_val
ON weight_kg.ref_date = monetary_val.ref_date
AND weight_kg.dguid = monetary_val.dguid
AND weight_kg.indicator = monetary_val.indicator
WHERE 
weight_kg.uom ="Kilograms" AND weight_kg.indicator LIKE "%Cannabis for Medical%" 
AND monetary_val.uom ="Dollars" AND monetary_val.indicator LIKE "%Cannabis for Medical%";