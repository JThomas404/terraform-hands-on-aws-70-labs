# Terraform Provisioners

## Overview

This documentation outlines my experience using Terraform provisioners to automate infrastructure deployment, particularly provisioning a web application on an AWS EC2 instance. Provisioners allow Terraform to execute commands or scripts after creating resources, either locally or on the remote machine. In this lab, I combined `local-exec` and `remote-exec` provisioners with a secure SSH connection, reinforcing modern DevOps principles like Infrastructure as Code (IaC), automation, and secure credential handling.

---

## SSH Keypair Generation

I securely generated an SSH key pair using the TLS provider. The private key was stored locally in PEM format with appropriate file permissions (`0600`) to restrict access to the file owner. This aligns with best practices for protecting sensitive credentials from unauthorised access and potential exploitation. By using `tls_private_key` and writing the output to a `.pem` file with restricted permissions, I ensured confidentiality of the private key material.

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
```

Apply the configuration to generate and store the key:

```bash
terraform apply
```

---

## Security Group Configuration

Two security groups were created:

- One allowing SSH access to enable remote provisioning
- Another allowing HTTP/HTTPS access for web traffic

**SSH Access:**

```hcl
resource "aws_security_group" "tf_mastery_sg" {
  name        = "terraform-mastery-security-group"
  description = "Allow SSH"
  vpc_id      = aws_vpc.tf_mastery_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = var.tags
}
```

**Web Access:**

```hcl
resource "aws_security_group" "tf_mastery_web" {
  name        = "terraform-mastery-web-security-group"
  description = "Allow Web Traffic"
  vpc_id      = aws_vpc.tf_mastery_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Port 80"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Port 443"
  }

  tags = var.tags
}
```

---

## EC2 Instance Provisioning with Secure Access

The EC2 instance uses the generated SSH key and the security groups above. I configured a `connection` block to enable Terraform to SSH into the instance for provisioning tasks.

The `local-exec` provisioner sets strict file permissions for the SSH private key. The `remote-exec` provisioner installs a web application via remote shell commands.

> 🔒 **Note:** While `remote-exec` is helpful for initial automation and demos, it is not recommended for long-term or production use due to its procedural nature and limited error handling. For production-grade workflows, configuration management tools (e.g., Ansible, cloud-init) or image-based approaches are more robust and reproducible.

```hcl
resource "aws_instance" "tf_mastery_ec2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id                   = aws_subnet.tf_mastery_public.id
  vpc_security_group_ids      = [aws_security_group.tf_mastery_sg.id, aws_security_group.tf_mastery_web.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated_key.key_name

  connection {
    user        = "ec2-user"
    private_key = tls_private_key.generated.private_key_pem
    host        = self.public_ip
  }

  provisioner "local-exec" {
    command = "chmod 600 ${local_file.private_key_pem.filename}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /tmp",
      "sudo git clone https://github.com/hashicorp/demo-terraform-101 /tmp",
      "sudo sh /tmp/assets/setup-web.sh",
    ]
  }

  tags = {
    Name  = local.server_name
    Owner = local.team
    App   = local.application
  }
}
```

---

## Deployment & Validation

Ensure configuration is valid:

```bash
terraform validate
```

Deploy resources and provision automatically:

```bash
terraform apply
```

Fetch instance metadata:

```bash
terraform state show aws_instance.tf_mastery_ec2
```

Example output:

```hcl
# aws_instance.tf_mastery_ec2:
resource "aws_instance" "tf_mastery_ec2" {
    ami                                  = "ami-02b3c03c6fadb6e2c"
    arn                                  = "arn:aws:ec2:us-east-1:533267010082:instance/i-03eb9adc82450dbf9"
    associate_public_ip_address          = true
    availability_zone                    = "us-east-1a"
    cpu_core_count                       = 1
    cpu_threads_per_core                 = 1
    disable_api_stop                     = false
    disable_api_termination              = false
    ebs_optimized                        = false
    get_password_data                    = false
    hibernation                          = false
    host_id                              = null
    iam_instance_profile                 = null
    id                                   = "i-03eb9adc82450dbf9"
    instance_initiated_shutdown_behavior = "stop"
    instance_lifecycle                   = null
    instance_state                       = "running"
    instance_type                        = "t2.micro"
    ipv6_address_count                   = 0
    ipv6_addresses                       = []
    key_name                             = "tf_mastery_generated_key"
    monitoring                           = false
    outpost_arn                          = null
    password_data                        = null
    placement_group                      = null
    placement_partition_number           = 0
    primary_network_interface_id         = "eni-004103df95f0c37c7"
    private_dns                          = "ip-10-0-2-199.ec2.internal"
    private_ip                           = "10.0.2.199"
    public_dns                           = null
    public_ip                            = "54.227.176.21"
    secondary_private_ips                = []
    security_groups                      = []
    source_dest_check                    = true
    spot_instance_request_id             = null
    subnet_id                            = "subnet-0205806e6dbd620dd"
    tags                                 = {
        "App"   = "corp_api"
        "Name"  = "ec2-dev-api-us-east-1a"
        "Owner" = "api_mgmt_dev"
    }
    tags_all                             = {
        "App"   = "corp_api"
        "Name"  = "ec2-dev-api-us-east-1a"
        "Owner" = "api_mgmt_dev"
    }
    tenancy                              = "default"
    user_data_replace_on_change          = false
    vpc_security_group_ids               = [
        "sg-07a17b19554e3a7f5",
        "sg-084416e3c257a9678",
    ]

    capacity_reservation_specification {
        capacity_reservation_preference = "open"
    }

    cpu_options {
        amd_sev_snp      = null
        core_count       = 1
        threads_per_core = 1
    }

    credit_specification {
        cpu_credits = "standard"
    }

    enclave_options {
        enabled = false
    }

    maintenance_options {
        auto_recovery = "default"
    }

    metadata_options {
        http_endpoint               = "enabled"
        http_protocol_ipv6          = "disabled"
        http_put_response_hop_limit = 1
        http_tokens                 = "optional"
        instance_metadata_tags      = "disabled"
    }

    private_dns_name_options {
        enable_resource_name_dns_a_record    = false
        enable_resource_name_dns_aaaa_record = false
        hostname_type                        = "ip-name"
    }

    root_block_device {
        delete_on_termination = true
        device_name           = "/dev/xvda"
        encrypted             = false
        iops                  = 100
        kms_key_id            = null
        tags                  = {}
        tags_all              = {}
        throughput            = 0
        volume_id             = "vol-052a7e3e4ed3de89f"
        volume_size           = 8
        volume_type           = "gp2"
    }
}
```

Verify application by visiting:

```
http://54.227.176.21
```

Optionally SSH into the instance:

```bash
ssh -i MyAWSKey.pem ec2-user@54.227.176.21
```

Example output:

```text
   ,     #_
   ~\_  ####_        Amazon Linux 2
  ~~  \_#####\
  ~~     \###|       AL2 End of Life is 2026-06-30.
  ~~       \#/ ___
   ~~       V~' '->
    ~~~         /    A newer version of Amazon Linux is available!
      ~~._.   _/
         _/ _/       Amazon Linux 2023, GA and supported until 2028-03-15.
       _/m/'           https://aws.amazon.com/linux/amazon-linux-2023/
```

---

## Real-World Use Cases

- Automatically bootstrapping EC2 instances with application setup scripts
- Enforcing strict SSH key management policies via Infrastructure as Code
- Enhancing CI/CD pipelines by incorporating infrastructure provisioning steps
- Simplifying staging environment replication

---

## Conclusion

This project demonstrates proficiency in using Terraform provisioners to automate full lifecycle infrastructure provisioning. From generating secure SSH credentials to installing web apps on remote servers, this workflow streamlines cloud deployment and enforces infrastructure consistency.

Additionally, this lab reinforced skills in:

- Using the TLS provider for key management
- Managing IAM-compliant SSH authentication
- Running secure provisioning steps remotely using `remote-exec`
- Safely handling local credentials using `local-exec` with permission enforcement
- Understanding the limitations of remote provisioning and recognizing better alternatives for production

This hands-on experience reflects my ability to integrate secure provisioning, automation, and real-world DevOps workflows using Terraform—ensuring reproducible, secure, and efficient infrastructure delivery in alignment with modern cloud engineering practices.

---
