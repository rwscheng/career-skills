with data_important_skills as (
    select 
        job_group,
        skills,
        total_job_required
    from {{ ref('data_important_skills')}}
), data_skills_rank as (
    select 
        job_group,
        skills,
        total_job_required,
        ROW_NUMBER() OVER (partition by job_group order by total_job_required desc) as skill_rank
    from data_important_skills  
), top3_master_data_skills as (
    select
        job_group,
        skills,
        total_job_required
    from data_skills_rank
    where skill_rank < 4
)

select * from top3_master_data_skills