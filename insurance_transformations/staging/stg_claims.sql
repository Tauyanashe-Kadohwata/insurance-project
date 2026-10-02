CREATE OR REPLACE TABLE STG_CLAIMS  AS
WITH VALIDATED_DATA AS (

   SELECT *
   FROM INSURANCE_PROJECT.RAW.CLAIMS
   WHERE claim_id IS NOT NULL
   AND claim_amount >= 0
   AND policy_id IS NOT NULL
),

DEDUPLICATED_DATA AS (
   SELECT *
   FROM VALIDATED_DATA
   QUALIFY ROW_NUMBER() OVER (PARTITION BY claim_id ORDER BY updated_at DESC) = 1 
),

CLEANED AS (
   SELECT
      claim_id,
      policy_id,
      claim_date,
      upper(claim_type) AS claim_type,
      upper(claim_status) AS claim_status,
      claim_amount,
      fraud_score,
      upper(country) AS country,
      updated_at
  FROM DEDUPLICATED_DATA
)
SELECT * 
FROM CLEANED