with extract_jobs_bullets as (
    select 
        job_id,
        job_bullet
    from {{ ref('int_jobs_bullets')}}
) 
select * from extract_jobs_bullets