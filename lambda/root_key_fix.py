import boto3
import json
import os

iam = boto3.client("iam")
sns = boto3.client("sns")

SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")

def lambda_handler(event, context):
    print("Event:", json.dumps(event))

    try:
        # Root user has no username, so list all root keys
        keys = iam.list_access_keys()["AccessKeyMetadata"]

        for key in keys:
            iam.delete_access_key(AccessKeyId=key["AccessKeyId"])


        message = "🚨 Root access key was created and has been DELETED automatically."
        print(message)

        if SNS_TOPIC_ARN:
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Subject="Root Access Key Deleted",
                Message=message
            )

    except Exception as e:
        print("Error:", str(e))
        raise
