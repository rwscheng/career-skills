import json
import urllib.parse
import boto3
import pandas as pd
from flatsplode import flatsplode
import awswrangler as wr
import unicodedata

s3 = boto3.client('s3')

def remove_accents(input_str):
    if not input_str:
        return
    nkfd_form = unicodedata.normalize('NFKD', input_str)
    only_ascii = nkfd_form.encode('ASCII', 'ignore')
    return only_ascii.decode('utf-8')

def handler(event, context):
    bucket, key = object_fm_sqs(event)
    json_data = object_to_json(bucket, key)
    df_job = json_flatten(json_data)
    upload_s3(bucket, key, df_job)

def object_fm_sqs(event):
    '''To get the object from SQS'''
    try:
        records = event['Records'][0]['body']
        records = json.loads(records)
        bucket = records['Records'][0]['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(records['Records'][0]['s3']['object']['key'], encoding='utf-8')
    except Exception as e:
        print(e)
        print('Error Bucket Name and file key')
        raise e
    return bucket, key

def object_to_json(bucket, key):
    try:
        response = s3.get_object(Bucket=bucket, Key=key)
        file_content = response["Body"].read().decode('utf-8')
        json_data = json.loads(file_content)
    except Exception as e:
        print(e)
        print('Error getting object')
        raise e
    return json_data

def json_flatten(json_data):
    try:
        job_detail = list(flatsplode(json_data))
        df_job = pd.DataFrame(job_detail)
        for c in df_job.columns:
            if df_job[c].dtype == 'object':
                df_job[c] = df_job[c].apply(remove_accents)

    except Exception as e:
        print(e)
        print('Error flattening object')
        raise e
    return df_job

def upload_s3(bucket, key, df_job):
    file_path = key.replace('/raw/', '/parquet/').replace('.json', '.parquet')
    save_path = f's3://{bucket}/{file_path}'

    wr.s3.to_parquet(df=df_job, path=save_path, dataset=False)
    return True