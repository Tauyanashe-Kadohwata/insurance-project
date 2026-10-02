CREATE OR REPLACE TABLE INSURANCE_PROJECT.CORE.FACT_PAYMENT AS

WITH PAYMENT_DEFINED AS (
    SELECT
        INSURANCE_PROJECT.CORE.PAYMENT_KEY_SEQ.NEXTVAL AS payment_key,
        payment_id,
        claim_id,
        payment_date,
        payment_amount,
        payment_status,
        payment_method
    FROM INSURANCE_PROJECT.STAGING.STG_PAYMENTS
),

FINAL_SELECTION AS (
    SELECT
        p.payment_key,
        p.payment_id,
        fc.claim_key,
        fc.policy_key,
        fc.customer_key,
        d.date_key,
        p.payment_amount,
        p.payment_status,
        p.payment_method

    FROM PAYMENT_DEFINED p

    JOIN INSURANCE_PROJECT.CORE.FACT_CLAIM fc
        ON p.claim_id = fc.claim_id

    JOIN INSURANCE_PROJECT.CORE.DIM_DATES d
        ON p.payment_date = d.full_date
)

SELECT *
FROM FINAL_SELECTION;