import boto3
import json
import os

ec2 = boto3.client("ec2")
sns = boto3.client("sns")

SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")

def lambda_handler(event, context):
    print("Event:", json.dumps(event))

    # Extract SG ID from AWS Config event
    sg_id = event["detail"]["resourceId"]

    try:
        # Describe current rules
        response = ec2.describe_security_groups(GroupIds=[sg_id])
        sg = response["SecurityGroups"][0]

        for rule in sg.get("IpPermissions", []):
            if rule.get("FromPort") == 22 and rule.get("ToPort") == 22:
                for ip_range in rule.get("IpRanges", []):
                    if ip_range["CidrIp"] == "0.0.0.0/0":
                        ec2.revoke_security_group_ingress(
                            GroupId=sg_id,
                            IpProtocol="tcp",
                            FromPort=22,
                            ToPort=22,
                            CidrIp="0.0.0.0/0"
                        )

        message = f"🚨 Open SSH detected and revoked automatically on Security Group {sg_id}"
        print(message)

        if SNS_TOPIC_ARN:
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Subject="Open SSH Closed Automatically",
                Message=message
            )

    except Exception as e:
        print("Error:", str(e))
        raise
