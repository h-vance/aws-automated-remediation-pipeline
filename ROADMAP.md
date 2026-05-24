# Roadmap: AWS Automated Remediation Pipeline

This roadmap outlines the end-to-end implementation of an event-driven, automated incident remediation system. This project bridges deep operational experience with modern cloud automation, proving reliability at scale.

## Phase 1: Foundation and CI/CD Infrastructure
Goal: Establish a secure, automated deployment pipeline using enterprise best practices.

- [x] Initialize repository structure and documentation.
- [x] Configure AWS OIDC for GitHub Actions (Zero-trust authentication).
- [x] Implement GitHub Actions workflow for Terraform Plan/Apply.
- [x] Set up Terraform remote state (S3 bucket and DynamoDB locking).
- [x] Integrate static analysis and security scanning (TFLint, Checkov, Trivy).
- [ ] Integrate cost estimation (Infracost) for proposed remediation fixes.

## Phase 2: Core Remediation Logic and Skill Architecture
Goal: Develop the "brain" of the system using a skill-based model.

- [x] Define the Remediation Skill schema (Markdown-based playbooks).
- [x] Create initial skills: `ec2-isolation.md` and `s3-hardening.md`.
- [x] Implement the Python orchestration layer to interpret skills and generate remediation plans.
- [ ] Create unit tests for Python logic using moto and pytest.

## Phase 3: Modular Infrastructure as Code
Goal: Define the system components using modular, reusable Terraform following terraform-skill standards.

- [x] **terraform-aws-remediation-core:** Lambda functions, IAM roles, and execution logs.
- [x] **terraform-aws-notification-engine:** SNS topics and webhook configurations.
- [ ] Implement Native Terraform Tests for module validation.
- [ ] Generate documentation using terraform-docs.

## Phase 4: Orchestration (AWS Step Functions)
Goal: Build the "brain" that coordinates the remediation workflow.

- [x] Design the Step Functions State Machine:
  - State: Context Gathering
  - Choice: Is Remediation Possible?
  - State: Execute Fix
  - State: Verification Check
  - State: Notify Success/Failure
- [x] Implement Step Functions definition in Terraform using ASL (Amazon States Language).

## Phase 5: Event-Driven Detection
Goal: Connect the remediation system to real-time triggers.

- [x] **Scenario A: High-CPU/Failure Detection.** Configure CloudWatch Alarms to trigger on performance thresholds.
- [ ] **Scenario B: Security Threat Detection.** Configure GuardDuty or WAF logging to trigger on malicious patterns.
- [x] Implement EventBridge Rules to capture these events and start the Step Function.

## Phase 6: Validation and Fault Injection
Goal: Prove the system works under real-world pressure.

- [x] Perform manual fault injection (e.g., stress testing an EC2 instance).
- [x] Validate end-to-end flow: Detection -> Orchestration -> Remediation -> Notification.
- [x] Document MTTR (Mean Time To Resolution) improvements compared to manual response.

## Phase 7: Final Documentation and Presentation
Goal: Polish the repository for recruiters and technical reviews.

- [x] Finalize Architectural Diagram (using Mermaid).
- [x] Create the Technical Philosophy narrative in the main README.
- [ ] Record a demo video or create an annotated Execution Walkthrough.
- [x] Final review of code standards and standalone repository structure.

---
Status: Completed
Current Focus: Repository Handover and Portfolio Integration
