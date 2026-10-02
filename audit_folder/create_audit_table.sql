CREATE OR REPLACE TABLE INSURANCE_PROJECT.AUDIT.DQ_REJECTS (
    table_name       VARCHAR,
    claim_id         NUMBER,
    failure_reason   VARCHAR,
    failed_at        TIMESTAMP
);