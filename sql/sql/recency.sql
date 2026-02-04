/* ---------------------------------------------------------
   recency.sql
   Purpose:
   Customer-level recency analysis:
   - Last purchase date per customer
   - Recency in days (days since last purchase)
   - Top customers by most recent activity

   Cleaning:
   - Exclude cancellations (InvoiceNo LIKE 'C%')
   - Exclude non-positive quantity/unit price
   - Exclude null CustomerID
   --------------------------------------------------------- */

/* A) If InvoiceDate is already in ISO format: 'YYYY-MM-DD HH:MM:SS'
   This is the easiest case for SQLite date() / julianday().
*/
WITH clean AS (
    SELECT
        CustomerID,
        InvoiceNo,
        InvoiceDate
    FROM online_retail
    WHERE CustomerID IS NOT NULL
      AND InvoiceNo NOT LIKE 'C%'
      AND Quantity > 0
      AND UnitPrice > 0
),
last_purchase AS (
    SELECT
        CustomerID,
        MAX(InvoiceDate) AS LastPurchaseDate
    FROM clean
    GROUP BY CustomerID
),
ref_date AS (
    /* Use the maximum date in the dataset as the reference "analysis date" */
    SELECT MAX(InvoiceDate) AS AnalysisDate
    FROM clean
)
SELECT
    lp.CustomerID,
    lp.LastPurchaseDate,
    ROUND(julianday(r.AnalysisDate) - julianday(lp.LastPurchaseDate), 0) AS RecencyDays
FROM last_purchase lp
CROSS JOIN ref_date r
ORDER BY RecencyDays ASC
LIMIT 50;


/* B) If InvoiceDate is in UK format: 'DD/MM/YYYY HH:MM'
   Uncomment this block ONLY if A fails to compute correct values.
   It converts DD/MM/YYYY to YYYY-MM-DD for SQLite parsing.
*/
/*
WITH clean AS (
    SELECT
        CustomerID,
        InvoiceNo,
        InvoiceDate,
        -- Convert 'DD/MM/YYYY HH:MM' -> 'YYYY-MM-DD HH:MM'
        substr(InvoiceDate, 7, 4) || '-' || substr(InvoiceDate, 4, 2) || '-' || substr(InvoiceDate, 1, 2) ||
        substr(InvoiceDate, 11) AS InvoiceDateISO
    FROM online_retail
    WHERE CustomerID IS NOT NULL
      AND InvoiceNo NOT LIKE 'C%'
      AND Quantity > 0
      AND UnitPrice > 0
),
last_purchase AS (
    SELECT
        CustomerID,
        MAX(InvoiceDateISO) AS LastPurchaseDate
    FROM clean
    GROUP BY CustomerID
),
ref_date AS (
    SELECT MAX(InvoiceDateISO) AS AnalysisDate
    FROM clean
)
SELECT
    lp.CustomerID,
    lp.LastPurchaseDate,
    ROUND(julianday(r.AnalysisDate) - julianday(lp.LastPurchaseDate), 0) AS RecencyDays
FROM last_purchase lp
CROSS JOIN ref_date r
ORDER BY RecencyDays ASC
LIMIT 50;
*/
