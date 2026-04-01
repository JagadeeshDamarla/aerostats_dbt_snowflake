/*
Author: Jagadeesh D
Created date: 01-04-2026
Modified date: 01-Apr-2026
Version: 1
Purpose: This layer will create the staging layer for runways table.
Source: dbt_test.raw.runways
-- resource for dbt config block https://hevodata.com/data-transformation/dbt-configs/
*/
{{ config(
    materialized='view',
    schema='bronze',
    alias='stg_runways',
    tags= ["aero_stats"]
) }}

with source as (
    /* This pulls from the source defined in your YAML */
    select * from  {{ source('raw_aviation', 'runways') }}
    where airport_ident is not null or trim(airport_ident) != ''
   
)
-- the best way is to define proper column names, since this practise excercise not doing so
select * from source
