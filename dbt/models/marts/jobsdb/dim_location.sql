with extract_location as (
    select distinct
        location_id,
        location_label
    from {{ ref('int_jobsdb_data')}}
)

select * from extract_location