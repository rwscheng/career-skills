-- This model is to aggregate the jobs the type (sub-class)

with jobs_subclass as (
    select 
        distinct 
        JOB_POST_DATE,
        job_id,
        sub_classification_id,
        sub_classification_info
    from {{ref("stg_vm_gc__jobsdb_data")}}
), jobs_subclass_grouped as (
    select 
        JOB_POST_DATE,
        sub_classification_id,
        sub_classification_info,
        count(job_id) as "JOBS_CREATED"
    from jobs_subclass
    group by 1,2,3
)

select * from jobs_subclass_grouped