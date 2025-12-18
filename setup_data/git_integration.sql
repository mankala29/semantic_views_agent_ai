use role accountadmin;
USE DATABASE SV_VHOL_DB;
USE SCHEMA VHOL_SCHEMA;
    -- Create API Integration for GitHub (public repository access)
    CREATE OR REPLACE API INTEGRATION git_api_integration
        API_PROVIDER = git_https_api
        API_ALLOWED_PREFIXES = ('https://github.com/mankala29/')
        ENABLED = TRUE;

    ALTER API INTEGRATION GIT_API_INTEGRATION
    SET ALLOWED_AUTHENTICATION_SECRETS = (
    'SV_VHOL_DB.VHOL_SCHEMA.TOK_PROPERTY_LIST'
    );

    
    GRANT USAGE ON INTEGRATION GIT_API_INTEGRATION TO ROLE agentic_analytics_vhol_role;

    use role agentic_analytics_vhol_role;
    -- Create Git repository integration for the public demo repository
    CREATE OR REPLACE GIT REPOSITORY AA_VHOL_REPO
        API_INTEGRATION = git_api_integration
        ORIGIN = 'https://github.com/mankala29/Snowflake_AI_DEMO.git';

    -- Create internal stage for copied data files
    CREATE OR REPLACE STAGE INTERNAL_DATA_STAGE
        FILE_FORMAT = CSV_FORMAT
        COMMENT = 'Internal stage for copied demo data files'
        DIRECTORY = ( ENABLE = TRUE)
        ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');

    ALTER GIT REPOSITORY AA_VHOL_REPO FETCH;

-- ========================================================================
    -- COPY DATA FROM GIT TO INTERNAL STAGE
-- ========================================================================

    -- Copy all CSV files from Git repository demo_data folder to internal stage
    COPY FILES
    INTO @INTERNAL_DATA_STAGE/demo_data/
    FROM @AA_VHOL_REPO/branches/main/demo_data/;

    COPY FILES
    INTO @INTERNAL_DATA_STAGE/unstructured_docs/
    FROM @AA_VHOL_REPO/branches/main/unstructured_docs/;

    -- Verify files were copied
    LS @INTERNAL_DATA_STAGE;

    ALTER STAGE INTERNAL_DATA_STAGE refresh;
