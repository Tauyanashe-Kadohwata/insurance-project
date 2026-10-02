-- 1. Create a table with a single Variant column to house the text
CREATE TABLE raw_policy_changes (
    raw_data VARIANT
);

-- 2. Create a file format specifically for JSON
CREATE OR REPLACE FILE FORMAT my_json_format
  TYPE = 'JSON';

-- 3. Load the local file from your Snowflake stage
COPY INTO raw_policy_changes_changes
FROM @policy_changes/policy_changes.jsonl
FILE_FORMAT = (FORMAT_NAME = my_json_format);




