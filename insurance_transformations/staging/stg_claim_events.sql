CREATE OR REPLACE TABLE STG_CLAIM_EVENTS  AS
WITH CLEANED AS (
   SELECT 
    raw_data:claim_id::INT AS claim_id,
    raw_data:event_type::STRING AS event_type,
    raw_data:timestamp::TIMESTAMP AS event_timestamp,
    raw_data:source::STRING AS event_source,
    raw_data:metadata:document_type::STRING AS document_type,
    raw_data:metadata:device::STRING AS device_type
FROM insurance_project.raw.raw_claim_logs
),

VALIDATED_DATA AS (
    SELECT *
    FROM CLEANED
    WHERE claim_id IS NOT NULL
    AND event_timestamp IS NOT NULL
    AND event_type IS NOT NULL
),
DEDUPLICATED AS (
    SELECT *
    FROM VALIDATED_DATA
    QUALIFY ROW_NUMBER() OVER (PARTITION BY claim_id, event_type, event_timestamp
    ORDER BY event_timestamp DESC) = 1
)
SELECT * 
FROM DEDUPLICATED;