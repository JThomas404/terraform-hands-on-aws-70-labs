# Using Built-in Functions in Terraform

## Overview

This lab demonstrates how to use Terraform's built-in functions to manipulate and transform input values within your configurations. These functions are crucial when building reusable, scalable, and dynamic infrastructure as code. You will explore numeric, string, and collection functions, as well as networking utilities such as `cidrsubnet`. These functions are often used in tagging strategies, dynamic resource naming, subnetting, and conditional logic.

---

## Key Implementations

### Numerical Functions

Terraform includes functions for numeric operations like `max()` and `min()`:

```hcl
variable "num_1" { default = 88 }
variable "num_2" { default = 73 }
variable "num_3" { default = 52 }

locals {
  maximum = max(var.num_1, var.num_2, var.num_3)
  minimum = min(var.num_1, var.num_2, var.num_3, 44, 20)
}

output "max_value" {
  value = local.maximum
}

output "min_value" {
  value = local.minimum
}
```

These outputs reveal the computed maximum and minimum values, illustrating simple arithmetic evaluations within Terraform.

---

### String Functions

Terraform provides string functions such as `upper()` and `lower()` to standardise inputs. Example:

```hcl
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = upper(var.vpc_name)
    Environment = upper(var.environment)
    Terraform   = upper("true")
  }

  enable_dns_hostnames = true
}
```

This ensures consistent tag formatting for governance and compliance.

Using `lower()` within locals:

```hcl
locals {
  common_tags = {
    Name      = lower(local.server_name)
    Owner     = lower(local.team)
    App       = lower(local.application)
    Service   = lower(local.service_name)
    AppTeam   = lower(local.app_team)
    CreatedBy = lower(local.createdby)
  }
}
```

Additionally, dynamic string creation using `join()` helps standardise naming conventions:

```hcl
locals {
  common_tags = {
    Name = join("-", [local.application, data.aws_region.current.name, local.createdby])
  }
}
```

---

### Networking Function – `cidrsubnet`

This specialised function allows automatic subnet creation based on a base CIDR block:

```hcl
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}
```

Given a `/16` base block and an 8-bit prefix increase, this generates `/24` subnets dynamically.

---

## Real-World Use Case

Terraform built-in functions are essential in environments that require:

- **Tag standardisation** for billing, compliance, and auditing.
- **Dynamic resource naming** based on input variables, current region, or other data sources.
- **Automated subnetting** without hardcoding IP ranges.
- **Reusable modules** that adapt to changing environments using `join`, `lookup`, `length`, and `cidrsubnet`.

**Example:** A multi-environment Terraform setup can generate consistent tag names (e.g., `app-prod-us-east-1`) by combining variables and data sources using `join()` and `lower()` functions. This ensures readability, environment-specific clarity, and automation.

---

## Skills Demonstrated

- Used arithmetic functions to evaluate numerical expressions.
- Manipulated strings dynamically using `upper()`, `lower()`, and `join()`.
- Applied `cidrsubnet()` to dynamically generate subnets from a base CIDR.
- Designed reusable tagging strategies using functions.

---

## Conclusion

This lab showcased the power and flexibility of Terraform built-in functions. Whether you are standardising inputs, computing values, or creating dynamic infrastructure naming, these functions are vital for writing clean, scalable, and efficient code. Mastering them is a foundational step toward becoming a proficient Infrastructure as Code engineer.

---
