/*
Author: Jagadeesh D
Created date: 01-04-2026
Modified date: 01-Apr-2026
Version: 1
Purpose: This layer will create the staging layer for airports table.
Source: dbt_test.raw.airports
*/

{{ config(
    materialized='view',
    schema='bronze',
    alias='stg_airports',
    tags= ["aero_stats"]
) }}

with source as (
    /* This pulls from the source defined in your YAML */
    select * from  {{ source('raw_aviation', 'airports') }}
   
),

renamed as (
    select
        -- Identifiers
        id as airport_id,
        ident as airport_identifier,
        type as airport_type,
        name as airport_name,

        -- Geography 
        cast(latitude_deg as float) as latitude,
        cast(longitude_deg as float) as longitude,
        elevation_ft,
        continent,
        iso_country,
        iso_region,
        municipality,

        -- Codes & Metadata
        scheduled_service,
        gps_code,
        iata_code,
        local_code,
        home_link,
        wikipedia_link,
        keywords

    from source
)

select * from renamed