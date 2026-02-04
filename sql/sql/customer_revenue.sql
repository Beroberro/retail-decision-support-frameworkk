/* ---------------------------------------------------------
   customer_revenue.sql
   Purpose:
   Customer-level revenue analysis:
   - Total revenue per customer
   - Top customers by revenue (for bar chart)
   - Revenue distribution (for ranking / distribution view)

   Assumptions:
   - Using the same cleaning rules as data_preparation.sql
   --------------------------------------------------------- */

/* A) Total revenue per customer */
SELECT
    CustomerID,
    SUM(Quantity * UnitPrice) AS TotalRevenue
FROM online_retail
WHERE CustomerID IS NOT NULL
  AND InvoiceNo NOT LIKE 'C%'
  AND Quantity > 0
  AND UnitPrice > 0
GROUP BY CustomerID;

/* B) Top 20 customers by revenue (for "Top Customers by Revenue" bar chart) */
SELECT
    CustomerID,
    SUM(Quantity * UnitPrice) AS TotalRevenue
FROM online_retail
WHERE CustomerID IS NOT NULL
  AND InvoiceNo NOT LIKE 'C%'
  AND Quantity > 0
  AND UnitPrice > 0
GROUP BY CustomerID
ORDER BY TotalRevenue DESC
LIMIT 20;

/* C) Revenue distribution preparation (rank customers by revenue)
   Use this to show "Revenue Distribution" as sorted bars or a ranked view.
*/
SELECT
    CustomerID,
    SUM(Quantity * UnitPrice) AS TotalRevenue,
    RANK() OVER (ORDER BY SUM(Quantity * UnitPrice) DESC) AS RevenueRank
FROM online_retail
WHERE CustomerID IS NOT NULL
  AND InvoiceNo NOT LIKE 'C%'
  AND Quantity > 0
  AND UnitPrice > 0
GROUP BY CustomerID
ORDER BY TotalRevenue DESC;
