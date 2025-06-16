# Terraform Variables Block

## Overview

A simple framework that this lab has taught me is "Don't repeat yourself." Variables are a fantastic way to ensure that cloud engineers or developers do not repeat themselves. They simplify and increase the usability of Terraform configurations. Input variables allow aspects of a module or configuration to be customized without altering the module's source code. This allows modules to be shared between different configurations.

Input variables (commonly referred to as just "variables") are often declared in a separate file called `variables.tf`, although this is not required. It is best practice to consolidate variable declarations in this file for organization and ease of management. Each variable used in a Terraform configuration must be declared before it can be used. Variables are declared in a `variable` block—one block per variable. This block includes the variable name and can optionally include additional information such as the type, description, default value, and validation rules.

## Template Syntax

```hcl
variable "<VARIABLE_NAME>" {
  type        = <VARIABLE_TYPE>
  description = <DESCRIPTION>
  default     = <EXPRESSION>
  sensitive   = <BOOLEAN>
  validation {
    condition     = <EXPRESSION>
    error_message = <MESSAGE>
  }
}
```

## Example Variable Block

```hcl
variable "aws_region" {
  type        = string
  description = "Region used to deploy workloads"
  default     = "us-east-1"
  validation {
    condition     = can(regex("^us-", var.aws_region))
    error_message = "The aws_region value must be a valid region in the USA, starting with 'us-'."
  }
}
```

Terraform uses a specific order of precedence to determine variable values, which includes default values, CLI input, environment variables, and `.tfvars` files.

## Add a VPC Resource Block with Static Values

First, we add a subnet resource directly into `main.tf` with hardcoded values:

```hcl
resource "aws_subnet" "variables-subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.250.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name      = "sub-variables-us-east-1a"
    Terraform = "true"
  }
}
```

### Run Terraform Plan

```bash
terraform plan
```

Expected output:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

Apply the change with:

```bash
terraform apply
```

---

## Declare Variable Blocks

Now we move the static values to variables by creating a `variables.tf` file:

```hcl
variable "variables_sub_cidr" {
  description = "CIDR Block for the Variables Subnet"
  type        = string
}

variable "variables_sub_az" {
  description = "Availability Zone used Variables Subnet"
  type        = string
}

variable "variables_sub_auto_ip" {
  description = "Set Automatic IP Assignment for Variables Subnet"
  type        = bool
}
```

---

## Replace Static Values with Variables

Update the original subnet block in `main.tf`:

```hcl
resource "aws_subnet" "variables-subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.variables_sub_cidr
  availability_zone       = var.variables_sub_az
  map_public_ip_on_launch = var.variables_sub_auto_ip

  tags = {
    Name      = "sub-variables-${var.variables_sub_az}"
    Terraform = "true"
  }
}
```

Run:

```bash
terraform plan
```

When prompted:

- `var.variables_sub_auto_ip`: `true`
- `var.variables_sub_az`: `us-east-1a`
- `var.variables_sub_cidr`: `10.0.250.0/24`

---

## Add Default Values

Now add default values to make input optional:

```hcl
variable "variables_sub_cidr" {
  description = "CIDR Block for the Variables Subnet"
  type        = string
  default     = "10.0.202.0/24"
}

variable "variables_sub_az" {
  description = "Availability Zone used for Variables Subnet"
  type        = string
  default     = "us-east-1a"
}

variable "variables_sub_auto_ip" {
  description = "Set Automatic IP Assignment for Variables Subnet"
  type        = bool
  default     = true
}
```

Run:

```bash
terraform plan
```

Expected result:

```text
Plan: 1 to add, 0 to change, 1 to destroy.
```

Apply changes:

```bash
terraform apply
```

---

## Real-World Use Case

In real-world infrastructure deployments, input variables are essential for creating reusable environments. For instance, the same Terraform configuration can be used to deploy to development, staging, and production environments simply by passing different variable values via `.tfvars` files or environment variables. This ensures consistency across environments while maintaining the flexibility to adapt to specific needs, such as different subnet CIDRs, instance types, or region selections.

## Conclusion

This lab taught me how to:

- Understand and use input variables in Terraform.
- Replace hardcoded values with variables for better reusability.
- Organize variables in a `variables.tf` file.
- Use default values to streamline provisioning.
- Prompt variable values dynamically or via `*.tfvars` or environment variables.

Variables are foundational to scaling and managing infrastructure as code efficiently. They make Terraform configurations more flexible, reduce duplication, and improve team collaboration.

---
