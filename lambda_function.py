import logging

import boto3

from wells.database import record_to_db

logging.basicConfig(level=logging.INFO)
s3 = boto3.client("s3")


def lambda_handler(event, context):
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = event["Records"][0]["s3"]["object"]["key"]

    try:
        response = s3.get_object(Bucket=bucket, Key=key)
    except Exception as e:
        logging.error(e, exc_info=True)
        raise e
    else:
        obj = response["Body"].read()

    record_to_db(obj, bucket, key)
