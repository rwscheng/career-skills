with extract_advertiser as (
    select distinct
        advertiser_id,
        advertiser_name
    from {{ ref('int_jobsdb_data')}}
)

select * from extract_advertiser