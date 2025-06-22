# Getting Started with HCP Terraform

## Overview

This lab documents a practical implementation of Terraform integrated with [HashiCorp Cloud Platform (HCP) Terraform](https://app.terraform.io/), designed to simulate a real-world onboarding flow into infrastructure as code (IaC) with centralized state management. The configuration provisions mock infrastructure using the [`fakewebservices`](https://registry.terraform.io/providers/hashicorp/fakewebservices/latest) provider, ideal for demonstration environments that require zero-cost execution.

---

## Lab Objectives

- Demonstrate workspace and API token initialization with HCP Terraform
- Automate Terraform configuration and remote plan/apply processes
- Showcase `terraform login` authentication and secure remote state use
- Validate provider logic using a safe mock deployment pipeline

---

## Repository Structure

- `main.tf`: Terraform configuration using `fakewebservices` to simulate cloud provisioning
- `scripts/setup.sh`: Automation script to initialize workspace, upload config, and execute remote operations

---

## Lab Prerequisites

The following tools must be installed on the local system to execute the lab:

- **Terraform CLI** (version 0.14 or later)
- **Bash shell** with execution permissions
- Command-line tools: `curl`, `sed`, and `jq`

---

## Lab Execution Phases

### Phase 1: CLI Authentication

Establish secure CLI access to HCP Terraform by logging in and generating a local API token:

```bash
terraform login
```

If the user does not have an existing HCP account, the CLI will guide them through account creation.

### Phase 2: Repository Cloning

Clone the example configuration to your local machine:

```bash
git clone https://github.com/hashicorp/tfc-getting-started.git
cd tfc-getting-started
```

### Phase 3: Environment Initialization

Run the setup script to automate backend and configuration provisioning:

```bash
./scripts/setup.sh
```

This script performs the following:

- Registers a new HCP workspace
- Pushes Terraform config to the workspace
- Links CLI state to the HCP workspace
- Triggers remote `terraform plan` and `apply`

---

## Real-World Use Case

In enterprise scenarios, organizations leverage HCP Terraform to manage cloud deployments across teams. This lab emulates those workflows using mock infrastructure:

- **DevOps Automation**: Onboarding new projects via bootstrap scripts to ensure consistent workspace provisioning
- **Secure Remote State**: Using HCP Terraform reduces risk of state file loss or corruption in team environments
- **CI/CD Compatibility**: Mirrors how CI pipelines trigger infrastructure changes while maintaining audit trails
- **Sandbox Testing**: Fake provider allows experimentation without affecting real cloud resources or incurring charges

---

## Skills Demonstrated

- Secure CLI authentication with HCP Terraform
- Workspace lifecycle management
- Scripted infrastructure setup using Bash automation
- Remote plan and apply execution
- Use of mock providers for isolated testing
- Foundational IaC and Terraform governance concepts

---

## Conclusion

This lab delivers a hands-on demonstration of best practices for initializing and managing Terraform infrastructure through HCP. Though simplified through mock providers, the lab structure reflects patterns used in production environments—including CI/CD pipelines, centralized state management, and scalable team onboarding.

Hiring managers can assess familiarity with Terraform CLI, remote backends, IaC automation scripting, and secure provisioning workflows from this lab. It serves as a foundational step toward mastering real-world cloud IaC deployments.

---
