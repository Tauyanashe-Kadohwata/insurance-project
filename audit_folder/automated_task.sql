-- ============================================================
-- INSURANCE PROJECT - SNOWFLAKE TASK GRAPH
-- ============================================================

USE DATABASE INSURANCE_PROJECT;


-- ============================================================
-- SUSPEND EXISTING TASKS (if any) BEFORE RECREATING
-- The root task must be suspended first; this cascades to children.
-- ============================================================

ALTER TASK IF EXISTS INSURANCE_PROJECT.AUDIT.INSURANCE_PIPELINE_ROOT SUSPEND;


-- ============================================================
-- 1. ROOT TASK
-- Starts the pipeline every day at 06:00 UTC
-- ============================================================

CREATE OR REPLACE TASK INSURANCE_PROJECT.AUDIT.INSURANCE_PIPELINE_ROOT
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = 'USING CRON 0 6 * * * UTC'
AS
    SELECT 'Insurance pipeline started' AS pipeline_status;


-- ============================================================
-- 2. STAGING DATA QUALITY
-- Runs after the root task
-- ============================================================

CREATE OR REPLACE TASK INSURANCE_PROJECT.AUDIT.RUN_STAGING_DQ
    WAREHOUSE = COMPUTE_WH
    AFTER INSURANCE_PROJECT.AUDIT.INSURANCE_PIPELINE_ROOT
AS
    CALL INSURANCE_PROJECT.AUDIT.VALIDATE_STAGING_DATA_QUALITY();


-- ============================================================
-- 3. BUILD CORE
-- Replace the procedure name below with your actual
-- CORE build/refresh procedure.
-- ============================================================

CREATE OR REPLACE TASK INSURANCE_PROJECT.AUDIT.BUILD_CORE
    WAREHOUSE = COMPUTE_WH
    AFTER INSURANCE_PROJECT.AUDIT.RUN_STAGING_DQ
AS
    CALL INSURANCE_PROJECT.AUDIT.BUILD_CORE_DATA();


-- ============================================================
-- 4. CORE DATA QUALITY
-- Replace procedure name if yours is different.
-- ============================================================

CREATE OR REPLACE TASK INSURANCE_PROJECT.AUDIT.RUN_CORE_DQ
    WAREHOUSE = COMPUTE_WH
    AFTER INSURANCE_PROJECT.AUDIT.BUILD_CORE
AS
    CALL INSURANCE_PROJECT.AUDIT.VALIDATE_CORE_DATA_QUALITY();


-- ============================================================
-- 5. BUILD MARTS
-- Replace with your actual marts procedure.
-- ============================================================

CREATE OR REPLACE TASK INSURANCE_PROJECT.AUDIT.BUILD_MARTS
    WAREHOUSE = COMPUTE_WH
    AFTER INSURANCE_PROJECT.AUDIT.RUN_CORE_DQ
AS
    CALL INSURANCE_PROJECT.AUDIT.BUILD_MARTS_DATA();


-- ============================================================
-- ENABLE TASK GRAPH
-- Child tasks first, root task last
-- ============================================================

ALTER TASK INSURANCE_PROJECT.AUDIT.BUILD_MARTS RESUME;

ALTER TASK INSURANCE_PROJECT.AUDIT.RUN_CORE_DQ RESUME;

ALTER TASK INSURANCE_PROJECT.AUDIT.BUILD_CORE RESUME;

ALTER TASK INSURANCE_PROJECT.AUDIT.RUN_STAGING_DQ RESUME;

ALTER TASK INSURANCE_PROJECT.AUDIT.INSURANCE_PIPELINE_ROOT RESUME;