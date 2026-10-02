CREATE OR REPLACE TABLE STG_POLICIES  AS
WITH VALIDATED_DATA AS (

   SELECT *
   FROM INSURANCE_PROJECT.RAW.POLICIES
   WHERE policy_id IS NOT NULL
   AND annual_premium >= 0
   AND customer_id IS NOT NULL
),

DEDUPLICATED_DATA AS (
   SELECT *
   FROM VALIDATED_DATA
   QUALIFY ROW_NUMBER() OVER (PARTITION BY policy_id ORDER BY end_date DESC
) = 1 
),

CLEANED AS (
   SELECT
      policy_id,
      customer_id,
      policy_type,
      upper(policy_status) AS policy_status,
      start_date,
      end_date,
      annual_premium,
      deductible,
      upper(sales_channel) AS sales_channel,
      updated_at
  FROM DEDUPLICATED_DATA
)
SELECT * 
FROM CLEANED