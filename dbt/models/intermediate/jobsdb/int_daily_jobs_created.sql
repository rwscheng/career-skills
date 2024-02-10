-- This model is to aggregate the jobs the type (sub-class)

with jobs_subclass as (
    select 
        distinct 
        job_post_date,
        job_id,
        sub_classification_id,
        sub_classification_info
    from {{ref("stg_vm_gc__jobsdb_data")}}
), jobs_subclass_grouped as (
    select 
        job_post_date,
        sub_classification_id,
        sub_classification_info,
        count(job_id) as jobs_created
    from jobs_subclass
    group by 1,2,3
)

select * from jobs_subclass_grouped