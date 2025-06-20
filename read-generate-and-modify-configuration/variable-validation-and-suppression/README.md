# Terraform Variable Validation and Sensitive Data Suppression

## Overview

This project documents the use of **variable validation** and **sensitive data suppression** in Terraform configurations. Through structured validation rules and output handling, the project demonstrates how to enforce data integrity and protect sensitive values during deployment workflows.

## Variable Validation Implementation

To enforce input quality and prevent misconfigurations, custom validation blocks were implemented within `variables.tf`:

```hcl
variable "cloud" {
  type = string

  validation {
    condition     = contains(["aws", "azure", "gcp", "vmware"], lower(var.cloud))
    error_message = "You must use an approved cloud."
  }

  validation {
    condition     = lower(var.cloud) == var.cloud
    error_message = "The cloud name must not have capital letters."
  }
}
```

Terraform commands confirmed enforcement:

```bash
terraform plan -var cloud=aws       # Success
terraform plan -var cloud=alibabba  # Error
```

### Additional Validations

Extended validations were applied to:

```hcl
variable "no_caps" {
  type = string
  validation {
    condition     = lower(var.no_caps) == var.no_caps
    error_message = "Value must be in all lower case."
  }
}

variable "character_limit" {
  type = string
  validation {
    condition     = length(var.character_limit) == 3
    error_message = "This variable must contain only 3 characters."
  }
}

variable "ip_address" {
  type = string
  validation {
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.ip_address))
    error_message = "Must be an IP address of the form X.X.X.X."
  }
}
```

These tests validated that malformed inputs are intercepted early in the planning phase.

## Sensitive Variable Suppression

Terraform allows flagging variables as `sensitive` to prevent accidental exposure in CLI output. This was tested with:

```hcl
variable "phone_number" {
  type      = string
  sensitive = true
  default   = "867-5309"
}
```

### Output Definitions

Structured outputs were defined using both sensitive and non-sensitive contexts:

```hcl
locals {
  contact_info = {
    cloud       = var.cloud
    department  = var.no_caps
    cost_code   = var.character_limit
    phone_number = var.phone_number
  }
  my_number = nonsensitive(var.phone_number)
}

output "phone_number" {
  value     = local.contact_info.phone_number
  sensitive = true
}

output "my_number" {
  value = local.my_number
}
```

Terraform output:

```bash
Outputs:

cloud        = "aws"
cost_code    = "rpt"
department   = "training"
my_number    = "867-5309"
phone_number = <sensitive>
```

## Terraform State Exposure Risk

Despite CLI obfuscation, sensitive values remain visible in the `terraform.tfstate` file:

```json
"phone_number": {
  "value": "867-5309",
  "type": "string",
  "sensitive": true
}
```

> Access to Terraform state must be tightly controlled.

## Terraform Cloud (TFC) Integration

Remote state management was tested using Terraform Cloud. Configuration included:

**remote.tf**

```hcl
terraform {
  backend "remote" {
    organization = "<org-name>"
    workspaces {
      name = "variable_validation"
    }
  }
}
```

**terraform.auto.tfvars**

```hcl
cloud           = "aws"
no_caps         = "training"
ip_address      = "1.1.1.1"
character_limit = "rpt"
```

Terraform Cloud correctly handled validation and suppression mechanisms during remote plan and apply operations.

## Real-World Use Cases

- **Validation** enforces proper input format in production environments (e.g., cloud provider, region, service limits).
- **Sensitive suppression** protects secrets like credentials, API keys, or internal contact information.
- **Terraform Cloud** enhances security by storing state remotely with controlled access.

## Conclusion

This implementation demonstrates effective use of validation rules to prevent invalid configurations and securely manage sensitive data. Proper use of validation and suppression enhances the maintainability, reliability, and security of Terraform-managed infrastructure. These techniques are critical in both local and team-based deployments, ensuring clean, consistent infrastructure-as-code practices.

---
