# Terraform Workspaces – OSS

## Overview

In this lab, I explored how Terraform Workspaces enable reuse of infrastructure code across multiple environments—such as development, staging, and production—without duplicating configuration files. This aligns with DRY (Don't Repeat Yourself) principles and enhances Infrastructure as Code (IaC) efficiency.

Terraform's stateful architecture maintains a mapping of resources and their configuration. Workspaces isolate this state, allowing you to deploy identical code to different environments while preserving each environment’s state independently.

---

## Core Concept: What Are Workspaces?

Each Terraform workspace is associated with its own state file. The default workspace is always present and cannot be deleted. Additional workspaces (e.g., `development`, `staging`) can be created to manage separate environments without modifying the core configuration files.

```bash
terraform workspace show       # Show current workspace
terraform workspace list       # List all available workspaces
terraform workspace new dev    # Create a new workspace
terraform workspace select dev # Switch to a workspace
terraform workspace delete dev # Delete a workspace (not "default")
```

---

## Use Case: Deploying to a New Environment (Development)

To demonstrate workspace isolation:

1. **Created** a new workspace:

   ```bash
   terraform workspace new development
   ```

2. **Modified** the AWS provider region in `main.tf`:

   ```hcl
   provider "aws" {
     region = "us-west-2"
   }
   ```

3. **Planned and applied** the configuration:

   ```bash
   terraform plan
   terraform apply
   ```

This deployed all declared infrastructure to `us-west-2`, isolated from the `default` workspace resources in `us-east-1`.

---

## Switching Between Environments

Using the `select` command allows seamless transitions between environments without modifying any `.tf` files:

```bash
terraform workspace select default     # Switch to production (us-east-1)
terraform workspace select development # Switch to dev (us-west-2)
```

Each environment's resources are managed independently, while sharing the same configuration code base.

---

## Dynamic Workspace-based Tagging

To improve environment traceability and enforce tagging standards, I interpolated the workspace name dynamically into resource tags:

```hcl
provider "aws" {
  region = "us-west-2"
  default_tags {
    tags = {
      Environment = terraform.workspace
    }
  }
}
```

Terraform automatically applies the correct environment tag based on the current workspace:

```diff
~ tags = {
-   "Environment" = "demo_environment"
+   "Environment" = "development"
}
```

---

## Real-World Value and Use Cases

- Simplifies multi-environment deployments from a single codebase
- Reduces manual overhead and code duplication
- Enables consistent tagging and environment-aware automation
- Facilitates safe parallel development and staging workflows
- Isolates infrastructure state per environment to prevent accidental overrides

---

## Conclusion

This hands-on project reinforced how Terraform Workspaces can streamline DevOps workflows, environment separation, and IaC scalability. It demonstrated practical proficiency in:

- Managing environment-specific deployments without duplicating code
- Leveraging dynamic interpolation (`terraform.workspace`) for tagging and identification
- Understanding and managing isolated infrastructure state across AWS regions

---
