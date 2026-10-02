CREATE OR REPLACE TABLE INSURANCE_PROJECT.CORE.DIM_POLICY AS

WITH POLICY_DEFINED AS (
    SELECT 
        INSURANCE_PROJECT.CORE.POLICY_KEY_SEQ.NEXTVAL AS policy_key,
        policy_id,
        customer_id,
        policy_type,
        policy_status,
        start_date,
        end_date,
        annual_premium,
        deductible,
        sales_channel,
        updated_at
    FROM INSURANCE_PROJECT.STAGING.STG_POLICIES
),

DURATION_COLUMN AS (
    SELECT
        policy_id,
        DATEDIFF('day', start_date, end_date) AS policy_duration
    FROM POLICY_DEFINED
),

JOIN_ONE AS (
    SELECT 
        p.policy_key,
        p.policy_id,
        p.customer_id,
        p.policy_type,
        p.policy_status,
        p.start_date,
        p.end_date,
        dur.policy_duration,
        p.annual_premium,
        p.deductible,
        p.sales_channel,
        p.updated_at
    FROM POLICY_DEFINED AS p
    LEFT JOIN DURATION_COLUMN AS dur
        ON p.policy_id = dur.policy_id
),

JOIN_TWO AS (
    SELECT
        j.policy_key,
        j.policy_id,
        c.customer_key,
        j.customer_id,
        j.policy_type,
        j.policy_status,
        j.start_date,
        j.end_date,
        j.policy_duration,
        j.annual_premium,
        j.deductible,
        j.sales_channel,
        j.updated_at
    FROM JOIN_ONE AS j
    LEFT JOIN INSURANCE_PROJECT.CORE.DIM_CUSTOMER AS c
        ON j.customer_id = c.customer_id
)

SELECT *
FROM JOIN_TWO;
