import json
import boto3
import logging
import os

# Configure logging for CloudWatch
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Region awareness: Inherit from environment or default to us-east-1
region = os.environ.get('AWS_REGION', 'us-east-1')
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    """
    Automated remediation to isolate a compromised EC2 instance.
    This function removes the instance from its current security groups 
    and attaches a 'quarantine' security group with no ingress/egress.
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    # Extract Instance ID from the event (sent by Step Functions or EventBridge)
    instance_id = event.get('detail', {}).get('instance_id') or event.get('instance_id')
    quarantine_sg_id = os.environ.get('QUARANTINE_SG_ID') or event.get('quarantine_sg_id')
    
    if not instance_id:
        logger.error("No instance_id found in event.")
        return {'statusCode': 400, 'body': 'instance_id missing'}

    if not quarantine_sg_id:
        logger.error("No quarantine_sg_id found in environment or event.")
        return {'statusCode': 400, 'body': 'quarantine_sg_id missing'}

    try:
        # Idempotency: Check if the instance is already isolated
        logger.info(f"Checking isolation status for instance: {instance_id}")
        instance_info = ec2.describe_instances(InstanceIds=[instance_id])
        current_groups = [sg['GroupId'] for sg in instance_info['Reservations'][0]['Instances'][0]['SecurityGroups']]
        
        if len(current_groups) == 1 and current_groups[0] == quarantine_sg_id:
            logger.info(f"Instance {instance_id} is already isolated.")
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'Instance already isolated',
                    'instance_id': instance_id,
                    'action': 'None'
                })
            }

        # 1. Modify the instance's security groups to the quarantine group
        logger.info(f"Isolating instance: {instance_id}")
        response = ec2.modify_instance_attribute(
            InstanceId=instance_id,
            Groups=[quarantine_sg_id]
        )
        
        logger.info(f"Successfully isolated instance {instance_id}")
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Instance isolated successfully',
                'instance_id': instance_id,
                'action': 'Security Group Swap'
            })
        }
        
    except Exception as e:
        logger.error(f"Error isolating instance {instance_id}: {str(e)}")
        raise e
