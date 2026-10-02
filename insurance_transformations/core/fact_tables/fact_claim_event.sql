CREATE OR REPLACE TABLE INSURANCE_PROJECT.CORE.FACT_CLAIM_EVENT AS

WITH CLAIM_EVENT_DEFINED AS (
    SELECT
        INSURANCE_PROJECT.CORE.EVENT_KEY_SEQ.NEXTVAL AS event_key,
        claim_id,
        event_type,
        event_timestamp,
        document_type,
        device_type,
        event_source
    FROM INSURANCE_PROJECT.STAGING.STG_CLAIM_EVENTS
),

FINAL_SELECTION AS (
    SELECT 
        f.event_key,
        f.claim_id,
        c.claim_key,
        c.policy_key,
        c.customer_key,
        d.date_key,
        f.event_type,
        f.event_timestamp

    FROM CLAIM_EVENT_DEFINED AS f
    
    JOIN INSURANCE_PROJECT.CORE.FACT_CLAIM AS c
        ON f.claim_id = c.claim_id

    JOIN INSURANCE_PROJECT.CORE.DIM_DATES AS d
        ON f.event_timestamp::DATE = d.full_date
)

SELECT *
FROM FINAL_SELECTION;
