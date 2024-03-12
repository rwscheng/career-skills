with int_jobs as (
    select 
        job_id,
        job_title,
        job_group,
        job_grading,
        abstract,
        detail,
        status,
        job_post_date,
        has_role_requirement,
        is_private_advertiser,
        is_link_out,
        is_verified,
        classification_id,
        sub_classification_id,
        advertiser_id,
        work_type_id,
        location_id
    from {{ ref('int_jobsdb_data')}}
)

select * from int_jobs