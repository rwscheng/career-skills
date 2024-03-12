{% set columns_to_unpivot = [
        'big_data',
        'power_bi',
        'snowflake',
        'gcp',
        'qlik',
        'etl',
        'databrick',
        'java_java_script',
        'ai',
        'aws',
        'ml',
        'sql',
        'spark',
        'database',
        'airflow',
        'python',
        'azure',
        'tableau',
        'warehousing'
    ] 
    %}

with data_jobs_skills as (
    select
        *
    from {{ ref('int_data_jobs_skills')}}
), data_jobs_skills_unpivot as (
    Select 
        job_id,
        column_name AS skills,
        is_required
    FROM data_jobs_skills
    UNPIVOT (is_required FOR column_name IN (
        {% for column_name in columns_to_unpivot %}
            "{{ column_name }}" {% if not loop.last %},{% endif %}
        {% endfor %}
        )) AS unpivoted_data
), data_jobs_required_skills as (
    select 
        job_id,
        skills
    from data_jobs_skills_unpivot
    where is_required = 1
)

select * from data_jobs_required_skills