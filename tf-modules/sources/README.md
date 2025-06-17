# Terraform Module Sources

## Overview

This project lab explored how Terraform modules can be sourced from different locations, including local folders, the Terraform Registry, GitHub repositories, and even S3 buckets. The aim was to understand how to refactor infrastructure code into reusable modules and source them from appropriate locations for better organisation and scalability. This lab also highlights how modules can be upgraded and extended as requirements grow.

---

## Sourcing a Local Terraform Module

To adopt a more structured convention, I reorganised the module structure by placing the previously created `server` module inside a `modules` directory:

```text
modules/
└── server/
    └── server.tf
```

In the `main.tf` file, I updated the `source` path to reflect the new location:

```hcl
module "server" {
  source          = "./modules/server"
  ami             = data.aws_ami.amazon_linux.id
  subnet_id       = aws_subnet.tf_mastery_public.id
  security_groups = [aws_security_group.tf_mastery_sg.id, aws_security_group.tf_mastery_web.id]
}
```

After modifying the source, I reinitialised the working directory using:

```bash
terraform init
```

---

## Creating a New Local Module Source

To test modular expansion, I created a new enhanced EC2 module called `web_server` with added user data provisioning using a `remote-exec` provisioner.

```text
modules/
├── server/
│   └── server.tf
└── web_server/
    └── server.tf
```

Key additions included support for SSH provisioning using key pairs and user variables. The provisioner cloned a demo repo and ran a setup script to configure a basic web server.

In the root module:

```hcl
module "server_subnet_1" {
  source      = "./modules/web_server"
  ami         = data.aws_ami.amazon_linux.id
  key_name    = aws_key_pair.generated.key_name
  user        = "ec2-user"
  private_key = tls_private_key.generated.private_key_pem
  subnet_id   = aws_subnet.public_subnets["public_subnet_1"].id
  security_groups = [
    aws_security_group.vpc-ping.id,
    aws_security_group.ingress-ssh.id,
    aws_security_group.vpc-web.id
  ]
}
```

This allowed me to parameterise more aspects of the module and reuse it in multiple subnets.

---

## Using the Public Module Registry

To test module consumption from the Terraform Registry, I integrated the `terraform-aws-modules/autoscaling/aws` module:

```hcl
module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "8.3.0"

  name                 = "myasg"
  vpc_zone_identifier  = [
    aws_subnet.private_subnets["private_subnet_1"].id,
    aws_subnet.private_subnets["private_subnet_2"].id,
    aws_subnet.private_subnets["private_subnet_3"].id
  ]
  min_size            = 0
  max_size            = 1
  desired_capacity    = 1
  image_id            = data.aws_ami.amazon_linux.id
  instance_type       = "t3.micro"
  instance_name       = "asg-instance"

  tags = {
    Name = "Web EC2 Server 2"
  }
}
```

This demonstrated how modules can be pulled and version-controlled directly from the Terraform Registry to deploy managed AWS resources.

---

## Sourcing a Module from GitHub

As an alternative, I tested sourcing the same module from GitHub by updating the `source` parameter:

```hcl
module "autoscaling" {
  source = "github.com/terraform-aws-modules/terraform-aws-autoscaling?ref=v8.3.0"
}
```

Note: The `version` parameter was removed because module versioning is handled by the `ref` query in GitHub sources.

This Git-based sourcing is especially useful when pulling from internal or private repositories, or when Registry publishing is not an option.

---

## Real-World Use Case

This modular sourcing strategy mirrors real-world Terraform practices used in team environments and CI/CD pipelines. By sourcing modules:

- Teams can share and maintain reusable infrastructure packages.
- Public and private registries help enforce version control.
- Git-based sources enable fetching modules from versioned repositories.
- Local modularisation supports team collaboration in monorepos.

---

## Conclusion

Through this project lab, I explored the practical applications of Terraform module sources—local, registry-based, and GitHub-hosted. I applied best practices for structure, sourcing, and reinitialisation. This lab reinforced:

- How to refactor infrastructure as code using modules
- Sourcing modules from remote and local systems
- Updating and extending module definitions
- Managing infrastructure components across projects with maintainability and version control in mind

---
