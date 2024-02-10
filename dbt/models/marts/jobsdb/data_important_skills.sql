-- This model is to group data job title by skills

with data_skills as (
    select 
        job_id,
        job_title,
        skills,
        required    
    from {{ ref("int_data_skills_unpivot")}}
), data_skills_job_groups as (
    select 
        case 
            when lower(job_title) like '%programmer%' then 'programmer'
            when lower(job_title) like '%developer%' then 'developer'
            when lower(job_title) like '%engineer%' then 'engineer'
            when lower(job_title) like '%analyst%' then 'analyst'
            when lower(job_title) like '%architect%' then 'architect'
            when lower(job_title) like '%science%' or lower(job_title) like '%scientist%' then 'scientist'
            when lower(job_title) like '%officer%' then 'officer'
            when lower(job_title) like '%support%' then 'support'
            when lower(job_title) like '%database%' then 'database_administrator'
            when lower(job_title) like '%solution%' then 'solution_specialist'
            when lower(job_title) like '%specialist%' then 'specialist'
            when lower(job_title) like '%project%' then 'project_specialist'
            when lower(job_title) like '%devops%' then 'devops_engineer'
        else 'others'
        end as job_group,
        job_id,
        job_title,
        skills,
        required
    from data_skills
), summarize_data_skills_per_group as (
    select
        job_group,
        skills,
        sum(required) as total_job_required
    from data_skills_job_groups
    group by 1,2 
)

select * from summarize_data_skills_per_group