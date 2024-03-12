with extract_jobs_bullets as (
    select 
        job_id,
        job_bullet
    from {{ ref('int_jobsdb_data')}}
) 
select * from extract_jobs_bullets