# Terraform Remote State – Enhanced Backend

## Overview

This documentation outlines the implementation and strategic value of enhanced backends in Terraform, with a focus on the `remote` backend integrated with Terraform Cloud. Enhanced backends enable both remote state storage and centralised execution of infrastructure operations. This lab captures how centralised state and execution workflows can improve governance, auditability, and team collaboration in real-world cloud environments.

---

## Lab Objectives

- Configure the `remote` backend using Terraform Cloud
- Validate remote execution and centralised state management
- Securely inject AWS credentials for cloud provider access
- Utilise Terraform Cloud features for governance and visibility

---

## Enhanced Backend in Terraform

Terraform supports two enhanced backends:

- **`local`** backend: Stores state locally on the developer's machine; default in standalone workflows.
- **`remote`** backend: Connects to Terraform Cloud to store state remotely and execute operations (`plan`, `apply`) within a secure, managed environment.

By using the `remote` backend, state management becomes centralised, enhancing visibility, access control, collaboration, and compliance for infrastructure teams.

---

## Backend Configuration

To migrate to the `remote` backend, the configuration in `terraform.tf` is updated as follows:

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

> ⚠️ A single backend block is allowed per configuration. Replace any existing backend block accordingly.

Remove existing local state files before reinitialising:

```bash
rm terraform.tfstate terraform.tfstate.backup
```

Re-initialise to apply the new backend configuration:

```bash
terraform init -reconfigure
```

---

## Remote Execution via Terraform Cloud

After reconfiguration, running `terraform apply` triggers execution in Terraform Cloud. The CLI streams logs to the terminal while providing a browser link for detailed run visibility.

Terraform Cloud now handles:

- Execution of infrastructure changes
- Secure, versioned state storage
- Variable injection for environment context

This decouples infrastructure changes from local machines, aligning with cloud-native DevOps models.

---

## Secure Credential Injection

To authenticate remote execution in Terraform Cloud, AWS credentials must be supplied as environment variables in the associated workspace:

- Navigate to the workspace's **Variables** tab
- Add environment variables:

  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`

- Mark both as **Sensitive** to ensure secure handling

This approach enforces best practices by avoiding hardcoded credentials and supporting role-based access.

---

## Terraform Cloud Features Utilised

With the `remote` backend in place, the following Terraform Cloud features are leveraged:

- **Versioned Remote State**: Enables tracking and rollback of infrastructure state
- **Log Streaming & Run History**: Visibility into execution for every plan and apply
- **Workspace Locking**: Prevents concurrent operations that could cause state corruption
- **Variable Management**: Central control of sensitive and non-sensitive values
- **UI-Based State Inspection**: Access past state versions and logs from the Terraform Cloud interface

Navigate to the **States** tab within the workspace to view versioned state files.

---

## Infrastructure Cleanup

To remove all infrastructure managed via the remote backend:

```bash
terraform destroy
```

This action is logged and executed within Terraform Cloud, maintaining traceability.

---

## Real-World Use Case

This lab simulates a production infrastructure workflow where teams require secure, auditable, and centrally managed state:

- **Cross-Team Collaboration**: Shared modules and remote state avoid configuration drift
- **Security & Compliance**: Credentials are handled securely and access is role-based
- **CI/CD Integration**: Pipelines can programmatically trigger Terraform operations
- **Multi-Environment Governance**: Workspaces isolate environments such as dev, staging, and production

This model reflects how modern organisations implement Infrastructure as Code at scale.

---

## Capabilities Applied

- Migration to Terraform Cloud via remote backend
- Secure AWS credential injection for remote plans/applies
- Execution validation and log inspection via CLI and UI
- UI-driven state and run history analysis
- Application of governance through workspace isolation and variable management

---

## Compatibility & Best Practices

### Backend Compatibility Notes

This configuration assumes use of Terraform v1.0+.

Deprecated backend syntax, such as `ignore_changes = ["propagating_vgws"]`, is not supported post-0.12 and requires updated syntax for lifecycle blocks.

### Version Pinning and Provider Constraints

Use `required_providers` in the `terraform` block alongside module version constraints to fully control provider compatibility:

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

This ensures consistent behaviour across deployments and minimises drift between environments.

## Conclusion

This lab demonstrates how Terraform Cloud enhances operational consistency by centralising both execution and state storage. The adoption of the `remote` backend supports scalable collaboration, secure credential handling, and policy-based governance—core pillars of modern infrastructure automation in cloud environments.

---
