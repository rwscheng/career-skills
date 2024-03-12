with jobs_bullets as (
    select 
        job_id,
        job_bullet
    from {{ ref("stg_vm_gc__jobsdb_data")}}
)

select * from jobs_bullets