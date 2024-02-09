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

with data_skill as (
    select * from
    {{ ref('int_data_skills')}}
), data_skills_unpivot as (
    Select 
        JOB_ID,
        JOB_TITLE,
        column_name AS skills,
        required
    FROM data_skill
    UNPIVOT (required FOR column_name IN (
        {% for column_name in columns_to_unpivot %}
            "{{ column_name }}" {% if not loop.last %},{% endif %}
        {% endfor %}
        )) AS unpivoted_data
)

select * from data_skills_unpivot