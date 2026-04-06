# dbt Seeds: Quick Reference Guide

Seeds are CSV files in your dbt project that automatically load into your data warehouse. They are best used for **small, static datasets** (e.g., country codes, zip code mappings, fixed conversion rates). By default seed files will be created as tables in the default schema specified. In case you want to change the schema then use seeds.yml file which also serves purpose for defining the column types.

*Do not use seeds to load raw operational data or massive datasets.*

---

## 1. Core Commands

| Command | What it does |
| :--- | :--- |
| `dbt seed` | Loads all CSVs in the `seeds/` folder into your database. |
| `dbt seed --select my_seed` | Loads only a specific seed file named `my_seed.csv`. |
| `dbt seed --full-refresh` | Drops the existing table in Snowflake and rebuilds it from scratch (Required if you change the schema/column types). |
| `dbt seed --show` | Previews the data in the terminal without building it. |

---

## 2. Referencing Seeds in Models
Once seeded, treat the CSV exactly like a model. You do not use the `source()` function; you use the `ref()` function.

```sql
-- models/silver/int_airport_countries.sql
SELECT 
    a.airport_name,
    c.country_name
FROM {{ ref('stg_airports') }} a
LEFT JOIN {{ ref('country_codes') }} c -- Matches country_codes.csv
    ON a.country_id = c.id