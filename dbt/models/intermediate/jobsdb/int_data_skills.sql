-- This model is showing the most important skills for Data Egnineer

with jobs_detail as (
    select 
        distinct 
        job_id,
        job_title,
        lower(detail) as detail
    from {{ref("stg_jobs_api__jobsdb_data")}}
), jobs_data_skills as (
    select 
        job_id,
        job_title,
        case 
            when detail like '%aws%'
            then 1 else 0
        end as "aws",
        case 
            when detail like '%azure%'
            then 1 else 0
        end as "azure",
        case 
            when detail like '%gcp%' or detail like '%google%'
            then 1 else 0
        end as "gcp",       
        case 
            when detail like '%python%'
            then 1 else 0
        end as "python",
        case 
            when detail like '%java%'
            then 1 else 0
        end as "java_java_script",
        case 
            when detail like '%ml%' or detail like '%machine learning%'
            then 1 else 0
        end as "ml",
        case 
            when detail like '%big data%'
            then 1 else 0
        end as "big_data",
        case 
            when detail like '%spark%'
            then 1 else 0
        end as "spark",        
        case 
            when detail like '%data warehouse%'
            then 1 else 0
        end as "warehousing",  
        case 
            when detail like '%database%'
            then 1 else 0
        end as "database",             
        case 
            when detail like '%airflow%'
            then 1 else 0
        end as "airflow",            
        case 
            when detail like '%etl%'
            then 1 else 0
        end as "etl",    
        case 
            when detail like '%snowflake%'
            then 1 else 0
        end as "snowflake",                     
        case 
            when detail like '%databrick%'
            then 1 else 0
        end as "databrick",
        case 
            when detail like '%ai%'
            then 1 else 0
        end as "ai",
        case 
            when detail like '%powerbi%' or detail like '%power bi%'
            then 1 else 0
        end as "power_bi",        
        case 
            when detail like '%qlik%'
            then 1 else 0
        end as "qlik",        
        case 
            when detail like '%tableau%'
            then 1 else 0
        end as "tableau",        
        case 
            when detail like '%sql%'
            then 1 else 0
        end as "sql"
    from jobs_detail
)

select * from jobs_data_skills