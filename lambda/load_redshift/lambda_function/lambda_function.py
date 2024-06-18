import boto3
import os
import urllib


def lambda_handler(event, context):
    print(event)
    print(context)

    redshift = boto3.client('redshift-data')
    cluster_identifier = os.environ.get('REDSHIFT_CLUSTER_IDENTIFIER')
    database = os.environ.get('DATABASE_NAME')
    db_user = os.environ.get('DATABASE_USER')

    # イベントからファイル名とバケット名を取得
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])

    s3_path = f's3://{bucket}/{key}'

    table_name = os.environ.get('TABLE_NAME')
    redshift_iam_role_arn = os.environ.get('REDSHIFT_IAM_ROLE_ARN')

    copy_query = f"""
    COPY {database}.public.\"{table_name}\" 
    FROM '{s3_path}' 
    IAM_ROLE '{redshift_iam_role_arn}'
    FORMAT AS CSV DELIMITER ',' QUOTE '"'
    IGNOREHEADER 1 
    BLANKSASNULL 
    DATEFORMAT 'auto' 
    REGION AS 'ap-northeast-1'"""

    print(f'copy_query: {copy_query}')

    # Redshiftにクエリを送信
    redshift.execute_statement(
        ClusterIdentifier=cluster_identifier,
        Database=database,
        DbUser=db_user,
        Sql=copy_query
    )

