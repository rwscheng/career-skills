with jobsdb_data as (
    select 
        distinct job_group 
    from {{ref('int_jobsdb_data') }}
)

select * from jobsdb_data