# describe of tables
describe customers;
describe Products;
describe Orders;
describe OrderDetails;


#Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization.
select location, count(customer_id) as number_of_customers 
from customers group by location
order by number_of_customers desc
limit 3;


#Determine the distribution of customers by the number of orders placed. 
#This insight will help in segmenting customers into one-time buyers, occasional shoppers, and regular customers for tailored marketing strategies.
select numberoforders, count(customer_id) as customercount 
from
(select count(order_id) as numberoforders, customer_id
from orders 
group by customer_id) os 
group by numberoforders
order by numberoforders asc;


#Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.
select product_id, 
avg(quantity) as AvgQuantity, 
sum(price_per_unit*quantity) as totalrevenue
from orderDetails
group by product_id
having avg(quantity) =2
order by totalrevenue desc;


#For each product category, calculate the unique number of customers purchasing from it. 
#This will help understand which categories have wider appeal across the customer base.
select p.category, count(distinct o.customer_id) as unique_customers
from products p 
join orderdetails od on p.product_id=od.product_id
join orders o on od.order_id=o.order_id
group by p.category
order by unique_customers desc;


#Analyze the month-on-month percentage change in total sales to identify growth trends.
select date_format(order_date,'%Y-%m') as Month,
sum(total_amount) as TotalSales,
round
(
    (sum(total_amount)-lag(sum(total_amount)) over (order by date_format(order_date,'%Y-%m')))
/lag(sum(total_amount))over(order by date_format(order_date,'%Y-%m'))*100 ,2) as PercentChange
from orders
group by date_format(order_date,'%Y-%m')
order by month;


#Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies to enhance order value.
-- Step 1: Calculate the average order value per month
WITH MonthlyAvg AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        ROUND(AVG(total_amount), 2) AS AvgOrderValue
    FROM Orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
-- Step 2: Calculate month-on-month change
SELECT  
    month,
    AvgOrderValue,
    ROUND(
        AvgOrderValue - LAG(AvgOrderValue) OVER (ORDER BY month), 
        2
    ) AS ChangeInValue
FROM MonthlyAvg
ORDER BY month ASC;



#Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.
SELECT
  product_id,
  COUNT(*) AS SalesFrequency
FROM OrderDetails
GROUP BY product_id
ORDER BY SalesFrequency DESC
LIMIT 5;


#List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.
SELECT 
    od.product_id,
    p.name,
    COUNT(DISTINCT o.customer_id) AS uniqueCustomerCount
FROM OrderDetails od
JOIN Orders o ON od.order_id = o.order_id
JOIN Products p ON od.product_id = p.product_id
GROUP BY od.product_id, p.name
HAVING COUNT(DISTINCT o.customer_id) < 0.4 * (SELECT COUNT(*) FROM Customers)
ORDER BY uniqueCustomerCount ASC;


#Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts
WITH FirstPurchase AS (
    SELECT 
        customer_id,
        DATE_FORMAT(MIN(order_date), '%Y-%m') AS firstPurchaseMonth
    FROM Orders
    GROUP BY customer_id
)
SELECT 
    firstPurchaseMonth,
    COUNT(customer_id) AS totalNewCustomers
FROM FirstPurchase
GROUP BY firstPurchaseMonth
ORDER BY firstPurchaseMonth ASC;


#Identify the months with the highest sales volume, aiding in planning for stock levels, 
#marketing efforts, and staffing in anticipation of peak demand periods.
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(total_amount) AS totalsales
FROM Orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY totalsales DESC
LIMIT 3;







