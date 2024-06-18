import os
import boto3
import json
import urllib
import datetime as dt

def lambda_handler(event, context):
    client = boto3.client('emr-serverless')

    application_id = os.environ.get('APPLICATION_ID')
    input_bucket = event['Records'][0]['s3']['bucket']['name']
    input_key = event['Records'][0]['s3']['object']['key']
    print(f'input_key: {urllib.parse.unquote_plus(input_key)}')
    output_bucket = os.environ.get('OUTPUT_BUCKET')
    # outputのfile名を定義したい
    # input_keyのファイル名を取得して、filename_yyyymmddhhmiss.csvのようにする
    # input_keyはS3バケットのファイルパスを表す文字列で、ファイル名を取得するためには拡張子を除いた部分を取得する必要がある
    # 例：input_key = 'input.csv'の場合、output_key = 'input_20210101120000'
    output_key = input_key.split('.')[0] + dt.datetime.now().strftime('_%Y%m%d%H%M%S')
    print(f'output_key: {urllib.parse.unquote_plus(output_key)}')

    print(f'Input path: s3://{input_bucket}/{input_key}')
    print(f'Output path: s3://{output_bucket}/{output_key}')

    response = client.start_job_run(
        applicationId=application_id,
        executionRoleArn=os.environ.get('EMR_SERVERLESS_ROLE'),
        jobDriver={
            'sparkSubmit': {
                'entryPoint': os.environ.get('ENTRY_POINT'),
                'entryPointArguments': [input_bucket, input_key, output_bucket, output_key],
                'sparkSubmitParameters': os.environ.get('SPARK_SUBMIT_PARAMETERS')
            }
        }
    )

    print(response)

    return {
        'statusCode': 200,
        'body': json.dumps('Job started successfully'),
        'jobRunId': response['jobRunId']
    }
