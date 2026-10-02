CREATE OR REPLACE TABLE INSURANCE_PROJECT.CORE.DIM_POLICY_HISTORY AS 

WITH policies_selected AS (
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

POLICY_CHANGES AS (
    SELECT
        INSURANCE_PROJECT.CORE.POLICY_CHANGES_KEY_SEQ.NEXTVAL AS policy_changes_key,
        policy_id,
        change_type,
        old_value,
        new_value,
        upper(source) as source,
    FROM INSURANCE_PROJECT.STAGING.STG_POLICY_CHANGES
),

POLICY_HISTORY AS (
    SELECT
        ps.policy_key,
        ps.policy_id,
        ps.customer_id,
        ps.policy_type,
        ps.policy_status,
        ps.start_date,
        ps.end_date,
        ps.annual_premium,
        ps.deductible,
        ps.sales_channel,
        ps.updated_at,
        pc.policy_changes_key,
        pc.change_type,
        pc.old_value,
        pc.new_value,
        pc.source
    FROM policies_selected ps
    LEFT JOIN POLICY_CHANGES pc 
      ON ps.policy_id = pc.policy_id
)

SELECT * FROM POLICY_HISTORY