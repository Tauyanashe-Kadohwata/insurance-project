CREATE OR REPLACE TABLE INSURANCE_PROJECT.CORE.DIM_CUSTOMER AS

WITH CUSTOMER_AGE AS (
    SELECT
        INSURANCE_PROJECT.CORE.CUSTOMER_KEY_SEQ.NEXTVAL AS customer_key,
        customer_id,
        first_name,
        last_name,
        date_of_birth,
        email,
        phone,
        occupation,
        city,
        region,
        created_at,

        DATEDIFF('year', date_of_birth, CURRENT_DATE())
        - IFF(
            DATEADD(
                'year',
                DATEDIFF('year', date_of_birth, CURRENT_DATE()),
                date_of_birth
            ) > CURRENT_DATE(),
            1,
            0
        ) AS age

    FROM INSURANCE_PROJECT.STAGING.STG_CUSTOMERS
),

AGE_RANGES AS (
    SELECT
        *,
        CASE
            WHEN age < 18 THEN 'underage'
            WHEN age BETWEEN 18 AND 25 THEN '18-25'
            WHEN age BETWEEN 26 AND 35 THEN '26-35'
            WHEN age BETWEEN 36 AND 55 THEN '36-55'
            WHEN age > 55 THEN 'senior citizen'
            ELSE NULL
        END AS age_range
    FROM CUSTOMER_AGE
),

FINAL_SELECTION AS (
    SELECT
        customer_key,
        customer_id,
        first_name,
        last_name,
        date_of_birth,
        age,
        age_range,
        email,
        phone,
        occupation,
        city,
        region,
        created_at
    FROM AGE_RANGES
)

SELECT *
FROM FINAL_SELECTION;