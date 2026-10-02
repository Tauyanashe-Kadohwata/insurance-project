CREATE OR REPLACE PROCEDURE INSURANCE_PROJECT.AUDIT.VALIDATE_STAGING_DATA_QUALITY()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
DECLARE
    failed_checks NUMBER DEFAULT 0;
    failed_rows NUMBER DEFAULT 0;
    result_message VARCHAR DEFAULT '';

BEGIN

    -- 1. STG_CLAIMS 
    SELECT COUNT(*)
    INTO :failed_rows
    FROM INSURANCE_PROJECT.STAGING.STG_CLAIMS
    WHERE claim_id IS NULL
       OR policy_id IS NULL
       OR claim_date IS NULL
       OR claim_date >= CURRENT_DATE()
       OR claim_amount < 0;

    IF (failed_rows > 0) THEN
        failed_checks := failed_checks + 1;
        result_message := result_message || 'STG_CLAIMS failed: '
                          || failed_rows || ' rows. ';
    END IF;


    -- 2. STG_CUSTOMERS
    SELECT COUNT(*)
    INTO :failed_rows
    FROM INSURANCE_PROJECT.STAGING.STG_CUSTOMERS
    WHERE customer_id IS NULL
       OR date_of_birth IS NULL
       OR date_of_birth >= CURRENT_DATE();

    IF (failed_rows > 0) THEN
        failed_checks := failed_checks + 1;
        result_message := result_message || 'STG_CUSTOMERS failed: '
                          || failed_rows || ' rows. ';
    END IF;


    -- 3. STG_POLICIES
    SELECT COUNT(*)
    INTO :failed_rows
    FROM INSURANCE_PROJECT.STAGING.STG_POLICIES
    WHERE policy_id IS NULL
       OR customer_id IS NULL
       OR start_date IS NULL
       OR end_date IS NULL
       OR start_date > end_date
       OR annual_premium < 0
       OR deductible < 0;

    IF (failed_rows > 0) THEN
        failed_checks := failed_checks + 1;
        result_message := result_message || 'STG_POLICIES failed: '
                          || failed_rows || ' rows. ';
    END IF;


    --4. STG_PAYMENTS
    SELECT COUNT(*)
    INTO :failed_rows
    FROM INSURANCE_PROJECT.STAGING.STG_PAYMENTS
    WHERE payment_date >= CURRENT_DATE();

    IF (failed_rows > 0) THEN

    failed_checks := failed_checks + 1;

    INSERT INTO INSURANCE_PROJECT.AUDIT.DQ_REJECTS (
        table_name,
        claim_id,
        failure_reason,
        failed_at
    )
    SELECT
        'STG_PAYMENTS',
        claim_id,
        'FUTURE_PAYMENT_DATE',
        CURRENT_TIMESTAMP()
    FROM INSURANCE_PROJECT.STAGING.STG_PAYMENTS
    WHERE payment_date >= CURRENT_DATE();

    result_message := result_message || 'STG_PAYMENTS failed: '
                      || failed_rows || ' rows. ';
    END IF;


    -- 5. STG_CLAIM_EVENTS
    SELECT COUNT(*)
    INTO :failed_rows
    FROM INSURANCE_PROJECT.STAGING.STG_CLAIM_EVENTS
    WHERE event_timestamp >= CURRENT_TIMESTAMP();

    IF (failed_rows > 0) THEN

    failed_checks := failed_checks + 1;

    INSERT INTO INSURANCE_PROJECT.AUDIT.DQ_REJECTS (
        table_name,
        claim_id,
        failure_reason,
        failed_at
    )
    SELECT
        'STG_CLAIM_EVENTS',
        claim_id,
        'FUTURE_EVENT_TIMESTAMP',
        CURRENT_TIMESTAMP()
    FROM INSURANCE_PROJECT.STAGING.STG_CLAIM_EVENTS
    WHERE event_timestamp >= CURRENT_TIMESTAMP();

    result_message := result_message || 'STG_CLAIM_EVENTS failed: '
                      || failed_rows || ' rows. ';
    END IF;


    --6. STG_POLICY_CHANGES
    SELECT COUNT(*)
    INTO :failed_rows
    FROM INSURANCE_PROJECT.STAGING.STG_POLICY_CHANGES
    WHERE changed_at >= CURRENT_TIMESTAMP();

    IF (failed_rows > 0) THEN

    failed_checks := failed_checks + 1;

    INSERT INTO INSURANCE_PROJECT.AUDIT.DQ_REJECTS (
        table_name,
        claim_id,
        failure_reason,
        failed_at
    )
    SELECT
        'STG_POLICY_CHANGES',
        policy_id,
        'FUTURE_POLICY_CHANGE_TIMESTAMP',
        CURRENT_TIMESTAMP()
    FROM INSURANCE_PROJECT.STAGING.STG_POLICY_CHANGES
    WHERE changed_at >= CURRENT_TIMESTAMP();

    result_message := result_message || 'STG_POLICY_CHANGES failed: '
                      || failed_rows || ' rows. ';
    END IF;

END;
$$;