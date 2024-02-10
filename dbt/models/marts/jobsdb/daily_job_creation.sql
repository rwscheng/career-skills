with daily_job_created as (
    select * from {{ ref("int_daily_jobs_created")}}
), daily_job_creation as (
    select 
        JOB_POST_DATE,
        sub_classification_info as "job_classifiction",
        JOBS_CREATED 
    from daily_job_created
)

select * from daily_job_creation