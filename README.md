# Career Skills

The skills you needed for improving your career.

### Data Extraction

The infrastructure is built on AWS with Terraform. Snowflake as the DWH.
The json data is extracted from a API and staging in AWS S3.
Then the json file will be transformed to Parquet format in Lambda in a event driven architecture.

### Data Load
The incremental data is ingested into snowflake with snowpipe. 
Two Databases are used. One for the raw data from S3, one for the analysis.

### Data Transform
DBT is used for the transfomation process.

### Prerequisites

The things you need before installing the software.

* Terraform
* AWS account
* DBT cloud/ core
* snowflake account

### Data Analytics
Power BI is used for the analytics.

