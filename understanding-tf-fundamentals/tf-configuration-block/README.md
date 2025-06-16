# Terraform Configuration Block

## Overview

This lab demonstrated how the **Terraform configuration block** is used to define global settings and metadata that guide the behavior of the Terraform CLI. One of the most common settings specified is the **required Terraform version**, which enables configuration authors to enforce compatibility constraints and reduce drift caused by version inconsistencies.

## Key Implementation

### Defining Required Terraform Version

To ensure the infrastructure code is run with a compatible Terraform version, the following block was declared:

```hcl
terraform {
  required_version = ">= 1.0.0"
}
```

This configuration was placed in a file named `terraform.tf`. Once in place, any attempt to run the configuration with a Terraform version older than `1.0.0` would be blocked, protecting against unsupported syntax or behavior changes.

To verify local compliance with this version requirement, the following command was issued:

```bash
terraform -version
```

The output confirmed compatibility:

```text
Terraform v1.12.2
on darwin_arm64
```

To further test version constraint enforcement, the requirement was deliberately tightened to an exact version:

```hcl
terraform {
  required_version = "= 1.0.0"
}
```

Running `terraform init` then produced the expected error:

```text
Error: Unsupported Terraform Core version

This configuration does not support Terraform version 1.12.2. To proceed, either choose another supported Terraform version or update this version constraint.
```

This confirmed that the constraint mechanism works as intended.

## Real-World Impact

Defining a required version is essential for infrastructure teams managing collaborative or production environments. It helps:

- Prevent team members from accidentally using incompatible Terraform versions
- Ensure deterministic behavior across machines and CI/CD pipelines
- Provide early feedback if a developer or system is not aligned with the expected tooling

## Conclusion

This configuration-focused lab demonstrates a core Terraform best practice: **explicitly declaring required Terraform versions to enforce consistency across environments**. While seemingly simple, this ensures safer collaboration, simplifies onboarding, and safeguards deployments against avoidable version-related issues.

---
