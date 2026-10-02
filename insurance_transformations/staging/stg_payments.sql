CREATE OR REPLACE TABLE STG_PAYMENTS  AS
WITH VALIDATED_DATA AS (

   SELECT *
   FROM INSURANCE_PROJECT.RAW.PAYMENTS
   WHERE payment_id IS NOT NULL
   AND payment_amount >= 0
   AND claim_id IS NOT NULL
),

DEDUPLICATED_DATA AS (
   SELECT *
   FROM VALIDATED_DATA
   QUALIFY ROW_NUMBER() OVER (PARTITION BY payment_id ORDER BY payment_date DESC) = 1 
),

CLEANED AS (
   SELECT
      payment_id,
      claim_id,
      payment_date,
      payment_amount,
      upper(payment_status) AS payment_status,
      upper(payment_method) AS payment_method
  FROM DEDUPLICATED_DATA
)
SELECT * 
FROM CLEANED