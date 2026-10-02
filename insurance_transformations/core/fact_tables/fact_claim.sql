CREATE OR REPLACE TABLE INSURANCE_PROJECT.CORE.FACT_CLAIM AS

WITH FACTS_DEFINED AS (
    SELECT
        INSURANCE_PROJECT.CORE.CLAIM_KEY_SEQ.NEXTVAL AS claim_key,
        claim_id,
        policy_id,
        claim_date,
        claim_type,
        claim_status,
        claim_amount,
        fraud_score,
        country
    FROM INSURANCE_PROJECT.STAGING.STG_CLAIMS
),

FINAL_SELECTION AS (
    SELECT
        f.claim_key,
        f.claim_id,
        p.policy_key,
        p.customer_key,
        d.date_key,
        ct.claim_type_key,
        f.claim_status,
        f.claim_amount,
        f.fraud_score

    FROM FACTS_DEFINED f

    JOIN INSURANCE_PROJECT.CORE.DIM_POLICY p
        ON f.policy_id = p.policy_id

    JOIN INSURANCE_PROJECT.CORE.DIM_DATES d
        ON f.claim_date = d.full_date

    JOIN INSURANCE_PROJECT.CORE.DIM_CLAIM_TYPE ct
        ON f.claim_type = ct.claim_type
)

SELECT *
FROM FINAL_SELECTION;