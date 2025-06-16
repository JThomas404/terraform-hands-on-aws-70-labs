# Terraform SSH Key Generation with TLS Provider

## Overview

This documentation outlines how to securely generate an SSH keypair using Terraform's TLS provider. The TLS provider is designed to work with Transport Layer Security keys and certificates, and is often used for cryptographic operations within infrastructure code. In this lab, I integrated the TLS provider alongside AWS, HTTP, Random, and Local providers to provision a keypair that is stored locally and used in the deployment of an EC2 instance.

This task demonstrates infrastructure security automation by using Terraform to programmatically generate and store secure credentials, eliminating the need for manual key management in development workflows.

---

## Provider Configuration

To begin, I defined all required providers—including the TLS provider—in the `terraform.tf` file:

```hcl
terraform {
  required_version = "~> 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}
```

Run the following command to install and verify provider versions:

```bash
terraform init
terraform version
```

Sample output:

```text
Terraform v1.12.2
+ provider registry.terraform.io/hashicorp/aws v5.100.0
+ provider registry.terraform.io/hashicorp/http v3.5.0
+ provider registry.terraform.io/hashicorp/local v2.4.1
+ provider registry.terraform.io/hashicorp/random v3.7.2
+ provider registry.terraform.io/hashicorp/tls v4.0.5
```

---

## SSH Keypair Generation and EC2 Integration

I updated the `main.tf` file to:

1. Generate a new private key using `tls_private_key`.
2. Use `aws_key_pair` to register the public key with AWS.
3. Save the private key to a PEM file using the `local_file` resource.
4. Deploy an EC2 instance using the newly generated key.

```hcl
resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

resource "aws_key_pair" "generated_key" {
  key_name   = "tf_mastery_generated_key"
  public_key = tls_private_key.generated.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.generated.private_key_pem
  filename        = "MyAWSKey.pem"
  file_permission = "0600"
}

resource "aws_instance" "tf_mastery_ec2" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  subnet_id                   = aws_subnet.tf_mastery_public.id
  vpc_security_group_ids      = [aws_security_group.tf_mastery_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated_key.key_name

  tags = {
    Name  = local.server_name
    Owner = local.team
    App   = local.application
  }
}
```

Run the deployment:

```bash
terraform apply
```

Confirm the PEM file has been created:

```bash
ls -l MyAWSKey.pem
cat MyAWSKey.pem
```

> **Note:** This is a self-signed certificate suitable only for development environments. Avoid using self-generated TLS credentials in production without a secure signing mechanism.

---

## Real-World Use Cases

- Automatically generating SSH keys for short-lived EC2 instances.
- Securing provisioning workflows without manual key distribution.
- Version-controlling infrastructure while keeping secrets external or encrypted.
- Ensuring consistent file permissions and storage format (PEM) for CI/CD pipelines.

---

## Conclusion

This lab demonstrates the power of Terraform's TLS provider for automating key generation and secure provisioning. By using `tls_private_key` with `local_file` and `aws_key_pair`, I was able to establish a reusable pattern for credential management in cloud infrastructure. One key takeaway was learning to apply the correct `file_permission` to private key files and understanding the implications of `public_key_openssh` vs. `private_key_pem`. This approach reduces human error and increases security in infrastructure deployment pipelines.

This hands-on experience reflects my ability to integrate security-first principles into modern DevOps workflows using Terraform.

---
