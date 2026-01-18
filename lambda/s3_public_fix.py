import boto3
import json
import os

s3 = boto3.client("s3")
sns = boto3.client("sns")

SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]

def lambda_handler(event, context):
    bucket = event["detail"]["resourceId"]

    # Fix bucket
    s3.put_public_access_block(
        Bucket=bucket,
        PublicAccessBlockConfiguration={
            "BlockPublicAcls": True,
            "IgnorePublicAcls": True,
            "BlockPublicPolicy": True,
            "RestrictPublicBuckets": True
        }
    )

    message = {
        "resource": bucket,
        "issue": "Public S3 bucket detected",
        "action": "Public access blocked automatically",
        "source": "AWS Automated Guardrails"
    }

    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Message=json.dumps(message),
        Subject="🚨 S3 Public Bucket Auto-Remediated"
    )

    return {"status": "fixed"}
