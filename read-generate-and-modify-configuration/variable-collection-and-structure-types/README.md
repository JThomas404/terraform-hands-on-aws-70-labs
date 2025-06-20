# Terraform Collections and Structural Types

## Overview

This documentation outlines the use of Terraform’s collection and structural types to manage dynamic and scalable infrastructure configurations. Through practical implementation, this project demonstrates how to create reusable, DRY (Don't Repeat Yourself) modules by abstracting and structuring data efficiently. These techniques are essential for enabling multi-environment deployments, reducing duplication, and maintaining consistency across cloud resources.

Terraform supports the following core value types:

- **Primitive Types**: `string`, `number`, `bool`
- **Collection Types**: `list`, `map`, `set`
- **Structural Types**: `object`, `tuple`

This project highlights:

- Usage of `list`, `map`, and `object` types
- Referencing values within collections
- Generating multiple resources using `for_each`
- Structuring nested configuration using map-of-maps

---

## Key Implementations

### Define and Reference a List

Defined a variable containing multiple availability zones, enabling dynamic selection:

```hcl
variable "us_east_1_azs" {
  type = list(string)
  default = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
    "us-east-1d",
    "us-east-1e"
  ]
}
```

Referenced the first element of the list to assign an availability zone:

```hcl
availability_zone = var.us_east_1_azs[0]
```

---

### Replace Hardcoded Values with Maps

Introduced a `map` type variable to manage CIDR blocks for different environments:

```hcl
variable "ip" {
  type = map(string)
  default = {
    prod = "10.0.150.0/24"
    dev  = "10.0.250.0/24"
  }
}
```

Referenced map values dynamically using an `environment` variable:

```hcl
variable "environment" {
  type    = string
  default = "dev"
}

cidr_block = var.ip[var.environment]
```

---

### Iterate with `for_each` to Provision Resources

Used `for_each` with a map to dynamically create multiple subnets:

```hcl
resource "aws_subnet" "list_subnet" {
  for_each          = var.ip
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value
  availability_zone = var.us_east_1_azs[0]
}
```

This eliminated resource duplication by generating one subnet per environment.

---

### Structure Multi-Field Data with Nested Maps

Defined a complex variable using `map(object(...))` to manage multiple attributes per environment:

```hcl
variable "env" {
  type = map(object({ ip = string, az = string }))
  default = {
    prod = {
      ip = "10.0.150.0/24"
      az = "us-east-1a"
    },
    dev = {
      ip = "10.0.250.0/24"
      az = "us-east-1e"
    }
  }
}
```

Provisioned subnets using nested values for AZ and CIDR block:

```hcl
resource "aws_subnet" "list_subnet" {
  for_each          = var.env
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.ip
  availability_zone = each.value.az
}
```

---

## Real-World Use Case

In production environments, engineering teams often need to provision resources across multiple environments (e.g., dev, staging, prod), with environment-specific values for network configurations. Using structured variables such as maps and objects allows for easy management and iteration without duplicating resource blocks. For example:

- **DevOps teams** can use nested maps to configure network CIDRs, availability zones, and tags per environment.
- **CI/CD pipelines** can switch configurations based on environment inputs.
- **Multi-tenant SaaS platforms** can iterate over tenant-specific variables for dynamic subnet creation and isolation.

These patterns align with Terraform best practices and ensure infrastructure is modular, testable, and scalable.

---

## Skills Demonstrated

- Structured and secure infrastructure-as-code using Terraform types
- Dynamic resource creation using `for_each` and map iteration
- Environment-based provisioning and abstraction
- Scalable design using nested maps for multi-attribute configurations

---

## Conclusion

This project validated the use of Terraform’s collection and structural types for building maintainable and dynamic infrastructure configurations. By shifting away from static values and toward reusable patterns, the configuration is adaptable across multiple environments and teams—making it ideal for enterprise-level infrastructure design.

---
