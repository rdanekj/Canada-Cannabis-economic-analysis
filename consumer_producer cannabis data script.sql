ALTER TABLE cannabis_c_p.consumer_producer CHANGE COLUMN Cannabis_price canna_price text;
SELECT * FROM cannabis_c_p.consumer_producer;
-- inspecting data
SELECT distinct geo FROM cannabis_c_p.consumer_producer;
SELECT distinct canna_price FROM cannabis_c_p.consumer_producer;
SELECT distinct unit_of_measure FROM cannabis_c_p.consumer_producer;
SELECT distinct (scalar_fac) FROM cannabis_c_p.consumer_producer;
SELECT distinct (vector) FROM cannabis_c_p.consumer_producer;
SELECT distinct (ended) FROM cannabis_c_p.consumer_producer;
SELECT distinct ref_date FROM cannabis_c_p.consumer_producer;
ALTER TABLE cannabis_c_p.consumer_producer modify ref_date int;
SELECT distinct (dguid), geo FROM cannabis_c_p.consumer_producer;

-- Data clean ajust dguid as seen on meta data
-- Canada
UPDATE cannabis_c_p.consumer_producer SET
dguid = '2016A000011124' 
WHERE dguid = '2016A00011124';
-- Atlantic
UPDATE cannabis_c_p.consumer_producer SET
dguid = '2016A000101' 
WHERE dguid = '2016A00011';
 -- Quebec
UPDATE cannabis_c_p.consumer_producer SET
dguid = '2016A000124' 
WHERE dguid = '2016A000224';
-- Ontario 135
UPDATE cannabis_c_p.consumer_producer SET
dguid = '2016A000135' 
WHERE dguid = '2016A000235';
-- Prairies 04
UPDATE cannabis_c_p.consumer_producer SET
dguid = '2016A000104' 
WHERE dguid = '2016A00014';
-- Manitoba 946
UPDATE cannabis_c_p.consumer_producer SET
dguid = '2016A000946' 
WHERE dguid = '2016A000246';
-- Saskatchewan 947
UPDATE cannabis_c_p.consumer_producer SET
dguid = '2016A000947' 
WHERE dguid = '2016A000247';
-- Alberta 948
UPDATE cannabis_c_p.consumer_producer SET
dguid = '2016A000948' 
WHERE dguid = '2016A000248';
-- British Columbia 159
UPDATE cannabis_c_p.consumer_producer SET
dguid = '2016A000159' 
WHERE dguid = '2016A000259';
-- Territories 106
UPDATE cannabis_c_p.consumer_producer SET
dguid = '2016A000106' 
WHERE dguid = '2016A00016';
-- Yukon 1460
UPDATE cannabis_c_p.consumer_producer SET
dguid = '2016A001460' 
WHERE dguid = '2016A000260';
-- Northwest Territories including Nunavut 1461
UPDATE cannabis_c_p.consumer_producer SET
dguid = '2016A001461' 
WHERE dguid = 'A000261';
UPDATE cannabis_c_p.consumer_producer SET
dguid = '2016A001461' 
WHERE dguid = '2016A000261';
-- Nunavut 1462
UPDATE cannabis_c_p.consumer_producer SET
dguid = '2016A001462' 
WHERE dguid = '2016A000262';

SELECT consumer.ref_date,consumer.geo,consumer.dguid,consumer.value as consumer_price_index,
producer.value as producer_price_index 
FROM cannabis_c_p.consumer_producer consumer
JOIN
cannabis_c_p.consumer_producer producer
ON consumer.dguid = producer.dguid
AND 
consumer.ref_date = producer.ref_date
WHERE 
consumer.unit_of_measure = "Price index"
AND 
consumer.canna_price = "Consumer price"
AND
producer.unit_of_measure = "Price index"
AND 
producer.canna_price = "Producer price"
ORDER BY 3,1;
-- calculate price changes by subtracting previous year from following year for comsumer and  producer based on location or dguid
## COuntry price index
-- consumer PI

SELECT consumer1.ref_date,consumer1.geo,consumer1.dguid,consumer1.value as consumer_price_index, 
round(consumer2.value - consumer1.value,2) as consumer_end_of_year_price_index_change 
FROM cannabis_c_p.consumer_producer consumer1
JOIN
cannabis_c_p.consumer_producer consumer2
ON consumer1.dguid = consumer2.dguid
AND 
consumer2.ref_date = consumer1.ref_date + 1
WHERE 
consumer1.unit_of_measure = "Price index"
AND 
consumer1.canna_price = "Consumer price"
AND
consumer2.unit_of_measure = "Price index"
AND 
consumer2.canna_price = "Consumer price"
AND consumer1.geo = "canada" AND consumer2.geo = "canada"
ORDER BY 3,1;

Create table cannabis_c_p.consumer_pi
(ref_date int, geo varchar (100), dguid varchar (100), consumer_price_index double, consumer_end_of_year_price_index_change double);
INSERT INTO cannabis_c_p.consumer_pi
SELECT cp_index.ref_date, cp_index.geo, cp_index.dguid, cp_index.consumer_price_index, consumer_pig.consumer_end_of_year_price_index_change
FROM 
(SELECT consumer.ref_date,consumer.geo,consumer.dguid,consumer.value as consumer_price_index 
FROM cannabis_c_p.consumer_producer consumer
WHERE 
consumer.unit_of_measure = "Price index"
AND 
consumer.canna_price = "Consumer price"
AND consumer.geo = "canada" ) cp_index
LEFT JOIN
(SELECT consumer1.ref_date,consumer1.geo,consumer1.dguid,consumer1.value as consumer_price_index, 
round(consumer2.value - consumer1.value,2) as consumer_end_of_year_price_index_change 
FROM cannabis_c_p.consumer_producer consumer1
JOIN
cannabis_c_p.consumer_producer consumer2
ON consumer1.dguid = consumer2.dguid
AND 
consumer2.ref_date = consumer1.ref_date + 1
WHERE 
consumer1.unit_of_measure = "Price index"
AND 
consumer1.canna_price = "Consumer price"
AND
consumer2.unit_of_measure = "Price index"
AND 
consumer2.canna_price = "Consumer price"
AND consumer1.geo = "canada" AND consumer2.geo = "canada") consumer_pig
ON consumer_pig.ref_date= cp_index.ref_date;
SELECT * from cannabis_c_p.consumer_pi;

-- producer PI
DROP table if exists cannabis_c_p.producer_pi;
CREATE TABLE cannabis_c_p.producer_pi
( ref_date int, geo varchar(100), dguid varchar(100), producer_price_index double, producer_end_of_year_price_index_change
double);
Insert INTO cannabis_c_p.producer_pi
SELECT pp_index.ref_date, pp_index.geo, pp_index.dguid, pp_index.producer_price_index, ppg.producer_end_of_year_price_index_change
FROM
(SELECT producer.ref_date,producer.geo,producer.dguid,producer.value as producer_price_index 
FROM cannabis_c_p.consumer_producer producer
WHERE 
producer.unit_of_measure = "Price index"
AND 
producer.canna_price = "Producer price"
AND producer.geo = "canada" ) pp_index
LEFT join
(SELECT producer1.ref_date,producer1.geo,producer1.dguid,producer1.value as producer_price_index, 
round((producer2.value - producer1.value),2) as producer_end_of_year_price_index_change
FROM cannabis_c_p.consumer_producer producer1
JOIN
cannabis_c_p.consumer_producer producer2
ON producer1.dguid = producer2.dguid
AND 
producer2.ref_date = producer1.ref_date + 1
WHERE 
producer1.unit_of_measure = "Price index"
AND 
producer1.canna_price = "Producer price"
AND
producer2.unit_of_measure = "Price index"
AND 
producer2.canna_price = "Producer price"
AND producer1.geo = "canada" AND producer2.geo = "canada") ppg
ON pp_index.ref_date = ppg.ref_date AND pp_index.geo = ppg.geo ;

SELECT * FROM cannabis_c_p.producer_pi;

-- producer PI
CREATE TABLE cannabis_c_p.producer_pi
( ref_date int, geo varchar(100), dguid varchar(100), producer_price_index double, producer_end_of_year_price_index_change
double);
Insert INTO cannabis_c_p.producer_pi
SELECT producer1.ref_date,producer1.geo,producer1.dguid,producer1.value as producer_price_index, 
round((producer2.value - producer1.value),2) as producer_end_of_year_price_index_change
FROM cannabis_c_p.consumer_producer producer1
JOIN
cannabis_c_p.consumer_producer producer2
ON producer1.dguid = producer2.dguid
AND 
producer2.ref_date = producer1.ref_date + 1
WHERE 
producer1.unit_of_measure = "Price index"
AND 
producer1.canna_price = "Producer price"
AND
producer2.unit_of_measure = "Price index"
AND 
producer2.canna_price = "Producer price"
AND producer1.geo = "canada" AND producer2.geo = "canada";

 -- JOIN consumer price index and producer pi for canada
SELECT consumer.ref_date, consumer.geo , consumer.dguid , consumer.consumer_price_index , consumer.consumer_end_of_year_price_index_change , producer.producer_price_index , producer.producer_end_of_year_price_index_change
FROM cannabis_c_p.consumer_pi consumer
JOIN cannabis_c_p.producer_pi producer
ON consumer.ref_date = producer.ref_date AND consumer.geo = producer.geo AND consumer.dguid = producer.dguid 
ORDER BY 1;

## create views for above query

-- Providences of canadian consumer price index
SELECT consumer1.ref_date,consumer1.geo,consumer1.dguid,consumer1.value as consumer_price_index, 
round(consumer2.value - consumer1.value,2) as consumer_end_of_year_price_index_change 
FROM cannabis_c_p.consumer_producer consumer1
JOIN
cannabis_c_p.consumer_producer consumer2
ON consumer1.dguid = consumer2.dguid
AND 
consumer2.ref_date = consumer1.ref_date + 1
WHERE 
consumer1.unit_of_measure = "Price index"
AND 
consumer1.canna_price = "Consumer price"
AND
consumer2.unit_of_measure = "Price index"
AND 
consumer2.canna_price = "Consumer price"
AND consumer1.geo != "canada" AND consumer2.geo != "canada"
ORDER BY 3,1;





## REGIONS/provinces price index
-- consumer PI

SELECT consumer1.ref_date,consumer1.geo,consumer1.dguid,consumer1.value as consumer_price_index, 
round(consumer2.value - consumer1.value,2) as consumer_end_of_year_price_index_change 
FROM cannabis_c_p.consumer_producer consumer1
JOIN
cannabis_c_p.consumer_producer consumer2
ON consumer1.dguid = consumer2.dguid
AND 
consumer2.ref_date = consumer1.ref_date + 1
WHERE 
consumer1.unit_of_measure = "Price index"
AND 
consumer1.canna_price = "Consumer price"
AND
consumer2.unit_of_measure = "Price index"
AND 
consumer2.canna_price = "Consumer price"
AND consumer1.geo != "canada" AND consumer2.geo != "canada"
ORDER BY 2,1;

Create table cannabis_c_p.prov_consumer_pi
(ref_date int, geo varchar (100), dguid varchar (100), consumer_price_index double, consumer_end_of_year_price_index_change double);
INSERT INTO cannabis_c_p.prov_consumer_pi
SELECT cp_index.ref_date, cp_index.geo, cp_index.dguid, cp_index.consumer_price_index, consumer_pig.consumer_end_of_year_price_index_change
FROM 
(SELECT consumer.ref_date,consumer.geo,consumer.dguid,consumer.value as consumer_price_index 
FROM cannabis_c_p.consumer_producer consumer
WHERE 
consumer.unit_of_measure = "Price index"
AND 
consumer.canna_price = "Consumer price"
AND consumer.geo != "canada" ) cp_index
LEFT JOIN
(SELECT consumer1.ref_date,consumer1.geo,consumer1.dguid,consumer1.value as consumer_price_index, 
round(consumer2.value - consumer1.value,2) as consumer_end_of_year_price_index_change 
FROM cannabis_c_p.consumer_producer consumer1
JOIN
cannabis_c_p.consumer_producer consumer2
ON consumer1.dguid = consumer2.dguid
AND 
consumer2.ref_date = consumer1.ref_date + 1
WHERE 
consumer1.unit_of_measure = "Price index"
AND 
consumer1.canna_price = "Consumer price"
AND
consumer2.unit_of_measure = "Price index"
AND 
consumer2.canna_price = "Consumer price"
AND consumer1.geo != "canada" AND consumer2.geo != "canada") consumer_pig
ON consumer_pig.ref_date= cp_index.ref_date AND consumer_pig.geo= cp_index.geo ;
SELECT * from cannabis_c_p.prov_consumer_pi Order by 2,1;

-- producer PI
DROP table if exists cannabis_c_p.prov_producer_pi;
CREATE TABLE cannabis_c_p.prov_producer_pi
( ref_date int, geo varchar(100), dguid varchar(100), producer_price_index double, producer_end_of_year_price_index_change
double);
Insert INTO cannabis_c_p.prov_producer_pi
SELECT pp_index.ref_date, pp_index.geo, pp_index.dguid, pp_index.producer_price_index, ppg.producer_end_of_year_price_index_change
FROM
(SELECT producer.ref_date,producer.geo,producer.dguid,producer.value as producer_price_index 
FROM cannabis_c_p.consumer_producer producer
WHERE 
producer.unit_of_measure = "Price index"
AND 
producer.canna_price = "Producer price"
AND producer.geo != "canada" ) pp_index
LEFT join
(SELECT producer1.ref_date,producer1.geo,producer1.dguid,producer1.value as producer_price_index, 
round((producer2.value - producer1.value),2) as producer_end_of_year_price_index_change
FROM cannabis_c_p.consumer_producer producer1
JOIN
cannabis_c_p.consumer_producer producer2
ON producer1.dguid = producer2.dguid
AND 
producer2.ref_date = producer1.ref_date + 1
WHERE 
producer1.unit_of_measure = "Price index"
AND 
producer1.canna_price = "Producer price"
AND
producer2.unit_of_measure = "Price index"
AND 
producer2.canna_price = "Producer price"
AND producer1.geo != "canada" AND producer2.geo != "canada") ppg
ON pp_index.ref_date = ppg.ref_date AND pp_index.geo = ppg.geo ;

SELECT * FROM cannabis_c_p.prov_producer_pi order by 2,1;

 -- JOIN consumer price index and producer pi for Province
SELECT consumer.ref_date, consumer.geo , consumer.dguid , consumer.consumer_price_index , consumer.consumer_end_of_year_price_index_change , producer.producer_price_index , producer.producer_end_of_year_price_index_change
FROM cannabis_c_p.prov_consumer_pi consumer
JOIN cannabis_c_p.prov_producer_pi producer
ON consumer.ref_date = producer.ref_date AND consumer.geo = producer.geo AND consumer.dguid = producer.dguid 
ORDER BY 2,1;

## CREATE VIEW FOR ABOVE QUery

## PRICE PER GRAM
-- Producer and Consumer Cannabis price Changes in Canada
SELECT consumer.ref_date,consumer.geo,consumer.dguid,consumer.value as consumer_price,
producer.value as producer_price, round((consumer.value - producer.value),2) as profit_or_loss
FROM cannabis_c_p.consumer_producer consumer
JOIN
cannabis_c_p.consumer_producer producer
ON consumer.dguid = producer.dguid
AND 
consumer.ref_date = producer.ref_date
WHERE 
consumer.unit_of_measure = "Price per gram"
AND 
consumer.canna_price = "Consumer price"
AND
producer.unit_of_measure = "Price per gram"
AND 
producer.canna_price = "Producer price"
AND consumer.geo = "canada" AND producer.geo = "canada";

WITH profit_loss (ref_date,geo,dguid, consumer_price,
 producer_price, profit_or_loss)
as 
(SELECT Consumer.ref_date,consumer.geo,consumer.dguid,consumer.value as consumer_price,
producer.value as producer_price, round((consumer.value - producer.value),2) as profit_or_loss
FROM cannabis_c_p.consumer_producer consumer
JOIN
cannabis_c_p.consumer_producer producer
ON consumer.dguid = producer.dguid
AND 
consumer.ref_date = producer.ref_date
WHERE 
consumer.unit_of_measure = "Price per gram"
AND 
consumer.canna_price = "Consumer price"
AND
producer.unit_of_measure = "Price per gram"
AND 
producer.canna_price = "Producer price"
AND consumer.geo = "canada" AND producer.geo = "canada") 
SELECT *
FROM profit_loss pl
LEFT JOIN
(SELECT Canadaprof_l1.ref_date,Canadaprof_l1.geo,Canadaprof_l1.dguid, Canadaprof_l1.consumer_price,round(Canadaprof_l2.consumer_price-Canadaprof_l1.consumer_price,2) as Consumer_price_increase,
Canadaprof_l1.producer_price,round(Canadaprof_l2.producer_price-Canadaprof_l1.producer_price,2) as Producer_price_increase, Canadaprof_l1.profit_or_loss
FROM profit_loss Canadaprof_l1  JOIN profit_loss Canadaprof_l2
on Canadaprof_l2.ref_date = Canadaprof_l1.ref_date +1 AND Canadaprof_l1.geo = Canadaprof_l2.geo) cpc
ON
pl.ref_date = cpc.ref_date
ORDER by 2,1;

CREATE TABLE  cannabis_c_p.profit_loss 
(ref_date int ,geo varchar (100),dguid varchar (100), consumer_price double,
 producer_price double, profit_or_loss double);
insert into cannabis_c_p.profit_loss 
SELECT Consumer.ref_date,consumer.geo,consumer.dguid,consumer.value as consumer_price,
producer.value as producer_price, round((consumer.value - producer.value),2) as profit_or_loss
FROM cannabis_c_p.consumer_producer consumer
JOIN
cannabis_c_p.consumer_producer producer
ON consumer.dguid = producer.dguid
AND 
consumer.ref_date = producer.ref_date
WHERE 
consumer.unit_of_measure = "Price per gram"
AND 
consumer.canna_price = "Consumer price"
AND
producer.unit_of_measure = "Price per gram"
AND 
producer.canna_price = "Producer price"
AND consumer.geo = "canada" AND producer.geo = "canada";

SELECT pl.ref_date, pl.geo , pl.dguid , pl.consumer_price , cpc.Consumer_price_increase  ,pl.producer_price ,cpc.Producer_price_increase  ,pl.profit_or_loss
FROM cannabis_c_p.profit_loss pl
LEFT JOIN
(SELECT Canadaprof_l1.ref_date,Canadaprof_l1.geo,Canadaprof_l1.dguid, Canadaprof_l1.consumer_price,round(Canadaprof_l2.consumer_price-Canadaprof_l1.consumer_price,2) as Consumer_price_increase,
Canadaprof_l1.producer_price,round(Canadaprof_l2.producer_price-Canadaprof_l1.producer_price,2) as Producer_price_increase, Canadaprof_l1.profit_or_loss
FROM cannabis_c_p.profit_loss  Canadaprof_l1  JOIN cannabis_c_p.profit_loss  Canadaprof_l2
on Canadaprof_l2.ref_date = Canadaprof_l1.ref_date +1 AND Canadaprof_l1.geo = Canadaprof_l2.geo) cpc
ON
pl.ref_date = cpc.ref_date
ORDER by 2,1;

## PRICE PER GRAM
-- Producer and Consumer Cannabis price Changes in Canadian cities
SELECT consumer.ref_date,consumer.geo,consumer.dguid,consumer.value as consumer_price,
producer.value as producer_price, round((consumer.value - producer.value),2) as profit_or_loss
FROM cannabis_c_p.consumer_producer consumer
JOIN
cannabis_c_p.consumer_producer producer
ON consumer.dguid = producer.dguid
AND 
consumer.ref_date = producer.ref_date
WHERE 
consumer.unit_of_measure = "Price per gram"
AND 
consumer.canna_price = "Consumer price"
AND
producer.unit_of_measure = "Price per gram"
AND 
producer.canna_price = "Producer price"
AND consumer.geo != "canada" AND producer.geo != "canada";

##CTE Producer and Consumer Cannabis price Changes in Canadian cities
WITH profit_loss (ref_date,geo,dguid, consumer_price,
 producer_price, profit_or_loss)
as 
(SELECT Consumer.ref_date,consumer.geo,consumer.dguid,consumer.value as consumer_price,
producer.value as producer_price, round((consumer.value - producer.value),2) as profit_or_loss
FROM cannabis_c_p.consumer_producer consumer
JOIN
cannabis_c_p.consumer_producer producer
ON consumer.dguid = producer.dguid
AND 
consumer.ref_date = producer.ref_date
WHERE 
consumer.unit_of_measure = "Price per gram"
AND 
consumer.canna_price = "Consumer price"
AND
producer.unit_of_measure = "Price per gram"
AND 
producer.canna_price = "Producer price"
AND consumer.geo != "canada" AND producer.geo != "canada") 
SELECT p_l1.ref_date,p_l1.geo,p_l1.dguid, p_l1.consumer_price,round(p_l2.consumer_price-p_l1.consumer_price,2) as Consumer_price_increase,
p_l1.producer_price,round(p_l2.producer_price-p_l1.producer_price,2) as Producer_price_increase, p_l1.profit_or_loss
FROM profit_loss p_l1  JOIN profit_loss p_l2
on p_l2.ref_date = p_l1.ref_date +1 AND p_l1.geo = p_l2.geo
ORDER by 2,1;

--  TABLE consumer_producer_prices
 DROP TABLE if exists cannabis_c_p.consumer_producer_prices;
CREATE TABLE cannabis_c_p.consumer_producer_prices_cities
( 
ref_date int, 
    geo varchar (60),
    dguid varchar (60), 
    consumer_price double,	
    producer_price double,
    profit_or_loss double
)   ;

INSERT into cannabis_c_p.consumer_producer_prices_cities
SELECT Consumer.ref_date,consumer.geo,consumer.dguid,consumer.value as consumer_price,
producer.value as producer_price, round((consumer.value - producer.value),2) as profit_or_loss
FROM cannabis_c_p.consumer_producer consumer
JOIN
cannabis_c_p.consumer_producer producer
ON consumer.dguid = producer.dguid
AND 
consumer.ref_date = producer.ref_date
WHERE 
consumer.unit_of_measure = "Price per gram"
AND 
consumer.canna_price = "Consumer price"
AND
producer.unit_of_measure = "Price per gram"
AND 
producer.canna_price = "Producer price"
AND consumer.geo != "canada" AND producer.geo != "canada";

SELECT *
FROM cannabis_c_p.consumer_producer_prices_cities Order by 2,1;


SELECT p_l1.ref_date,p_l1.geo,p_l1.dguid, p_l1.consumer_price,round(p_l2.consumer_price-p_l1.consumer_price,2) as Consumer_price_increase,
p_l1.producer_price,round(p_l2.producer_price-p_l1.producer_price,2) as Producer_price_increase, p_l1.profit_or_loss
FROM cannabis_c_p.consumer_producer_prices_cities p_l1  JOIN cannabis_c_p.consumer_producer_prices_cities p_l2
on p_l2.ref_date = p_l1.ref_date +1 AND p_l1.geo = p_l2.geo
ORDER by 2,1;

SELECT ppc.ref_date , ppc.geo , ppc.dguid , ppc.consumer_price ,ppcg.Consumer_price_increase , 
ppc.producer_price , ppcg.Producer_price_increase , ppc.profit_or_loss 
FROM cannabis_c_p.consumer_producer_prices_cities ppc
Left JOIN 
(SELECT p_l1.ref_date,p_l1.geo,p_l1.dguid, p_l1.consumer_price,round(p_l2.consumer_price-p_l1.consumer_price,2) as Consumer_price_increase,
p_l1.producer_price,round(p_l2.producer_price-p_l1.producer_price,2) as Producer_price_increase, p_l1.profit_or_loss
FROM cannabis_c_p.consumer_producer_prices_cities p_l1  JOIN cannabis_c_p.consumer_producer_prices_cities p_l2
on p_l2.ref_date = p_l1.ref_date +1 AND p_l1.geo = p_l2.geo) ppcg
ON ppc.ref_date = ppcg.ref_date AND ppc.geo = ppcg.geo
ORDER BY 2,1;

-- Creat views for data vizualization

-- producer and consumer price index
CREATE VIEW cannabis_c_p.cons_prod_price_index_province as
SELECT consumer.ref_date, consumer.geo , consumer.dguid , consumer.consumer_price_index , consumer.consumer_end_of_year_price_index_change , producer.producer_price_index , producer.producer_end_of_year_price_index_change
FROM cannabis_c_p.prov_consumer_pi consumer
JOIN cannabis_c_p.prov_producer_pi producer
ON consumer.ref_date = producer.ref_date AND consumer.geo = producer.geo AND consumer.dguid = producer.dguid 
ORDER BY 2,1;

-- prducer and consumer price index change for country
Create view cannabis_c_p.cons_prod_price_index_country as
SELECT consumer.ref_date, consumer.geo , consumer.dguid , consumer.consumer_price_index , consumer.consumer_end_of_year_price_index_change , producer.producer_price_index , producer.producer_end_of_year_price_index_change
FROM cannabis_c_p.consumer_pi consumer
JOIN cannabis_c_p.producer_pi producer
ON consumer.ref_date = producer.ref_date AND consumer.geo = producer.geo AND consumer.dguid = producer.dguid 
ORDER BY 1;

-- Views for price change/increases for canada provinces producers and consumers
CREATE VIEW cannabis_c_p.provinces_cannabis_price_changes as
SELECT ppc.ref_date , ppc.geo , ppc.dguid , ppc.consumer_price ,ppcg.Consumer_price_increase , 
ppc.producer_price , ppcg.Producer_price_increase , ppc.profit_or_loss 
FROM cannabis_c_p.consumer_producer_prices_cities ppc
Left JOIN 
(SELECT p_l1.ref_date,p_l1.geo,p_l1.dguid, p_l1.consumer_price,round(p_l2.consumer_price-p_l1.consumer_price,2) as Consumer_price_increase,
p_l1.producer_price,round(p_l2.producer_price-p_l1.producer_price,2) as Producer_price_increase, p_l1.profit_or_loss
FROM cannabis_c_p.consumer_producer_prices_cities p_l1  JOIN cannabis_c_p.consumer_producer_prices_cities p_l2
on p_l2.ref_date = p_l1.ref_date +1 AND p_l1.geo = p_l2.geo) ppcg
ON ppc.ref_date = ppcg.ref_date AND ppc.geo = ppcg.geo
ORDER BY 2,1;

-- Views for price change/increases for Canadas producers and consumers
CREATE VIEW cannabis_c_p.country_cannabis_price_changes as
SELECT pl.ref_date, pl.geo , pl.dguid , pl.consumer_price , cpc.Consumer_price_increase  ,pl.producer_price ,cpc.Producer_price_increase  ,pl.profit_or_loss
FROM cannabis_c_p.profit_loss pl
LEFT JOIN
(SELECT Canadaprof_l1.ref_date,Canadaprof_l1.geo,Canadaprof_l1.dguid, Canadaprof_l1.consumer_price,round(Canadaprof_l2.consumer_price-Canadaprof_l1.consumer_price,2) as Consumer_price_increase,
Canadaprof_l1.producer_price,round(Canadaprof_l2.producer_price-Canadaprof_l1.producer_price,2) as Producer_price_increase, Canadaprof_l1.profit_or_loss
FROM cannabis_c_p.profit_loss  Canadaprof_l1  JOIN cannabis_c_p.profit_loss  Canadaprof_l2
on Canadaprof_l2.ref_date = Canadaprof_l1.ref_date +1 AND Canadaprof_l1.geo = Canadaprof_l2.geo) cpc
ON
pl.ref_date = cpc.ref_date
ORDER by 2,1;