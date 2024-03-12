with extract_jobs_classifiction as (
    select 
        classification_id,
        classification_info,
        classification_label
    from {{ ref('int_jobsdb_data')}}
)

select * from extract_jobs_classifiction