with data_jobs_skills as (
    select 
        job_id,
        skills
    from {{ref('int_data_jobs_skills_unpivot')}}
)

select * from data_jobs_skills