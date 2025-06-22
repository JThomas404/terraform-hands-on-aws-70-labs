# Terraform Cloud Secure Variables

## Overview

This documentation outlines the application of Terraform Cloud (TFC) to securely manage variable definitions in infrastructure-as-code environments. TFC offers encrypted storage and scoped access for variables at both the workspace and organisational levels, allowing centralised handling of credentials, configurations, and metadata without relying on local plaintext files or developer machines.

---

## Secure Variable Management in Terraform Cloud

TFC supports two primary types of variables:

- **Terraform Variables**: Used to provide values for `variable` blocks in Terraform modules.
- **Environment Variables**: Used by Terraform providers and runtime tools (e.g. AWS SDK).

This lab demonstrates secure storage of AWS credentials and configuration parameters in TFC.

### Store AWS Credentials as Environment Variables

To allow Terraform to authenticate with AWS, credentials should be added as environment variables. These must never be embedded directly in `.tf` files or source control.

1. Navigate to the `Variables` tab of the `my-aws-app` workspace.
2. Click `+ Add variable`.
3. Add the following environment variables:

   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key (**mark this as sensitive** to prevent exposure)

> Code Comment: Marking variables as sensitive ensures they are hidden in logs and not retrievable through the UI or CLI.

---

## Validating the Use of TFC Variables

Once variables have been defined in TFC, the configuration should be validated to confirm proper integration.

### Reinitialise Terraform Configuration

```bash
terraform init -reconfigure
```

### Execute a Remote Plan

```bash
terraform plan
```

Sample output:

```bash
No changes. Infrastructure is up-to-date.
```

> Code Comment: A zero-change plan validates that externalised variables have not altered the infrastructure state.

---

## Modify a Variable in Terraform Cloud

To test real-time variable updates:

1. Locate the `vpc_name` variable in the workspace.
2. Click the `...` menu > `Edit`.
3. Modify the value (e.g. `dev-vpc` → `prod-vpc`) and save.
4. Apply the updated configuration:

```bash
terraform apply
```

> Code Comment: Terraform retrieves the latest variable values from TFC at runtime to apply changes.

---

## Initiating a Remote Apply in the Terraform Cloud UI

TFC also allows plans and applies to be initiated directly from the web interface:

1. Navigate to `Actions` > `Start new plan`.
2. Add a plan description (e.g. `VPC Name Update`).
3. Select `Plan (most common)` and proceed through the review and apply steps.

> Code Comment: Web-based apply operations help support change approvals, auditing, and team collaboration.

---

## Variable Sets for Multi-Workspace Credential Management

To reduce duplication and enforce consistent credential usage:

1. Go to `Organisation Settings` > `Variable sets`
2. Click `Create variable set`
3. Name: `AWS Credentials`
4. Scope: `my-aws-app`
5. Add variables:

   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY` (**sensitive**)

> Code Comment: Variable sets promote reusability and security by grouping credentials centrally for multiple workspaces.

These sets can be attached to any future workspace requiring AWS authentication, reducing maintenance and credential sprawl.

---

## Skills Demonstrated

- Managed remote storage of credentials via environment variables
- Executed secure plans and applies via Terraform Cloud
- Updated infrastructure behaviour through UI-based variable changes
- Implemented variable sets for secure multi-workspace configuration
- Applied sensitive flag usage to safeguard secrets during remote execution

---

## Real-World Use Case

In a typical enterprise setup, cloud credentials must be rotated regularly, tightly scoped, and centrally controlled. TFC variable sets:

- Eliminate repetition across workspaces
- Strengthen compliance by masking and managing secrets
- Facilitate safe and fast onboarding of new projects
- Enhance collaboration across infrastructure and security teams

**Example:** A DevOps team manages workspaces across QA, staging, and production environments. Rather than redefining credentials each time, they use environment-specific variable sets (`qa-creds`, `prod-creds`) linked to appropriate workspaces. These sets are rotated quarterly and locked behind TFC team-based permissions.

---

## Versioning Rationale

Pinning the Terraform version in each workspace ensures consistent execution and prevents drift. Example benefits:

- Stable execution environment for CI/CD pipelines
- Easier collaboration across teams using identical tool versions
- Reduced risk of unintentional breaking changes after upgrades

TFC allows explicit version selection per workspace, supporting cautious versioning in production while allowing newer versions for experimental workspaces.

---

## Conclusion

This lab demonstrated best practices for securely managing infrastructure variables using Terraform Cloud. By externalising secrets, versioning configuration, and applying centralised policies through variable sets, teams can improve both the security and scalability of Terraform deployments. These practices are essential for auditability, multi-team collaboration, and operational resilience in real-world infrastructure environments.

---
