{{
   config(
    materialized='view',
    schema='silver',
    alias='runway_cnt',
    tags= ["aero_stats"]
) }}

select 
    air.airport_identifier,
    count(*) as number_of_runways

from {{ ref('stg_airports') }} air
left join  {{ ref('stg_runways') }} runway
on air.airport_identifier = runway.airport_ident

group by 1
order by 1 asc