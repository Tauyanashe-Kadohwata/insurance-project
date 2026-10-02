CREATE OR REPLACE TABLE STG_RISK_SCORES  AS
WITH VALIDATED_DATA AS (
   SELECT *
   FROM INSURANCE_PROJECT.RAW.RISK_SCORES
   WHERE customer_id IS NOT NULL
   AND risk_score > 0 AND risk_score < 100
),
CLEANED AS (
   SELECT
      customer_id,
      risk_score,
      upper (risk_category) as risk_category
  FROM VALIDATED_DATA
)
SELECT * 
FROM CLEANED