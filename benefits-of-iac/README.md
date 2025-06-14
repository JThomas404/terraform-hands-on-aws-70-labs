# The Benefits of IaC

## Overview

While there are many benefits of Infrastructure as Code (IaC), a few key advantages include the simplification of cloud adoption—allowing teams to quickly leverage cloud-based services to improve capabilities.

IaC eliminates many of the manual steps typically required for provisioning, enabling automation of infrastructure requests without relying on ticketing queues. It also enables on-demand capacity by exposing reusable infrastructure modules and services to developers, potentially through self-service portals.

Ultimately, IaC drives standardisation and consistency across the organisation, improving efficiency while reducing human error and configuration drift.

> Reference: [Infrastructure as Code in a Private or Public Cloud](https://www.hashicorp.com/resources/what-is-infrastructure-as-code)

---

## Desired Infrastructure

The end state of the AWS environment should look similar to the following diagram:

![Desired Infrastructure](https://github.com/JThomas404/terraform-hands-on-aws-70-labs/blob/main/benefits-of-iac/images/figure-1-desired-infrastructure.png?raw=true)

--

## Real-World Business Value

This lab demonstrates the foundational benefit of Infrastructure as Code—automating cloud resource provisioning across multiple availability zones with consistent configuration and teardown logic. By using Terraform to deploy AWS VPC resources, reduce manual error, accelerate time-to-delivery, and enforce repeatability.

---

## Prerequisites

- AWS Account with programmatic access
- AWS CLI configured locally
- Terraform CLI installed (version 1.5 or later)

---

## Project Folder Structure

```
benefits-of-iac/
├── terraform/
│   ├── main.tf
│   └── variables.tf
├── README.md
└── images/
    └── figure-1-desired-infrastructure.png
```

---

## Tasks and Implementation Steps

1. Create a new VPC in the `us-east-1` region
2. Create three public and private subnets across different AZs
3. Attach an Internet Gateway to the VPC
4. Provision a NAT Gateway for outbound traffic from private subnets
5. Configure route tables for both public and private subnets
6. Tear down the VPC manually or with Terraform destroy
7. Prepare credentials and export them via environment variables
8. Deploy infrastructure using `terraform apply`
9. Clean up with `terraform destroy`

---

## Core Implementation Breakdown

Terraform configuration includes the creation of a VPC, Internet Gateway, three public and private subnets, a single NAT Gateway, route tables, and associations. Availability Zones are dynamically fetched using a data source. Subnet CIDRs are generated with `cidrsubnet` logic.

### `main.tf`

```hcl
provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "iac-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 3)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "private-subnet-${count.index}"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
```

### `variables.tf`

```hcl
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
```

---

## Local Testing and Debugging

Deployment was validated using `terraform plan` and `terraform apply`, confirming successful provisioning of all required resources. Resources were verified through the AWS Console (VPC, Subnets, IGW, NAT Gateway, and Route Tables).

---

## Skills Demonstrated

- Infrastructure as Code principles with Terraform
- AWS networking: VPC, Subnets, IGW, NAT, and Route Tables
- Terraform interpolation and dynamic resource creation with `count`
- Secure handling of cloud credentials using environment variables
- Cloud architecture design aligned with multi-AZ failover

---

## Conclusion

This lab implements a production-grade VPC foundation using Infrastructure as Code on AWS. It reflects modern cloud engineering principles such as repeatability, modularity, and minimal human error through automation. The setup supports real-world use cases such as internet-facing and private backend applications across high-availability zones.

---
