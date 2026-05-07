# Contributing to AWS Automated Remediation Pipeline

Thank you for your interest in contributing to this project. As a portfolio piece focused on Cloud Operations and Reliability, contributions that enhance security, observability, and automation are highly valued.

## How to Contribute

1.  **Fork the repository.**
2.  **Create a new branch** for your feature or bug fix: `git checkout -b feature/your-feature-name`.
3.  **Implement your changes.** Ensure all Terraform code follows the established modular patterns and passes `terraform validate`.
4.  **Add tests.** If adding a new remediation skill, include a simulation script or unit test to verify the logic.
5.  **Run security scans.** Ensure your changes pass `checkov` and `trivy` scans.
6.  **Submit a Pull Request.** Provide a clear description of the problem your change solves and the technical approach taken.

## Coding Standards

- **Terraform:** Follow the [terraform-skill](https://github.com/antonbabenko/terraform-skill) standards. Use descriptive variable names and provide clear descriptions for all resources.
- **Python:** Adhere to PEP 8 standards. Use `boto3` for all AWS interactions and ensure proper error handling and logging.
- **Documentation:** Update the `README.md` and `ROADMAP.md` if your changes introduce new capabilities or alter the architecture.

## Security

If you discover a security vulnerability, please open a GitHub Issue or contact the maintainer directly at hcollender788@gmail.com.
