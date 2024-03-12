with jobs_detail as (
    select 
        classification_id,
        classification_info,
        classification_label,
        sub_classification_id,
        sub_classification_info,
        has_role_requirement,
        is_private_advertiser,
        location_id,
        location_label,
        job_bullet,
        work_type_id,
        job_id,
        job_title,
        is_link_out,
        is_verified,
        abstract,
        detail,
        status,
        work_type_label,
        advertiser_id,
        advertiser_name,
        insight_title,
        job_post_date,
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
        case
            when lower(job_title) like '%sr %' 
                or lower(job_title) like '%senior%'
                then 'senior'
            when lower(job_title) like '%manager%' 
                then 'management'
            else 'junior'
        end as job_grading
    from {{ ref("stg_vm_gc__jobsdb_data")}}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY job_id ORDER BY job_post_date) = 1
)

select * from jobs_detail