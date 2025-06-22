# Dynamic Blocks in Terraform

## Overview

This lab showcases the use of **dynamic blocks** in Terraform—an advanced technique used to programmatically generate nested blocks inside resources. Dynamic blocks allow for greater reusability and flexibility, especially when dealing with repeatable configurations such as multiple security group rules. This aligns closely with the Infrastructure-as-Code (IaC) principles of DRY (Don’t Repeat Yourself) and modularity.

---

## Key Implementations

### 1. Creating a Static AWS Security Group

We began by defining an AWS security group with two hardcoded ingress rules:

```hcl
resource "aws_security_group" "main" {
  name   = "core-sg"
  vpc_id = aws_vpc.tf_mastery_vpc.id

  ingress {
    description = "Port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

This configuration works but is repetitive and less maintainable as the number of rules grows.

---

### 2. Refactoring with a Dynamic Block

We then introduced a **local block** to store ingress rules and used a dynamic block to generate each ingress rule:

```hcl
locals {
  ingress_rules = [
    { port = 443, description = "Port 443" },
    { port = 80,  description = "Port 80"  }
  ]
}

resource "aws_security_group" "main" {
  name   = "core-sg"
  vpc_id = aws_vpc.tf_mastery_vpc.id

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

This improves modularity and maintainability by abstracting rule definitions.

---

### 3. Using a Map Variable for Greater Flexibility

To make the code reusable, we defined a map variable for ingress rules and referenced it in the resource:

```hcl
variable "web_ingress" {
  type = map(object({
    description = string
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = {
    "80" = {
      description = "Port 80"
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    "443" = {
      description = "Port 443"
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

resource "aws_security_group" "main" {
  name   = "core-sg"
  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.web_ingress
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```

This approach decouples the security group logic from its implementation, making it more reusable in modules or shared configurations.

---

## Real-World Use Case

Dynamic blocks are ideal when building reusable Terraform modules that need to accept variable-length configurations—like firewall rules, IAM policies, or load balancer listeners.

**Example:**
A DevOps platform team creates a Terraform module for AWS security groups. Application teams can pass a map of ingress rules (e.g., from CI/CD pipelines), and the dynamic block generates security group entries dynamically. This allows the platform team to enforce structure while giving application teams flexibility.

---

## Best Practices

- **Avoid overuse:** Use dynamic blocks only when the number of blocks is variable. Prefer static blocks for clarity when the structure is known.
- **Use locals or variables:** Store repeatable logic in `locals` or `variables` to improve readability.
- **Validate inputs:** Use `variable` type constraints to catch errors early.
- **Document dynamic content:** Make it clear what structure is expected from maps/lists used in dynamic blocks.

---

## Skills Demonstrated

- Wrote reusable Terraform code with `dynamic` blocks
- Parameterised security group rules with local values and variables
- Demonstrated map iteration with `for_each` and `ingress.value`
- Improved readability, reusability, and scalability of infrastructure definitions

---

## Conclusion

This lab demonstrated how dynamic blocks enable you to write more modular, scalable, and reusable Terraform configurations. By using locals or map-based variables, dynamic blocks reduce repetition and promote clean design patterns—especially in shared modules or team-based environments.

While powerful, dynamic blocks should be used judiciously to avoid compromising readability. When applied appropriately, they help bring Terraform code closer to software-quality engineering.

---
