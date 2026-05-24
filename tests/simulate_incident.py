import boto3
import json
import argparse
import sys

def simulate_incident(state_machine_arn, instance_id):
    """
    Simulates an EventBridge trigger by manually starting a Step Function execution.
    """
    sfn = boto3.client('states')
    
    input_payload = {
        "instance_id": instance_id,
        "source": "Simulation Script",
        "reason": "Manual Fault Injection"
    }
    
    print(f"Starting simulation for instance: {instance_id}")
    print(f"State Machine: {state_machine_arn}")
    
    try:
        response = sfn.start_execution(
            state_machineArn=state_machine_arn,
            input=json.dumps(input_payload)
        )
        
        execution_arn = response['executionArn']
        print("Execution started successfully.")
        print(f"Execution ARN: {execution_arn}")
        print("\nMonitor the execution in the AWS Console or check the SNS/Slack alerts.")
        
    except Exception as e:
        print(f"Error starting simulation: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Simulate a CloudWatch/EventBridge incident trigger.")
    parser.add_argument("--sfn-arn", required=True, help="The ARN of the Remediation Step Function")
    parser.add_argument("--instance-id", required=True, help="The ID of the EC2 instance to 'remediate'")
    
    args = parser.parse_args()
    simulate_incident(args.sfn_arn, args.instance_id)
