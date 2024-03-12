with extract_jobs_classifiction as (
    select distinct
        classification_id,
        classification_info
    from {{ ref('int_jobsdb_data')}}
)

select * from extract_jobs_classifiction