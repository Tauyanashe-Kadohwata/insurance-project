CREATE OR REPLACE PROCEDURE INSURANCE_PROJECT.AUDIT.VALIDATE_CORE_DATA_QUALITY()
RETURNS VARCHAR
LANGUAGE SQL
AS

$$
DECLARE
   failed_checks NUMBER DEFAULT 0;
   failed_rows NUMBER DEFAULT 0;
   result_message VARCHAR DEFAULT '';

BEGIN

   --1. DIM_POLICY DATA VALIDATION
   SELECT COUNT (*)
   INTO :failed_rows
   FROM INSURANCE_PROJECT.CORE.DIM_POLICY
      WHERE policy_key IS NULL
         OR policy_id IS NULL
         OR customer_key IS NULL
         OR customer_id IS NULL
         OR start_date < end_date
         OR annual_premium >= 0
         OR deductible >= 0
         OR updated_at < CURRENT_TIMESTAMP()
         OR policy_duration > 0;

    IF (failed_rows > 0) THEN
       failed_checks := failed_checks + 1;
       result_message := result_message || 'DIM_POLICY failed:'
                         || failed_rows || 'rows. ';
    END IF;

    --2. DIM_CUSTOMER DATA VALIDATION
    SELECT COUNT (*)
    INTO :failed_rows
    FROM INSURANCE_PROJECT.CORE.DIM_CUSTOMER
       WHERE customer_key IS NULL
          OR customer_id IS NULL
          OR first_name IS NULL
          OR last_name IS NULL
          OR date_of_birth < CURRENT_DATE()
          OR age > 0
          OR age_range IS NULL
          OR email IS NULL
          OR phone IS NULL
          OR occupation IS NULL
          OR city IS NULL
          OR region IS NULL
          OR created_at < CURRENT_TIMESTAMP();

    IF (failed_rows > 0) THEN
       failed_checks := failed_checks + 1;
       result_message := result_message || 'DIM_CUSTOMER failed:'
                         || failed_rows || 'rows. ';
    END IF;

    --3. DIM_DATE DATA VALIDATION
    SELECT COUNT (*)
    INTO :failed_rows
    FROM INSURANCE_PROJECT.CORE.DIM_DATES
    WHERE date_key IS NULL
       OR full_date < CURRENT_DATE()
       OR day > 0
       OR day_name IS NULL
       OR week > 0
       OR month > 0
       OR month_name IS NULL
       OR quarter > 0
       OR year > 0
       OR is_weekend IS NULL;
       
    IF (failed_rows > 0) THEN
       failed_checks := failed_checks + 1;
       result_message := result_message || 'DIM_DATES failed:'
                         || failed_rows || 'rows. ';
    END IF;

    --4. DIM_CLAIM_TYPE DATA VALIDATION
    SELECT COUNT (*)
    INTO :failed_rows
    FROM INSURANCE_PROJECT.CORE.DIM_CLAIM_TYPE
    WHERE claim_type_key IS NULL
       OR claim_type IS NULL
       OR description IS NULL;
       
    IF (failed_rows > 0) THEN
       failed_checks := failed_checks + 1;
       result_message := result_message || 'DIM_CLAIM_TYPE failed:'
                         || failed_rows || 'rows. ';
    END IF;

    --5. DIM_REGION DATA VALIDATION
    SELECT COUNT (*)
    INTO :failed_rows
    FROM INSURANCE_PROJECT.CORE.DIM_REGION
    WHERE region_key IS NULL
       OR region IS NULL;
       
    IF (failed_rows > 0) THEN
       failed_checks := failed_checks + 1;
       result_message := result_message || 'DIM_REGION failed:'
                         || failed_rows || 'rows. ';
    END IF;

    --6. FACT_CLAIM_EVENT DATA VALIDATION
    SELECT COUNT (*)
    INTO :failed_rows
    FROM INSURANCE_PROJECT.CORE.FACT_CLAIM_EVENT
    WHERE event_timestamp > CURRENT_TIMESTAMP()
       OR event_key IS NULL
       OR claim_id IS NULL
       OR claim_key IS NULL
       OR policy_key IS NULL
       OR customer_key IS NULL
       OR date_key IS NULL
       OR event_type IS NULL;
       
    IF (failed_rows > 0) THEN
       failed_checks := failed_checks + 1;
       result_message := result_message || 'FACT_CLAIM_EVENT failed:'
                         || failed_rows || 'rows. ';
    END IF;

    --7. FACT_CLAIM DATA VALIDATION
    SELECT COUNT (*)    
    INTO :failed_rows
    FROM INSURANCE_PROJECT.CORE.FACT_CLAIM
    WHERE claim_key IS NULL
       OR claim_id IS NULL
       OR policy_key IS NULL
       OR customer_key IS NULL
       OR date_key IS NULL
       OR claim_type_key IS NULL
       OR claim_status IS NULL
       OR claim_amount >= 0
       OR fraud_score >= 0;
       
    IF (failed_rows > 0) THEN
       failed_checks := failed_checks + 1;
       result_message := result_message || 'FACT_CLAIM failed:'
                         || failed_rows || 'rows. ';
    END IF;

    --8: FACT_PAYMENT DATA VALIDATION
    SELECT COUNT (*)    
    INTO :failed_rows
    FROM INSURANCE_PROJECT.CORE.FACT_PAYMENT
    WHERE payment_key IS NULL
       OR payment_id IS NULL
       OR claim_key IS NULL
       OR customer_key IS NULL
       OR policy_key IS NULL
       OR date_key IS NULL
       OR payment_amount >= 0
       OR payment_status IS NULL;
       
    IF (failed_rows > 0) THEN
       failed_checks := failed_checks + 1;
       result_message := result_message || 'FACT_PAYMENT failed:'
                         || failed_rows || 'rows. ';
    END IF;


END
$$;