
/*
    Model - JobsDB Data
    Directly extract from Snowflake
*/

with source_data as (
    select 
        "result.job.tracking.classificationInfo.classificationId" as classification_id,
        "result.job.tracking.classificationInfo.classification" as classification_info,
        "result.job.classifications.label" as classification_label,
        "result.job.tracking.classificationInfo.subClassificationId" as sub_classification_id,
        "result.job.tracking.classificationInfo.subClassification" as sub_classification_info,
        "result.job.tracking.hasRoleRequirements" as has_role_requirement,
        "result.job.tracking.isPrivateAdvertiser" as is_private_advertiser,
        "result.job.tracking.locationInfo.locationIds" as location_id,
        "result.job.location.label" as location_label,
        "result.job.products.bullets" as job_bullet,
        "result.job.tracking.workTypeIds" as work_type_id,
        "result.job.id" as job_id,
        "result.job.title" as job_title,
        "result.job.isLinkOut" as is_link_out,
        "result.job.isVerified" as is_verified,
        "result.job.abstract" as abstract,
        "result.job.content" as detail,
        "result.job.status" as status,
        "result.job.workTypes.label" as work_type_label,
        "result.job.advertiser.id" as advertiser_id,
        "result.job.advertiser.name" as advertiser_name,
        "result.learningInsights.analytics.title" as insight_title,
        JOB_POST_DATE
    from {{ source('vm_gc', 'DATA') }}
)

select *
from source_data

/*
    Uncomment the line below to remove records with null `id` values
*/

-- where id is not null
