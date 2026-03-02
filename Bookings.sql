create database booking_hotels;
use booking_hotels;

create table bookings(
	hotel varchar(5000),
    location varchar(2500),
    rating decimal(5,2),
    review varchar(150),
    no_of_reviews int,
    room_score decimal(5,2),
    price int,
    room_category varchar(150),
    balcony boolean,
    sea_view boolean,
    shared_bathroom boolean,
    no_window boolean,
    bed_count int,
    bed_type varchar(1000)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bookings.csv'
INTO TABLE bookings
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


select count(*) from bookings;

 -- / -- 🧠 1️⃣ Revenue Architecture – Where Is Money Really Coming From?  --/
## 1. What % of total revenue comes from top 10% properties?
with ranked as (select *, ntile(10) over (order by price desc) as revenue_decile from bookings)
select sum(price) as top10_pct from ranked where revenue_decile=1;

## 2. What is revenue per listing vs revenue per bed capacity?
select (sum(price)/ count(distinct hotel)) as rpl, (sum(price) / sum(bed_count)) as rpb from bookings;

## 3. Which room category generates highest revenue density?
select room_category, sum(price) as nett from bookings group by room_category order by nett desc limit 1 offset 1;

## 4. Are we overly dependent on a small cluster of listings?
select sum(price) as nett from (select price from bookings order by price desc limit 10) as top;

## 5. What is revenue contribution by location tier (top vs bottom quartile)?
with ranked as (select *, ntile(4) over (order by price desc) as revenue_decile from bookings)
select sum(price) as top10_pct from ranked where revenue_decile=1;

with ranked as (select *, ntile(4) over (order by price desc) as revenue_decile from bookings)
select sum(price) as top10_pct from ranked where revenue_decile=4;



-- / --  📈 2️⃣ Pricing Intelligence – Are We Pricing on Logic or Luck? -- /
## 6. Is there a strong correlation between price and rating?
select (count(*) * sum(price * rating) - sum(price) * sum(rating)) / 
sqrt(
(count(*) * sum(price*price) - pow(sum(price),2)) * (count(*) * sum(rating*rating) - pow(sum(rating),2))
) as corr from bookings;

## 7. Where does demand start dropping sharply as price increases?
select case when price<100000 then 'Low' when price<10000000 then 'Mid' else 'High' end as price_band, count(*) as listing_count from bookings group by price_band order by min(price);

## 8. What is the optimal price band for maximum booking volume?
select case when price<100000 then 'Low' when price<10000000 then 'Mid' else 'High' end as price_band, count(*) as listing_count, avg(rating) as avg_rated, avg(price) as avg_price from bookings group by price_band;

## 9. Are highly rated listings underpriced relative to peers?
select count(*) * 100/(select count(*) from bookings) from bookings where rating > (select avg(rating) from bookings) and price < (select avg(price) from bookings);

## 10. Is price per bed more predictive of revenue than price per room?
select avg(price/bed_count) as avg_ppb, avg(price) as avg_ppr from bookings where bed_count is not null;




-- / --  🏨 3️⃣ Inventory Optimization – Is Supply Structured Smartly?  --/
## 11. What is the distribution of bed capacity across listings?
select bed_count, count(*) as listings from bookings group by bed_count order by bed_count;

## 12. Do higher-capacity rooms actually produce higher revenue?
select bed_count, avg(price) as avg_priced from bookings group by bed_count order by bed_count;

## 13. Which bed types deliver highest ROI per square unit?
select bed_type, avg(price) as prices, count(*) as listings from bookings group by bed_type order by prices desc;

## 14. Is inventory skewed toward low-demand room types?
select room_category, count(*) as listings from bookings group by room_category order by listings desc;

## 15. Are premium room categories over-supplied or under-supplied?
select case when room_score>=8 then 'Premium' else 'Non_Premium' end as room_categ, count(*) as listings from bookings group by room_categ order by listings desc;




-- / -- ⭐ 4️⃣ Experience vs Monetization  --/
## 16. What rating threshold unlocks pricing power?
select floor(rating) as rating_group, avg(price) as priced from bookings group by rating_group order by rating_group;

## 17. Do premium features significantly improve ratings?
select sea_view, balcony, avg(rating) as rated from bookings group by sea_view, balcony;

## 18. Are shared-bathroom listings dragging overall rating average?
select shared_bathroom, avg(rating) as rated from bookings group by shared_bathroom;

## 19. High price + low rating listings — brand risk exposure?
select * from bookings where price > (select avg(price) from bookings) and rating < (select avg(rating) from bookings);

## 20. High rating + low price listings — missed revenue opportunity?
select * from bookings where price < (select avg(price) from bookings) and rating > (select avg(rating) from bookings);



-- / -- 🌍 5️⃣ Geographic Expansion Strategy  --/
## 21. Revenue per listing by city/location.
select location, sum(price) as revenue, count(*) as listing from bookings group by location	order by revenue;

select location, sum(price) as revenue, avg(price) as rpl from bookings group by location order by revenue desc;

## 22. Revenue volatility by location.
select location, stddev(price) as revenue_volatility from bookings group by location order by revenue_volatility desc;

## 23. Rating clusters by geography — quality concentration?
select location, avg(rating) as rated from bookings group by location order by rated desc;

## 24. Which locations have high demand but lower supply density?
select location, count(*) as supply, avg(price) as pricing from bookings group by location order by supply desc;

## 25. Where should expansion be prioritized based on revenue efficiency?
select location, sum(price)/count(*) as revenue_eff from bookings group by location order by revenue_eff desc;




-- / --  🛏 6️⃣ Feature ROI Engineering  --/
## 26. Incremental revenue impact of:
	## * Sea View
	## * Balcony
	## * Private bathroom
	## * Capsule vs Deluxe

select sea_view, avg(price) from bookings group by sea_view;
select balcony, avg(price) from bookings group by balcony;
select shared_bathroom, avg(price) from bookings group by shared_bathroom;
select room_category, avg(price) from bookings group by room_category;


## 27. Which amenity delivers highest marginal revenue gain?
select 'Sea_View' as feature , avg(price) from bookings where sea_view=1 
union
select 'Balcony' as feature , avg(price) from bookings where balcony=1 
union
select 'Private Bathroom' as feature , avg(price) from bookings where shared_bathroom=0; 



-- / -- 📊 7️⃣ Risk & Operational Efficiency  --/
## 28. Listings priced above market median but below rating median — pricing inefficiency?
 WITH SortedPrices AS (
    SELECT 
        price,
        ROW_NUMBER() OVER (ORDER BY price) as row_num,
        COUNT(*) OVER () as total_count
    FROM bookings
)
SELECT AVG(price) AS median_price
FROM SortedPrices
WHERE row_num IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2));

WITH SortedRatings AS (
    SELECT 
        rating,
        ROW_NUMBER() OVER (ORDER BY rating) as row_num,
        COUNT(*) OVER () as total_count
    FROM bookings
)
SELECT AVG(rating) AS median_rate
FROM SortedRatings
WHERE row_num IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2)); 


WITH 
SortedPrices AS (
    SELECT price,
           ROW_NUMBER() OVER (ORDER BY price) AS row_num,
           COUNT(*) OVER () AS total_count
    FROM bookings
    WHERE price IS NOT NULL
),
MedianPrice AS (
    SELECT AVG(price) AS median_price
    FROM SortedPrices
    WHERE row_num IN (
        FLOOR((total_count + 1) / 2),
        CEIL((total_count + 1) / 2)
    )
),
SortedRatings AS (
    SELECT rating,
           ROW_NUMBER() OVER (ORDER BY rating) AS row_num,
           COUNT(*) OVER () AS total_count
    FROM bookings
    WHERE rating IS NOT NULL
),
MedianRating AS (
    SELECT AVG(rating) AS median_rating
    FROM SortedRatings
    WHERE row_num IN (
        FLOOR((total_count + 1) / 2),
        CEIL((total_count + 1) / 2)
    )
)

SELECT *
FROM bookings
WHERE price > (SELECT median_price FROM MedianPrice)
AND rating < (SELECT median_rating FROM MedianRating);


## 29. Revenue variance by room type — stability vs volatility?
select room_category, stddev(price) as revenue_variance from bookings group by room_category order by revenue_variance desc;

## 30. Is overall portfolio optimized for margin or occupancy?
select avg(price) as avg_price, count(*) as listings, sum(price) as revenue from bookings;




