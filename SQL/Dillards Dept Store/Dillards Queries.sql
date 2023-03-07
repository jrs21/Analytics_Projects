/*Strategic:*/
/*1. Total revenue per month for April, May, and June in 2005. Return the month name and the month's total revenue.*/
SELECT 
    dim_date.month_name AS 'Month',
    SUM(fact_purchased.total_amount) AS 'total_revenue'
FROM
    fact_purchased
        JOIN
    dim_date ON fact_purchased.saledate_fk = dim_date.saledate_fk
WHERE
    dim_date.saledate_fk BETWEEN '2005-04-01' AND '2005-06-30'
GROUP BY month_name; 

/*2. Total purchase count per month for April, May, and June in 2005. Return the month name and the month's total purchase count.*/
SELECT 
    dim_date.month_name AS 'Month',
    COUNT(fact_purchased.total_quantity) AS 'purchase_count'
FROM
    fact_purchased
        JOIN
    dim_date ON fact_purchased.saledate_fk = dim_date.saledate_fk
WHERE
    dim_date.saledate_fk BETWEEN '2005-04-01' AND '2005-06-30'
GROUP BY month_name; 

/*3. Total profit per month for April, May, and June in 2005. Return the month name and the month's total profit.*/
SELECT 
    dim_date.month_name AS 'Month',
    SUM(fact_purchased.total_profit) AS 'total_profit'
FROM
    fact_purchased
        JOIN
    dim_date ON fact_purchased.saledate_fk = dim_date.saledate_fk
WHERE
    dim_date.saledate_fk BETWEEN '2005-04-01' AND '2005-06-30'
GROUP BY month_name; 

/*Operational:*/
/*1. Average revenue per transaction from April 1, 2005 to April 30, 2005 for stores in Texas. Return the date and the average revenue 
per transaction for the date.
*/
SELECT 
    dim_store.State AS State,
    ROUND(SUM(fact_purchased.total_amount) / SUM(fact_purchased.total_quantity),
            2) AS average_revenue_per_transaction,
    fact_purchased.saledate_fk
FROM
    fact_purchased
        JOIN
    dim_store ON fact_purchased.store_fk = dim_store.store_fk
WHERE
    fact_purchased.saledate_fk BETWEEN '2005-04-01' AND '2005-04-30'
        AND dim_store.State = 'TX'
GROUP BY saledate_fk;


/*2. Daily purchase count for th brand Colehaan from April 7, 2005 to April 14, 2005. Return the date and the date's purchase count.*/
SELECT 
    dim_date.saledate_fk AS Sale_Date,
    SUM(fact_purchased.total_quantity) AS Daily_purchase_count,
    dim_sku.deptdesc AS Department
FROM
    fact_purchased
        JOIN
    dim_date ON fact_purchased.saledate_fk = dim_date.saledate_fk
        JOIN
    dim_sku ON fact_purchased.SKU_fk = dim_sku.SKU_fk
WHERE
    dim_date.saledate_fk BETWEEN '2005-04-07' AND '2005-04-14'
        AND dim_sku.deptdesc = 'colehaan'
GROUP BY dim_date.saledate_fk;

/*3. The 5 lowest performing stores for April 1, 2005 to April 30, 2005 based on purchase revenue. 
Return the store ID and the store's total revenue for the entire date range.*/
SELECT 
    fact_purchased.saledate_fk,
    fact_purchased.store_fk AS 'store ID',
    SUM(fact_purchased.total_amount) AS 'Total Revenue'
FROM
    fact_purchased
WHERE
    fact_purchased.saledate_fk BETWEEN '2005-04-01' AND '2005-04-30'
GROUP BY fact_purchased.saledate_fk
ORDER BY SUM(fact_purchased.total_amount) ASC
LIMIT 5;

/*Analytical:*/
/*1. Top 10 SKUs based on quantity sold for May 7, 2005 to May 14, 2005. Return the SKU and the quantity sold for the SKU.*/
SELECT 
    fact_purchased.saledate_fk AS 'Date',
    fact_purchased.SKU_fk AS SKU,
    SUM(fact_purchased.total_quantity) AS 'Quantity Sold'
FROM
    fact_purchased
WHERE
    fact_purchased.saledate_fk BETWEEN '2005-05-07' AND '2005-05-14'
GROUP BY fact_purchased.saledate_fk
ORDER BY SUM(fact_purchased.total_quantity) DESC
LIMIT 10;

/*2. Top 3 department and city combinations based on revenue for December 1, 2004 to December 31, 2004. 
Return the department and city and the revenue for the department and city combination.*/
SELECT 
    fact_purchased.saledate_fk AS 'Date',
    dim_store.CITY AS 'City',
    dim_sku.deptdesc AS 'Department',
    SUM(fact_purchased.total_amount) AS 'Revenue'
FROM
    fact_purchased
        JOIN
    dim_store ON fact_purchased.store_fk = dim_store.store_fk
        JOIN
    dim_sku ON fact_purchased.SKU_fk = dim_sku.SKU_fk
WHERE
    fact_purchased.saledate_fk BETWEEN '2004-12-01' AND '2004-12-31'
GROUP BY fact_purchased.saledate_fk
ORDER BY SUM(fact_purchased.total_amount) DESC
LIMIT 3;

/*3. The number of returned items (STYPE = 'R') for each day of the week for June 2005. 
Return the day of the week name, i.e. Monday, Thursday, etc. and its returned items total.*/
SELECT 
    dim_date.saledate_fk AS 'Date',
    dim_date.day_name AS 'Day of the week',
    SUM(fact_returned.quantity_returned) AS 'Total quantity returned',
    SUM(fact_returned.amt_returned) AS 'Total return amount'
FROM
    fact_returned
        JOIN
    dim_date ON fact_returned.saledate_fk = dim_date.saledate_fk
WHERE
    dim_date.month_name = 'June'
        AND dim_date.year = '2005'
GROUP BY dim_date.saledate_fk;
