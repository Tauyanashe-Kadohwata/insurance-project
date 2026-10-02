CREATE OR REPLACE TABLE STG_CUSTOMERS  AS
WITH VALIDATED_DATA AS (

   SELECT *
   FROM INSURANCE_PROJECT.RAW.CUSTOMERS
   WHERE customer_id IS NOT NULL
),

DEDUPLICATED_DATA AS (
   SELECT *
   FROM VALIDATED_DATA
   QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY created_at DESC) = 1 
),

CLEANED AS (
   SELECT
      customer_id,
      first_name,
      last_name,
      date_of_birth,
      city,
      region,
      occupation,
      email,
      phone,
      created_at
  FROM DEDUPLICATED_DATA
)
SELECT * 
FROM CLEANED