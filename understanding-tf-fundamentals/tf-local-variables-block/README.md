# Terraform Locals Block

## Overview

This lab focuses on understanding and applying **Terraform locals blocks** to simplify and streamline my infrastructure code. Locals allow develops to define named values that can be reused throughout the configuration. Unlike variables, locals are not influenced by user input; they remain constant throughout the Terraform lifecycle. This lab demonstrates how to define and use locals to improve code readability, reduce duplication, and encapsulate logic.

## Locals Syntax

```hcl
locals {
  time        = timestamp()
  application = "api_server"
  server_name = "${var.account}-${local.application}"
}
```

Locals are referenced using `local.<name>`. They are evaluated only once and are immutable.

---

## Define the Name of an EC2 Instance using a Local Variable

In the `main.tf` file, define the following locals block:

```hcl
locals {
  team        = "api_mgmt_dev"
  application = "corp_api"
  server_name = "ec2-${var.environment}-api-${var.variables_sub_az}"
}
```

Then update the EC2 instance resource to use the local variables:

```hcl
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnets["public_subnet_1"].id

  tags = {
    Name  = local.server_name
    Owner = local.team
    App   = local.application
  }
}
```

---

## Run Terraform Plan

Execute the following command:

```bash
terraform plan
```

Expected outcome:

```text
~ tags = {
      ~ Name  = "old-tag" -> "ec2-dev-api-us-east-1a"
      ~ Owner = "old-owner" -> "api_mgmt_dev"
      ~ App   = "old-app" -> "corp_api"
    }
```

This confirms that the EC2 instance tags will be updated based on the defined locals.

## Apply the Changes

Run:

```bash
terraform apply
```

Confirm that the changes reflect in your AWS Console.

### Real-World Use Case

In production environments, locals are valuable for centralizing naming conventions and tag formats. For example, defining a standard `server_name` format ensures consistency across EC2 instances deployed in different environments or regions, enabling easier tracking and automation.

## Conclusion

Through this lab, I learned:

- The purpose and usage of `locals` in Terraform.
- How locals simplify infrastructure code and increase readability.
- How to dynamically construct tag values using a combination of variables and locals.
- That locals are evaluated once and help encapsulate logic without relying on user input.

---
