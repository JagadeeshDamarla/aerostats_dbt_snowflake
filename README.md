# aerostats_dbt_snowflake
Test
# Steps
- Installing virtual env
- Installing dbt-snowflake `pip install dbt-snowflake` this is the driver to communicate with snowflake

# Roles from snowflake side
## Snowflake & dbt Access Control Setup

This project uses a dedicated service account and role to manage transformations via dbt. Snowflake's Role-Based Access Control (RBAC) requires explicit permissions at the Warehouse, Database, and Schema levels.

### Architecture Overview
* **Service Account:** `DBT_SERVICE_ACCOUNT`
* **Role:** `DBT_ROLE`
* **Warehouse:** `COMPUTE_WH`
* **Database:** `DBT_TEST`
* **Medallion Layers (Schemas):**
  * `RAW`: Landing zone for raw CSV extracts.
  * `BRONZE`: Staging models (1:1 views of raw data, cleaned and cast).
  * `SILVER`: Intermediate models (joined and standardized).
  * `GOLD`: Marts/Reporting models (aggregated for BI).

### Initial Permission Script
To replicate this environment or reset permissions, run the following script in a Snowflake Worksheet using the `ACCOUNTADMIN` or `SECURITYADMIN` role. 

This script grants dbt the ability to read the raw data, dynamically create schemas if they are missing, and build tables/views in the transformation layers.

```sql
USE ROLE ACCOUNTADMIN;

-- 1. Setup Role and User
CREATE ROLE IF NOT EXISTS DBT_ROLE;
GRANT ROLE DBT_ROLE TO USER DBT_SERVICE_ACCOUNT;
ALTER USER DBT_SERVICE_ACCOUNT SET DEFAULT_ROLE = DBT_ROLE;

-- 2. Grant Warehouse and Database Access
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE DBT_ROLE;
GRANT USAGE ON DATABASE DBT_TEST TO ROLE DBT_ROLE;
GRANT CREATE SCHEMA ON DATABASE DBT_TEST TO ROLE DBT_ROLE;

-- 3. Create Medallion Schemas
CREATE SCHEMA IF NOT EXISTS DBT_TEST.RAW;
CREATE SCHEMA IF NOT EXISTS DBT_TEST.BRONZE;
CREATE SCHEMA IF NOT EXISTS DBT_TEST.SILVER;
CREATE SCHEMA IF NOT EXISTS DBT_TEST.GOLD;

-- 4. Grant Read Access to RAW Data
GRANT USAGE ON SCHEMA DBT_TEST.RAW TO ROLE DBT_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA DBT_TEST.RAW TO ROLE DBT_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA DBT_TEST.RAW TO ROLE DBT_ROLE;

-- 5. Grant Write/Build Access to Medallion Layers
-- BRONZE
GRANT USAGE, CREATE TABLE, CREATE VIEW ON SCHEMA DBT_TEST.BRONZE TO ROLE DBT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA DBT_TEST.BRONZE TO ROLE DBT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN SCHEMA DBT_TEST.BRONZE TO ROLE DBT_ROLE;

-- SILVER
GRANT USAGE, CREATE TABLE, CREATE VIEW ON SCHEMA DBT_TEST.SILVER TO ROLE DBT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA DBT_TEST.SILVER TO ROLE DBT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN SCHEMA DBT_TEST.SILVER TO ROLE DBT_ROLE;

-- GOLD
GRANT USAGE, CREATE TABLE, CREATE VIEW ON SCHEMA DBT_TEST.GOLD TO ROLE DBT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA DBT_TEST.GOLD TO ROLE DBT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN SCHEMA DBT_TEST.GOLD TO ROLE DBT_ROLE;
```