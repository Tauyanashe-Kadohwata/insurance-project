CREATE OR REPLACE TABLE INSURANCE_PROJECT.CORE.DIM_CLAIM_TYPE AS

WITH DEFINED_CLAIM_TYPE AS (
    SELECT 
       INSURANCE_PROJECT.CORE.CLAIM_TYPE_KEY_SEQ.NEXTVAL AS claim_type_key,
       claim_type,
       description
    FROM INSURANCE_PROJECT.STAGING.STG_CLAIM_TYPES
    WHERE LOWER(claim_type) != 'claim_type'
),

DESCRIPTION_DEFINED AS (
    SELECT 
       claim_type_key,
       claim_type,
       CASE 
         WHEN description = 'Accident' THEN 'This is a accident related claim'
         WHEN description = 'Theft' THEN 'This is a theft related claim'
         WHEN description = 'Damage' THEN 'This claim is related to property damage'
         WHEN description = 'Illness' THEN 'This claim is related to an illness'
         WHEN description = 'Water Damage' THEN 'This claim is related to water damage'
         WHEN description = 'Fire' THEN 'This claim is related to fire'
         WHEN description = 'Travel Delay' THEN 'This claim is related to travel delay'
         WHEN description = 'Pet Illness' THEN 'This claim is related to a pet illness'
         ELSE description
       END AS description
       FROM DEFINED_CLAIM_TYPE
)

SELECT * 
FROM DESCRIPTION_DEFINED