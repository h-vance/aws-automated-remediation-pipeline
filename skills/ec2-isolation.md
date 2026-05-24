# Skill: EC2 Instance Isolation

## Description
This skill provides a secure, automated method for isolating a compromised EC2 instance by swapping its existing security groups with a restricted 'quarantine' security group that denies all ingress and egress traffic.

## Triggers
- CloudWatch Alarm: High CPU / Unusual Network Traffic
- GuardDuty Finding: EC2 instance compromise
- Security Hub Insight: Critical vulnerability detected

## Analyze Phase
1. **Identify Resource:** Extract `InstanceId` from the trigger event.
2. **Verify State:** Ensure the instance is in a 'running' or 'stopped' state.
3. **Check Tags:** Verify the instance does not have an 'Exempt' tag.

## Remediation Strategy
- **Action:** `ModifyInstanceAttribute`
- **Parameter:** `Groups`
- **Value:** `[QUARANTINE_SG_ID]`
- **Pre-requisite:** A security group with no ingress or egress rules.

## Validation Phase
- **Post-Check:** Verify that `DescribeInstanceAttribute` returns only the quarantine security group ID for the instance.
- **Security Check:** Ensure the quarantine group has no open ports (Checkov).

## Notification
- **Subject:** [ACTION TAKEN] EC2 Instance Isolated
- **Payload:** Include `InstanceId`, `OldSecurityGroups`, and `Timestamp`.
