/* ---------------------------------------------------------
   data_preparation.sql
   Purpose:
   Clean and prepare the Online Retail transactional dataset
   for customer-level analytics (Revenue, Frequency, Recency).

   Key steps:
   - Exclude missing CustomerID
   - Exclude cancelled invoices (InvoiceNo starting with 'C')
   - Exclude non-positive Quantity and UnitPrice
   - Create Revenue measure (Quantity * UnitPrice)
   --------------------------------------------------------- */

/* 1) Base cleaned dataset (use as a logical filter in other queries) */
SELECT
    Country,
    CustomerID,
    Description,
    InvoiceDate,
    StockCode,
    UnitPrice,
    InvoiceNo,
    Quantity,
    (Quantity * UnitPrice) AS Revenue
FROM online_retail
WHERE CustomerID IS NOT NULL
  AND InvoiceNo NOT LIKE 'C%'     -- remove cancellations
  AND Quantity > 0                -- remove returns/invalid quantities
  AND UnitPrice > 0;              -- remove free/invalid prices
