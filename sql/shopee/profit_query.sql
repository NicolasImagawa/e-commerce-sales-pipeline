SELECT SUM(price) AS faturamento, SUM(profit) - 534.85 - 638.06 - 445.00 - 445.00 AS lucro FROM shopee.profits
WHERE date_created >= '2025-03-12 00:00:00+00'
and date_approved <= '2025-05-01 00:00:00+00'