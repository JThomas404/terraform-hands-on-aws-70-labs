# Terraform Modules

## Overview

In this project lab, I worked through creating and using Terraform modules to improve code reusability, maintainability, and scalability in infrastructure as code (IaC) projects. Terraform modules allow infrastructure components to be encapsulated in reusable, parameterised blocks that can be versioned and deployed across multiple environments.

Modules help enforce standards and consistency across environments by packaging configurations into self-contained units. In real-world DevOps workflows, modules are commonly used for provisioning standardised resources like EC2 instances, VPCs, S3 buckets, or IAM roles across development, staging, and production.

---

## Creating a Local Terraform Module

To begin, I created a new module directory and wrote the following configuration for an EC2 instance:

1. **Module Directory:**

   ```bash
   mkdir -p /workspace/terraform/server
   ```

2. **Module Configuration (\*\***`server/server.tf`\***\*):**

```hcl
variable "ami" {}
variable "size" {
  default = "t3.micro"
}
variable "subnet_id" {}
variable "security_groups" {
  type = list(any)
}

resource "aws_instance" "web" {
  ami                    = var.ami
  instance_type          = var.size
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_groups

  tags = {
    Name        = "Server from Module"
    Environment = "Training"
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}

output "public_dns" {
  value = aws_instance.web.public_dns
}
```

---

## Calling the Module from Root Configuration

In the root configuration file (`main.tf`), I referenced the newly created module using a module block. This allowed me to reuse the instance configuration by passing input variables:

```hcl
module "server" {
  source          = "./server"
  ami             = data.aws_ami.amazon_linux.id
  subnet_id       = aws_subnet.tf_mastery_public.id
  security_groups = [aws_security_group.tf_mastery_sg.id, aws_security_group.tf_mastery_web.id]
}
```

This abstraction simplifies the main configuration while keeping the logic clean and modular.

---

## Initialising and Applying the Module

To apply the changes and test the module integration, I ran:

```bash
terraform init
terraform apply
```

To verify provider and module information:

```bash
terraform providers
```

Output:

```text
.
├── provider[registry.terraform.io/hashicorp/random] 3.7.2
├── provider[registry.terraform.io/hashicorp/local] 2.4.1
├── provider[registry.terraform.io/hashicorp/tls] 4.0.5
├── provider[registry.terraform.io/hashicorp/aws] 5.100.0
├── provider[registry.terraform.io/hashicorp/http] 3.5.0
└── module.server
    └── provider[registry.terraform.io/hashicorp/aws]
```

---

## Inspecting Module Resources in Terraform State

To confirm the deployed infrastructure, I listed and inspected the Terraform state:

```bash
terraform state list
```

Sample output:

```text
aws_instance.web_server
module.server.aws_instance.web
```

To see full details of the EC2 instance provisioned by the module:

```bash
terraform state show module.server.aws_instance.web
```

---

## Real-World Use Case

This module design approach is applicable in:

- Creating reusable and standardised infrastructure components (e.g., EC2, VPCs, IAM roles)
- Enforcing naming and tagging conventions across teams
- Integrating Terraform modules into CI/CD pipelines
- Version-controlling reusable templates via private or public module registries
- Promoting best practices and collaboration in infrastructure teams

---

## Conclusion

This project lab reinforced how Terraform modules support modular infrastructure design, simplify configuration files, and promote code reuse. Through this lab, I practised:

- Structuring and referencing modules in a real-world IaC layout
- Passing variables and reading outputs between modules
- Navigating and inspecting Terraform state for module-based deployments
- Abstracting infrastructure definitions to maintain scalable and maintainable codebases

---
