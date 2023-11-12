-- ----------------Create database-----------------------------------------------

create database walmartSales;
use walmartSales;


CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);
select * from sales;

-- --------------------------------------------------------------------
-- ---------------------------- Feature Engineering -------------------
-- --------------------------------------------------------------------

-- --------TIME OF THE DAY

select time,
   (case 
            when `time` between "00:00:00" and "12:00:00" then "Morning"
            when `time` between "12:01:00" and "16:00:00" then "Afternoon"
            else "evening"
            end) 
            as time_of_date
from sales;

alter table sales add column time_of_day varchar(20);

update sales
set time_of_day=(
 case 
            when `time` between "00:00:00" and "12:00:00" then "Morning"
            when `time` between "12:01:00" and "16:00:00" then "Afternoon"
            else "evening"
            end);
            
-- ----DAY NAME-------
select date,
dayname(date)
from sales;

alter table sales add column _day varchar(20);

update sales
set _day=(
dayname(date)
);

-- ----MONTH NAME-------
select
monthname(date)
from
sales;

alter table sales add column name_of_month varchar(30);

update sales 
set name_of_month=(monthname(date));

-- --------------------------------------------------------------------
-- ---------------------------- Generic ------------------------------
-- --------------------------------------------------------------------


-- How many unique cities does the data have?
select 
distinct city 
from sales;

-- In which city is each branch?
select distinct city,branch
from sales; 

-- --------------------------------------------------------------------
-- ---------------------------- Product -------------------------------
-- --------------------------------------------------------------------

-- How many unique product lines does the data have?
select distinct product_line
from sales;


-- What is the most common payment method
select payment,count(payment) 
from sales
group by payment
order by count(payment)  desc;


-- What is the most selling product line
select 	  product_line,  count(product_line)
from sales
group by product_line
order by count(product_line) desc;


-- What is the total revenue by month
select name_of_month, sum(total) as total_rev
from sales
group by name_of_month
order by total_rev desc;


-- What month had the largest COGS?
select name_of_month, max(cogs),sum(cogs)
from sales
group by name_of_month
order by max(cogs) desc;


-- What product line had the largest revenue?
select product_line, sum(total)
from sales
group by product_line
order by sum(total) desc;

-- What is the city with the largest revenue?
 select branch,city, count(total)
 from sales
 group by city,branch
 order by count(total) desc;




-- What product line had the largest VAT?
select product_line, avg( tax_pct)
from sales
group by product_line
order by avg( tax_pct);

-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales
select avg(quantity)
from sales;

select product_line,
case when avg(quantity) > 5.4995 then "good"
	 when avg(quantity) < 5.4995 then "bad"
     else "average" end as remark
from sales
group by product_line;
     
     
-- Which branch sold more products than average product sold?
SELECT branch, 
    SUM(quantity) AS qnty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);


-- What is the most common product line by gender
select gender, count(gender),product_line
from sales
group by gender, product_line
order by count(gender) desc;


-- What is the average rating of each product line
select product_line, avg(rating)
from sales
group by product_line;


-- --------------------------------------------------------------------
-- -------------------------- Customers -------------------------------
-- --------------------------------------------------------------------

-- How many unique customer types does the data have?
select distinct customer_type
from sales;

-- How many unique payment methods does the data have?
select distinct payment
from sales;


-- What is the most common customer type?
select distinct customer_type, count(customer_type)
from sales
group by customer_type
order by count(customer_type) desc;


-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type;


-- What is the gender distribution per branch?
select  gender, count(*) as branch_A
from sales
where branch="A"
group by gender;

select  gender, count(*) 
from sales
where branch="B"
group by gender;

select  gender, count(*) 
from sales
where branch="C"
group by gender;


-- What is the gender of most of the customers?
select 
gender, count(*)
from sales
group by gender;


-- Which time of the day do customers give most ratings?
select time_of_day, avg(rating)
from sales
group by time_of_day
order by avg(rating) desc;


-- Which time of the day do customers give most ratings per branch?
select  time_of_day, avg(rating) as rating_from_A
from sales
where branch="A"
group by time_of_day
order by avg(rating) desc;

select  time_of_day, avg(rating) as rating_from_B
from sales
where branch="B"
group by time_of_day
order by avg(rating) desc;

select  time_of_day, avg(rating) as rating_from_C
from sales
where branch="C"
group by time_of_day
order by avg(rating) desc;


-- Which day fo the week has the best avg ratings?
select _day, avg(rating)
from sales
group by _day
order by avg(rating) desc;


-- Which day of the week has the best average ratings per branch?
select _day, avg(rating)
from sales
where branch="A"
group by _day
order by avg(rating) desc;


-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday 
select time_of_day, count(*)
from sales
where _day="Monday"
group by time_of_day
order by count(*) desc;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours

-- Which of the customer types brings the most revenue?
select customer_type, count(*)
from sales
group by customer_type
order by count(*)  desc;


-- Which city has the largest tax/VAT percent?
select city, sum(tax_pct)
from sales
group by city
order by sum(tax_pct) desc;


-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax;