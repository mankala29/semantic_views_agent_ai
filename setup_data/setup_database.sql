--- This script borrows heavily from the Snowflake Intelligence end to end demo here: https://github.com/NickAkincilar/Snowflake_AI_DEMO

--- should take around 2 minutes to run completely


 -- Switch to accountadmin role to create warehouse
    USE ROLE accountadmin;

    -- Enable Snowflake Intelligence by creating the Config DB & Schema
    CREATE DATABASE IF NOT EXISTS agentic_analytics_vhol;
    CREATE SCHEMA IF NOT EXISTS agentic_analytics_vhol.agents;

    -- Allow anyone to see the agents in this schema
    GRANT USAGE ON DATABASE agentic_analytics_vhol TO ROLE PUBLIC;
    GRANT USAGE ON SCHEMA agentic_analytics_vhol.agents TO ROLE PUBLIC;

    create or replace role agentic_analytics_vhol_role;

    SET current_user_name = CURRENT_USER();

    -- Step 2: Use the variable to grant the role
    GRANT ROLE agentic_analytics_vhol_role TO USER IDENTIFIER($current_user_name);
    GRANT CREATE DATABASE ON ACCOUNT TO ROLE agentic_analytics_vhol_role;

    -- Create a dedicated warehouse for the demo with auto-suspend/resume
    CREATE OR REPLACE WAREHOUSE agentic_analytics_vhol_wh 
        WITH WAREHOUSE_SIZE = 'XSMALL'
        AUTO_SUSPEND = 300
        AUTO_RESUME = TRUE;


    -- Grant usage on warehouse to admin role
    GRANT USAGE ON WAREHOUSE agentic_analytics_vhol_wh TO ROLE agentic_analytics_vhol_role;

    -- Alter current user's default role and warehouse to the ones used here
    ALTER USER IDENTIFIER($current_user_name) SET DEFAULT_ROLE = agentic_analytics_vhol_role;
    ALTER USER IDENTIFIER($current_user_name) SET DEFAULT_WAREHOUSE = agentic_analytics_vhol_wh;
    
    -- Switch to SF_Intelligence_Demo role to create demo objects
    use role agentic_analytics_vhol_role;

    -- Create database and schema
    CREATE OR REPLACE DATABASE SV_VHOL_DB;
    USE DATABASE SV_VHOL_DB;

    CREATE SCHEMA IF NOT EXISTS VHOL_SCHEMA;
    USE SCHEMA VHOL_SCHEMA;

    -- Create file format for CSV files
    CREATE OR REPLACE FILE FORMAT CSV_FORMAT
        TYPE = 'CSV'
        FIELD_DELIMITER = ','
        RECORD_DELIMITER = '\n'
        SKIP_HEADER = 1
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        TRIM_SPACE = TRUE
        ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
        ESCAPE = 'NONE'
        ESCAPE_UNENCLOSED_FIELD = '\134'
        DATE_FORMAT = 'YYYY-MM-DD'
        TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS'
        NULL_IF = ('NULL', 'null', '', 'N/A', 'n/a');