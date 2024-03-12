with extract_work_type as (
    select distinct
        work_type_id,
        work_type_label
    from {{ ref('int_jobsdb_data')}}
)

select * from extract_work_type