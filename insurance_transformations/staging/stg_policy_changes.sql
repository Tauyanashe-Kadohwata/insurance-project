CREATE OR REPLACE TABLE STG_POLICY_CHANGES  AS
WITH CLEANED AS (
   SELECT 
    raw_data:policy_id::INT AS policy_id,
    raw_data:changed_at::TIMESTAMP AS changed_at,
    raw_data:change_type::STRING AS change_type,
    raw_data:old_value::STRING AS old_value,
    raw_data:new_value::STRING AS new_value,
    raw_data:source::STRING AS source
FROM insurance_project.raw.raw_policy_changes
),

VALIDATED_DATA AS (
    SELECT *
    FROM CLEANED
    WHERE policy_id IS NOT NULL
    AND changed_at IS NOT NULL
    AND change_type IS NOT NULL
),

DEDUPLICATED AS (
    SELECT *
    FROM VALIDATED_DATA
    QUALIFY ROW_NUMBER() OVER (PARTITION BY policy_id, changed_at, change_type, old_value, new_value, source 
    ORDER BY changed_at DESC) = 1
)

SELECT * 
FROM DEDUPLICATED;