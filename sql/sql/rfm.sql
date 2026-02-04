/* ---------------------------------------------------------
   rfm.sql
   Purpose:
   - Build customer-level RFM table from Online Retail dataset
   - Assign R, F, M scores (1-5) using quintiles (NTILE)
   - Create an overall RFM score and simple segment labels

   Cleaning rules:
   - Exclude cancellations (InvoiceNo LIKE 'C%')
   - Exclude non-positive Quantity / UnitPrice
   - Exclude NULL CustomerID
   --------------------------------------------------------- */

WITH clean AS (
    SELECT
        CustomerID,
        InvoiceNo,
        InvoiceDate,
        Quantity,
        UnitPrice,
        (Quantity * UnitPrice) AS Revenue
    FROM online_retail
    WHERE CustomerID IS NOT NULL
      AND InvoiceNo NOT LIKE 'C%'
      AND Quantity > 0
      AND UnitPrice > 0
),
ref_date AS (
    SELECT MAX(InvoiceDate) AS AnalysisDate
    FROM clean
),
customer_metrics AS (
    SELECT
        c.CustomerID,
        -- Recency: days since last purchase (using dataset max date as reference)
        ROUND(julianday(r.AnalysisDate) - julianday(MAX(c.InvoiceDate)), 0) AS RecencyDays,

        -- Frequency: number of distinct invoices
        COUNT(DISTINCT c.InvoiceNo) AS Frequency,

        -- Monetary: total revenue
        ROUND(SUM(c.Revenue), 2) AS MonetaryValue
    FROM clean c
    CROSS JOIN ref_date r
    GROUP BY c.CustomerID
),
scored AS (
    SELECT
        CustomerID,
        RecencyDays,
        Frequency,
        MonetaryValue,

        /* Score logic:
           - Recency: lower is better => order ASC (most recent gets higher score when we reverse later)
           - Frequency: higher is better => DESC
           - Monetary: higher is better => DESC
        */

        -- For Recency: NTILE(5) gives 1 for smallest (best), 5 for largest (worst)
        -- We flip it so 5 = best recency
        (6 - NTILE(5) OVER (ORDER BY RecencyDays ASC)) AS R_Score,

        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY MonetaryValue DESC) AS M_Score
    FROM customer_metrics
),
final AS (
    SELECT
        CustomerID,
        RecencyDays,
        Frequency,
        MonetaryValue,
        R_Score,
        F_Score,
        M_Score,

        (R_Score || F_Score || M_Score) AS RFM_Score,

        CASE
            WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN 'Champions'
            WHEN R_Score >= 4 AND F_Score >= 3 THEN 'Loyal Customers'
            WHEN R_Score >= 4 AND F_Score <= 2 THEN 'New / Promising'
            WHEN R_Score = 3 AND F_Score >= 3 THEN 'Potential Loyalists'
            WHEN R_Score <= 2 AND F_Score >= 4 THEN 'At Risk (High Frequency)'
            WHEN R_Score <= 2 AND M_Score >= 4 THEN 'At Risk (High Value)'
            WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2 THEN 'Hibernating'
            ELSE 'Needs Attention'
        END AS CustomerSegment
    FROM scored
)
SELECT *
FROM final
ORDER BY MonetaryValue DESC;
