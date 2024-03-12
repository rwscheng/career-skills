with extract_jobs_sub_classifiction as (
    select 
        sub_classification_id,
        sub_classification_info
    from {{ ref('int_jobsdb_data')}}
)

select * from extract_jobs_sub_classifiction