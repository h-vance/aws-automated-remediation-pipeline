import json
import boto3
import logging

# Configure logging for CloudWatch
logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    """
    Automated remediation to isolate a compromised EC2 instance.
    This function removes the instance from its current security groups 
    and attaches a 'quarantine' security group with no ingress/egress.
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    # Extract Instance ID from the event (sent by Step Functions or EventBridge)
    instance_id = event.get('detail', {}).get('instance_id') or event.get('instance_id')
    quarantine_sg_id = event.get('quarantine_sg_id')
    
    if not instance_id:
        logger.error("No instance_id found in event.")
        return {'statusCode': 400, 'body': 'instance_id missing'}

    try:
        logger.info(f"Isolating instance: {instance_id}")
        
        # 1. Modify the instance's security groups to the quarantine group
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
