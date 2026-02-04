/* =========================================================
   kpi_sales.sql
   Purpose:
   - Produce core retail KPIs and "top lists" for dashboards
   - Works with the Online Retail dataset structure
   ---------------------------------------------------------
   IMPORTANT:
   - If you already have a column named Revenue, use it.
   - Otherwise compute Revenue = Quantity * UnitPrice
   ========================================================= */

/* ---------- 1) Base clean dataset (view-like CTE) ----------
   Common cleaning:
   - Exclude NULL CustomerID
   - Exclude cancelled invoices (InvoiceNo starts with 'C')
   - Exclude non-positive quantity/price (returns, corrections)
*/
WITH cleaned AS (
    SELECT
        InvoiceNo,
        StockCode,
        Description,
        Quantity,
        UnitPrice,
        InvoiceDate,
        CustomerID,
        Country,
        /* If you do NOT have Revenue column, compute it: */
        (Quantity * UnitPrice) AS Revenue
    FROM online_retail
    WHERE CustomerID IS NOT NULL
      AND InvoiceNo NOT LIKE 'C%'
      AND Quantity > 0
      AND UnitPrice > 0
)

/* ---------- 2) Core KPIs (single row) ---------- */
SELECT
    ROUND(SUM(Revenue), 2) AS total_revenue,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    COUNT(DISTINCT CustomerID) AS total_customers,
    ROUND(SUM(Revenue) * 1.0 / COUNT(DISTINCT InvoiceNo), 2) AS avg_order_value,
    ROUND(SUM(Revenue) * 1.0 / COUNT(DISTINCT CustomerID), 2) AS avg_revenue_per_customer,
    MIN(InvoiceDate) AS period_start,
    MAX(InvoiceDate) AS period_end
FROM cleaned;

/* ---------- 3) Revenue by Country (top 10) ---------- */
WITH cleaned AS (
    SELECT
        InvoiceNo, CustomerID, Country,
        (Quantity * UnitPrice) AS Revenue
    FROM online_retail
    WHERE CustomerID IS NOT NULL
      AND InvoiceNo NOT LIKE 'C%'
      AND Quantity > 0
      AND UnitPrice > 0
)
SELECT
    Country,
    ROUND(SUM(Revenue), 2) AS revenue
FROM cleaned
GROUP BY Country
ORDER BY revenue DESC
LIMIT 10;

/* ---------- 4) Top Customers by Revenue (top 20) ---------- */
WITH cleaned AS (
    SELECT
        InvoiceNo, CustomerID,
        (Quantity * UnitPrice) AS Revenue
    FROM online_retail
    WHERE CustomerID IS NOT NULL
      AND InvoiceNo NOT LIKE 'C%'
      AND Quantity > 0
      AND UnitPrice > 0
)
SELECT
    CustomerID,
    ROUND(SUM(Revenue), 2) AS revenue,
    COUNT(DISTINCT InvoiceNo) AS orders
FROM cleaned
GROUP BY CustomerID
ORDER BY revenue DESC
LIMIT 20;

/* ---------- 5) Top Products by Revenue (top 20) ---------- */
WITH cleaned AS (
    SELECT
        StockCode, Description,
        (Quantity * UnitPrice) AS Revenue
    FROM online_retail
    WHERE CustomerID IS NOT NULL
      AND InvoiceNo NOT LIKE 'C%'
      AND Quantity > 0
      AND UnitPrice > 0
)
SELECT
    StockCode,
    Description,
    ROUND(SUM(Revenue), 2) AS revenue
FROM cleaned
GROUP BY StockCode, Description
ORDER BY revenue DESC
LIMIT 20;

/* ---------- 6) Monthly Revenue Trend ---------- */
WITH cleaned AS (
    SELECT
        InvoiceDate,
        (Quantity * UnitPrice) AS Revenue
    FROM online_retail
    WHERE CustomerID IS NOT NULL
      AND InvoiceNo NOT LIKE 'C%'
      AND Quantity > 0
      AND UnitPrice > 0
)
SELECT
    strftime('%Y-%m', InvoiceDate) AS year_month,
    ROUND(SUM(Revenue), 2) AS revenue
FROM cleaned
GROUP BY year_month
ORDER BY year_month;
