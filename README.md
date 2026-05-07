# AWS Automated Remediation Pipeline

**Event-Driven Incident Response & Cloud Operations Automation**

This repository implements a production-grade, event-driven remediation system on AWS. It automates the detection, isolation, and resolution of common infrastructure failures and security threats, reducing MTTR (Mean Time To Resolution) from minutes to seconds.

## Architecture

The system follows an **Observe -> Orient -> Decide -> Act** (OODA loop) pattern:

1.  **Observe:** CloudWatch Alarms or GuardDuty detect an anomaly.
2.  **Orient:** EventBridge triggers an AWS Step Functions state machine.
3.  **Decide:** Step Functions orchestrate logic to gather context and determine the appropriate fix.
4.  **Act:** Lambda functions execute the remediation (e.g., isolating an instance, updating WAF rules) and notify stakeholders via Slack/SNS.

## Tech Stack

-   **IaC:** Terraform (Modular architecture)
-   **Orchestration:** AWS Step Functions
-   **Compute:** AWS Lambda (Python/Boto3)
-   **Observability:** CloudWatch, EventBridge, SNS
-   **CI/CD:** GitHub Actions with OIDC (Zero-trust)
-   **Security:** IAM (Least-privilege), Checkov scanning

## Implementation Roadmap

See [ROADMAP.md](./ROADMAP.md) for a detailed phase-by-phase breakdown.

---
Operations and Reliability Engineered (c) 2026 Harrison Vance.
