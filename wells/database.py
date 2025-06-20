import logging
import os

from botocore.exceptions import ClientError
import boto3

from wells.hash_log import hash_log

logging.basicConfig(level=logging.INFO)

TABLE_NAME = os.getenv("RESOURCE_NAME")
dynamodb = boto3.resource("dynamodb")


def record_to_db(obj, bucket, key):
    hash_val = hash_log(obj)

    table = dynamodb.Table(TABLE_NAME)
    item = {
        "Id": hash_val,
        "Bucket": bucket,
        "S3Key": key,
    }

    try:
        table.put_item(
            Item=item,
            ConditionExpression="attribute_not_exists(Id)"
        )
        logging.info("Added well log data to the database")
    except ClientError as error:
        code = "ConditionalCheckFailedException"
        if error.response["Error"]["Code"] == code:
            logging.info("TIFF file already exists!")
        else:
            raise error
    except Exception as error:
        raise error
