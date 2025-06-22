# Terraform Remote State – Enhanced Backend

## Overview

This documentation outlines the implementation and strategic function of enhanced backends in Terraform, with emphasis on the `remote` backend integrated with Terraform Cloud. Enhanced backends are capable of storing state and executing Terraform operations centrally. This lab captures how centrally managed state and remote operations improve visibility, governance, and team collaboration in real-world cloud workflows.

---

## Lab Objectives

- Configure the `remote` backend using Terraform Cloud
- Validate remote execution and centralised state management
- Inject AWS credentials securely for remote cloud provisioning
- Use Terraform Cloud features to support collaborative operations

---

## Enhanced Backend Functionality

Terraform supports two enhanced backends:

- **`local`**: The default backend that stores state on the local filesystem
- **`remote`**: Connects to Terraform Cloud to store state remotely and run operations (such as `plan` and `apply`) within a managed cloud execution environment

The `remote` backend provides:

- Centralised state storage
- Controlled and secure execution environment
- Enhanced team collaboration features

---

## Backend Configuration

The `terraform.tf` file is updated to specify the use of the `remote` backend:

```hcl
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Enterprise-Cloud"

    workspaces {
      name = "my-aws-app"
    }
  }
}
```

> ⚠️ Only one backend block can be defined per configuration. Remove any existing `backend` configuration beforehand.

Delete existing local state files:

```bash
rm terraform.tfstate terraform.tfstate.backup
```

Re-initialise the working directory to reflect the new backend:

```bash
terraform init -reconfigure
```

---

## Remote Execution in Terraform Cloud

Once initialised, any `terraform apply` operations are executed remotely in Terraform Cloud. Terraform streams logs to the CLI and provides a web URL for detailed tracking.

This approach ensures:

- Operations are performed in a secure, remote environment
- Logs and execution history are centrally accessible
- Teams share visibility into infrastructure changes

---

## Secure Credential Handling

Terraform Cloud requires AWS credentials to interact with AWS resources. These must be added as environment variables:

- In the workspace UI, navigate to the **Variables** section
- Add environment variables:

  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`

- Mark both variables as **Sensitive** to protect visibility

This practice avoids local credential leaks and supports organisational security policies.

---

## Terraform Cloud Features

Enabling the `remote` backend activates the following Terraform Cloud features:

- **State Versioning**: Track and revert infrastructure state
- **Run History & Logs**: Auditable execution trail
- **Workspace Locking**: Prevent concurrent changes
- **Centralised Variable Management**: Control sensitive and shared values
- **State Visualisation**: Browse state history via web interface

These capabilities reflect production-grade operational needs for infrastructure management.

---

## Infrastructure Teardown

All resources created via the remote backend can be destroyed from the CLI. Terraform Cloud logs and executes this operation:

```bash
terraform destroy
```

Confirmation prompts and real-time logs are streamed during execution, and records are preserved in the Terraform Cloud UI.

---

## Applied Capabilities

This lab applies the following capabilities:

- Migration to Terraform Cloud using the `remote` backend
- Secure credential provisioning through environment variables
- Execution streaming and visibility through CLI and UI
- State history, locking, and audit controls
- Policy-aligned infrastructure governance using workspaces

---

## Compatibility and Best Practices

### Terraform Version Requirements

This configuration requires Terraform version 1.0.0 or higher. Ensure compliance to avoid deprecated syntax or compatibility issues.

### Provider Pinning

Include version constraints and required providers for predictable behaviour:

```hcl
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.21.0"
    }
  }
}
```

Defining provider versions helps ensure consistent execution across environments and avoids regressions due to unanticipated upgrades.

---

## Conclusion

This lab illustrates the integration of Terraform Cloud’s remote backend as a means to standardise infrastructure workflows. By storing state remotely and executing operations in a managed environment, teams benefit from enhanced collaboration, security, and operational consistency—key elements for scaling infrastructure as code in modern organisations.

---
