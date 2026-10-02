CREATE OR REPLACE TABLE INSURANCE_PROJECT.CORE.DIM_DATES AS
SELECT
    TO_NUMBER(TO_CHAR(full_date, 'YYYYMMDD')) AS date_key,
    full_date,
    DAY(full_date) AS day,
    DAYNAME(full_date) AS day_name,
    WEEK(full_date) AS week,
    MONTH(full_date) AS month,
    MONTHNAME(full_date) AS month_name,
    QUARTER(full_date) AS quarter,
    YEAR(full_date) AS year,
    DAYOFWEEK(full_date) IN (6, 7) AS is_weekend
FROM (
    SELECT DATEADD(
        day,
        SEQ4(),
        '2020-01-01'::DATE
    ) AS full_date
    FROM TABLE(GENERATOR(ROWCOUNT => 4018))
);