/* ---------------------------------------------------------
   purchase_frequency.sql
   Purpose:
   Customer-level purchase frequency analysis:
   - Number of unique invoices per customer (Frequency)
   - Top customers by frequency (for bar chart)

   Notes:
   - Using DISTINCT InvoiceNo as "transaction count"
   - Cleaning:
     * Exclude cancellations (InvoiceNo LIKE 'C%')
     * Exclude non-positive quantity/unit price
     * Exclude null CustomerID
   --------------------------------------------------------- */

/* A) Purchase frequency per customer */
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS PurchaseFrequency
FROM online_retail
WHERE CustomerID IS NOT NULL
  AND InvoiceNo NOT LIKE 'C%'
  AND Quantity > 0
  AND UnitPrice > 0
GROUP BY CustomerID;

/* B) Top 20 customers by purchase frequency (for bar chart) */
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS PurchaseFrequency
FROM online_retail
WHERE CustomerID IS NOT NULL
  AND InvoiceNo NOT LIKE 'C%'
  AND Quantity > 0
  AND UnitPrice > 0
GROUP BY CustomerID
ORDER BY PurchaseFrequency DESC
LIMIT 20;

/* C) Tie-breaker version (if many customers share same frequency)
   This sorts by Frequency first, then by Revenue as a secondary criteria.
*/
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS PurchaseFrequency,
    SUM(Quantity * UnitPrice) AS TotalRevenue
FROM online_retail
WHERE CustomerID IS NOT NULL
  AND InvoiceNo NOT LIKE 'C%'
  AND Quantity > 0
  AND UnitPrice > 0
GROUP BY CustomerID
ORDER BY PurchaseFrequency DESC, TotalRevenue DESC
LIMIT 20;
