/* =========================================================
   views_for_tableau.sql
   Purpose:
   - Create clean, reusable SQL views for Tableau
   - Keeps dashboards consistent and reproducible
   ========================================================= */

/* ---------- 1) Clean transactions view ---------- */
DROP VIEW IF EXISTS vw_clean_transactions;

CREATE VIEW vw_clean_transactions AS
SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    UnitPrice,
    InvoiceDate,
    CustomerID,
    Country,
    (Quantity * UnitPrice) AS Revenue
FROM online_retail
WHERE CustomerID IS NOT NULL
  AND InvoiceNo NOT LIKE 'C%'
  AND Quantity > 0
  AND UnitPrice > 0;


/* ---------- 2) Customer-level summary view ---------- */
DROP VIEW IF EXISTS vw_customer_summary;

CREATE VIEW vw_customer_summary AS
SELECT
    CustomerID,
    Country,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    SUM(Quantity) AS total_items,
    MIN(InvoiceDate) AS first_purchase_date,
    MAX(InvoiceDate) AS last_purchase_date
FROM vw_clean_transactions
GROUP BY CustomerID, Country;


/* ---------- 3) (Optional) RFM view ----------
   If you already calculate RFM in another script, you can
   skip this. But having it as a VIEW is very Tableau-friendly.
*/
DROP VIEW IF EXISTS vw_customer_rfm;

CREATE VIEW vw_customer_rfm AS
WITH base AS (
    SELECT
        CustomerID,
        MAX(date(InvoiceDate)) AS last_purchase_date,
        COUNT(DISTINCT InvoiceNo) AS frequency,
        SUM(Revenue) AS monetary_value
    FROM vw_clean_transactions
    GROUP BY CustomerID
),
ref AS (
    SELECT MAX(date(InvoiceDate)) AS max_date
    FROM vw_clean_transactions
)
SELECT
    b.CustomerID,
    CAST(julianday(r.max_date) - julianday(b.last_purchase_date) AS INTEGER) AS recency_days,
    b.frequency,
    ROUND(b.monetary_value, 2) AS monetary_value
FROM base b
CROSS JOIN ref r;
