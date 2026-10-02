INSERT INTO INSURANCE_PROJECT.AUDIT.DQ_REJECTS (
    table_name,
    claim_id,
    failure_reason,
    failed_at
)
SELECT
    'STG_CLAIM_EVENTS' AS table_name,
    claim_id,
    'FUTURE_EVENT_TIMESTAMP' AS failure_reason,
    CURRENT_TIMESTAMP() AS failed_at
FROM INSURANCE_PROJECT.STAGING.STG_CLAIM_EVENTS
WHERE event_timestamp >= CURRENT_TIMESTAMP();