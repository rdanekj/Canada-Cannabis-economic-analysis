select * FROM cannabis_c_p.`industr_ prod`;
select distinct(dguid) , geo FROM cannabis_c_p.`industr_ prod`;
select * FROM cannabis_c_p.`industr_ prod`
WHERE dguid like "2016A00011%"
ORDER BY 3 ASC ;

select distinct(dguid) , geo FROM cannabis_c_p.`industr_ prod`;

SELECT geo, ref_date, industry,(value*1000000) as "Dollar_Value"
FROM cannabis_c_p.income
WHERE industry = "Non-medical cannabis industry"
AND
estimate = "Gross domestic product (GDP)";

SELECT geo, ref_date, industry,(value*1000000) as "Dollar_Value"
FROM cannabis_c_p.income
WHERE industry = "Medical cannabis industry"
AND
estimate = "Gross domestic product (GDP)";

SELECT income.ref_date, income.geo, income.industry, (income.value*1000000) as revenue, `industr_ prod`.industry, `industr_ prod`.authority
FROM cannabis_c_p.income
JOIN cannabis_c_p.`industr_ prod`
ON income.geo = `industr_ prod`.geo
ORDER BY income.ref_date;

SELECT income.ref_date, income.geo, income.industry, (income.value*1000000) as revenue, `industr_ prod`.industry, `industr_ prod`.authority
FROM cannabis_c_p.income
JOIN cannabis_c_p.`industr_ prod`
ON income.geo = `industr_ prod`.geo
ORDER BY `industr_ prod`.ref_date DESC;

SELECT consumer_producer.ref_date,consumer_producer.geo as sales_location ,consumer_producer.value as cost_per_gram, 
`industr_ prod`.geo as produc_location,`industr_ prod`.authority,(`industr_ prod`.value*1000000) as indus_value, (((`industr_ prod`.value*1000000)/consumer_producer.value)/907184.74) as unit_sold_Tones
FROM cannabis_c_p.consumer_producer
JOIN cannabis_c_p.`industr_ prod`
ON consumer_producer.dguid = `industr_ prod`.dguid
AND
consumer_producer.ref_date = `industr_ prod`.ref_date
WHERE `industr_ prod`.authority = "Unlicensed source";

SELECT consumer_producer.ref_date,consumer_producer.geo as sales_location ,consumer_producer.value as cost_per_gram, 
`industr_ prod`.geo as produc_location,`industr_ prod`.authority,(`industr_ prod`.value*1000000) as indus_value, (((`industr_ prod`.value*1000000)/consumer_producer.value)/907184.74) as unit_sold_Tones
FROM cannabis_c_p.consumer_producer
JOIN cannabis_c_p.`industr_ prod`
ON consumer_producer.dguid = `industr_ prod`.dguid
AND
consumer_producer.ref_date = `industr_ prod`.ref_date
WHERE `industr_ prod`.authority = "Licensed source";

SELECT consumer_producer.geo as sales_location ,consumer_producer.value as cost_per_gram, consumer_producer.ref_date, consumer_producer.geo as produc_location,`industr_ prod`.authority,(`industr_ prod`.value*1000000) as indus_value, ((`industr_ prod`.value*1000000)/consumer_producer.value) as unit_sold
FROM cannabis_c_p.consumer_producer
JOIN cannabis_c_p.`industr_ prod`
ON consumer_producer.dguid = `industr_ prod`.dguid
ORDER BY `industr_ prod`.ref_date;



SELECT consumer_producer.geo as sales_location ,consumer_producer.value as cost_per_gram, consumer_producer.ref_date, consumer_producer.geo as produc_location,`industr_ prod`.authority,(`industr_ prod`.value*1000000) as indus_value, ((`industr_ prod`.value*1000000)/consumer_producer.value) as unit_sold
FROM cannabis_c_p.consumer_producer
RIGHT JOIN cannabis_c_p.`industr_ prod`
ON consumer_producer.dguid = `industr_ prod`.dguid
ORDER BY `industr_ prod`.ref_date;

SELECT consumer_producer.geo as sales_location ,consumer_producer.value as cost_per_gram, consumer_producer.ref_date, consumer_producer.geo as produc_location,`industr_ prod`.authority,(`industr_ prod`.value*1000000) as indus_value, ((`industr_ prod`.value*1000000)/consumer_producer.value) as unit_sold
FROM cannabis_c_p.consumer_producer
LEFT JOIN cannabis_c_p.`industr_ prod`
ON consumer_producer.dguid = `industr_ prod`.dguid
ORDER BY consumer_producer.ref_date;

SELECT consumer_producer.geo as sales_location ,consumer_producer.value as cost_per_gram, 
consumer_producer.ref_date, consumer_producer.geo as produc_location,`industr_ prod`.authority,(`industr_ prod`.value*1000000) as indus_value, ((`industr_ prod`.value*1000000)/consumer_producer.value) as unit_sold
FROM cannabis_c_p.consumer_producer
LEFT JOIN cannabis_c_p.`industr_ prod`
ON consumer_producer.dguid = `industr_ prod`.dguid
WHERE `industr_ prod`.authority ="Unlicensed source"
GROUP BY sales_location
ORDER BY `industr_ prod`.ref_date;