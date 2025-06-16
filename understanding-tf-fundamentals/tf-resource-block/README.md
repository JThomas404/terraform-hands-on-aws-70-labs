# Terraform Resource Block

Terraform uses resource blocks to manage infrastructure, such as virtual networks, compute instances, or higher-level components such as DNS records. Resource blocks represent one or more infrastructure objects in the Terraform configuration. Most Terraform providers have a number of different resources that map to the appropriate APIs to manage that particular infrastructure type.

```hcl
# Template
<BLOCK TYPE> "<BLOCK LABEL>" "<BLOCK LABEL>" {
  # Block body
  <IDENTIFIER> = <EXPRESSION> # Argument
}
```

When working with a specific provider, like AWS, Azure, or GCP, the resources are defined in the provider documentation. Each resource is fully documented in regards to the valid and required arguments required for each individual resource. For example, the `aws_key_pair` resource has a "Required" argument of `public_key` but optional arguments like `key_name` and `tags`.&#x20;

**Important** - Without `resource` blocks, Terraform is not going to create resources. All of the other block types, such as `variable`, `provider`, `terraform`, `output`, etc. are essentially supporting block types for the `resource` block.

## AWS Resource Table (Resources defined in my main.tf)

| Resource    | AWS Provider                | AWS Infrastructure         |
| ----------- | --------------------------- | -------------------------- |
| Resource 1  | aws_vpc                     | VPC                        |
| Resource 2  | aws_internet_gateway        | Internet Gateway           |
| Resource 3  | aws_subnet                  | Public and Private Subnets |
| Resource 4  | aws_eip                     | Elastic IP                 |
| Resource 5  | aws_nat_gateway             | NAT Gateway                |
| Resource 6  | aws_route_table             | Route Tables               |
| Resource 7  | aws_route                   | Routes                     |
| Resource 8  | aws_route_table_association | Subnet Associations        |
| Resource 9  | aws_security_group          | Security Group             |
| Resource 10 | random_id                   | Random S3 Suffix Generator |
| Resource 11 | aws_s3_bucket               | Amazon S3 Bucket           |
| Resource 12 | aws_key_pair                | EC2 Key Pair               |
| Resource 13 | aws_instance                | EC2 Instance               |

---

## AWS Infrastructure with Terraform

### Provider Configuration

```hcl
provider "aws" {
  region = "us-east-1"
}
```

Configures the AWS provider to deploy resources in the `us-east-1` region.

---

### VPC and Internet Gateway

```hcl
resource "aws_vpc" "tf_mastery_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = var.tags
}
```

Defines a VPC with a /16 CIDR block for private networking.

```hcl
resource "aws_internet_gateway" "tf_mastery_igw" {
  vpc_id = aws_vpc.tf_mastery_vpc.id
  tags   = var.tags
}
```

Attaches an Internet Gateway to the VPC to enable public internet access.

---

### Subnets

```hcl
resource "aws_subnet" "tf_mastery_public" {
  vpc_id                  = aws_vpc.tf_mastery_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags                    = merge(var.tags, { Name = "${var.tags["Name"]}-public-subnet" })
}
```

Creates a public subnet with automatic public IP assignment.

```hcl
resource "aws_subnet" "tf_mastery_private" {
  vpc_id            = aws_vpc.tf_mastery_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags              = merge(var.tags, { Name = "${var.tags["Name"]}-private-subnet" })
}
```

Creates a private subnet for internal-only resources.

---

### NAT Gateway with EIP

```hcl
resource "aws_eip" "tf_mastery_eip" {
  domain = "vpc"
}
```

Provisions an Elastic IP (EIP) for NAT Gateway use.

```hcl
resource "aws_nat_gateway" "tf_mastery_ngw" {
  subnet_id     = aws_subnet.tf_mastery_public.id
  allocation_id = aws_eip.tf_mastery_eip.id
  tags          = var.tags

  depends_on = [aws_internet_gateway.tf_mastery_igw]
}
```

Creates a NAT Gateway in the public subnet, using the EIP, to provide internet access for private subnets.

---

### Route Tables

```hcl
resource "aws_route_table" "tf_mastery_public_rt" {
  vpc_id = aws_vpc.tf_mastery_vpc.id
  tags   = merge(var.tags, { Name = "${var.tags["Name"]}-public-rt" })
}
```

Creates a route table for the public subnet.

```hcl
resource "aws_route_table" "tf_mastery_private_rt" {
  vpc_id = aws_vpc.tf_mastery_vpc.id
  tags   = merge(var.tags, { Name = "${var.tags["Name"]}-private-rt" })
}
```

Creates a route table for the private subnet.

---

### Routes

```hcl
resource "aws_route" "tf_mastery_public_igw" {
  route_table_id         = aws_route_table.tf_mastery_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tf_mastery_igw.id
}
```

Defines a route from the public subnet to the internet via the Internet Gateway.

```hcl
resource "aws_route" "tf_mastery_private_ngw" {
  route_table_id         = aws_route_table.tf_mastery_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.tf_mastery_ngw.id
}
```

Defines a route from the private subnet to the internet via the NAT Gateway.

---

### Route Table Associations

```hcl
resource "aws_route_table_association" "tf_mastery_public" {
  subnet_id      = aws_subnet.tf_mastery_public.id
  route_table_id = aws_route_table.tf_mastery_public_rt.id
}
```

Associates the public subnet with its route table.

```hcl
resource "aws_route_table_association" "tf_mastery_private" {
  subnet_id      = aws_subnet.tf_mastery_private.id
  route_table_id = aws_route_table.tf_mastery_private_rt.id
}
```

Associates the private subnet with its route table.

---

### Security Group

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

Enables SSH access to EC2 instances and unrestricted outbound traffic.

---

### S3 Bucket

```hcl
resource "random_id" "random_s3_suffix" {
  byte_length = 8
}
```

Generates a random suffix for the bucket name.

```hcl
resource "aws_s3_bucket" "tf_mastery_bucket" {
  bucket        = "tf-mastery-s3-bucket-${random_id.random_s3_suffix.hex}"
  force_destroy = true
  tags          = var.tags
}
```

Creates an S3 bucket with a unique name and tags.

---

### EC2 Instance

```hcl
resource "aws_key_pair" "tf_mastery_key" {
  key_name   = "tf_master_key"
  public_key = "ssh-rsa AAAAB3NzaC1... email@example.com"
}
```

Imports a public SSH key for EC2 instance access.

```hcl
resource "aws_instance" "tf_mastery_ec2" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  subnet_id                   = aws_subnet.tf_mastery_public.id
  vpc_security_group_ids      = [aws_security_group.tf_mastery_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.tf_mastery_key.key_name

  tags = var.tags
}
```

Launches an EC2 instance in the public subnet using the security group and SSH key.

---

## Summary of Terraform AWS Infrastructure Concepts

### Resource Creation and Configuration

- **S3 Buckets:** Creating globally unique buckets using `random_id`
- **VPC:** Setting up a VPC with proper CIDR blocks
- **Subnets:** Creating public and private subnets with appropriate attributes
- **Security Groups:** Configuring inbound/outbound rules for network security
- **EC2 Instances:** Launching instances with the right AMI, instance type, and networking

### Networking Components

- **Internet Gateway:** Providing internet access for public subnets
- **NAT Gateway:** Enabling outbound internet access for private subnets
- **Elastic IPs:** Allocating static public IPs for resources like NAT Gateways
- **Route Tables:** Creating separate tables for public and private subnets
- **Routes:** Directing traffic to appropriate gateways
- **Route Table Associations:** Connecting subnets to their route tables

### Terraform Best Practices

- **Resource Organization:** Logical ordering of resources based on dependencies
- **Variable Usage:** Creating reusable configurations with variables
- **Tagging Strategy:** Consistent resource tagging for better management
- **Security Considerations:** Limiting SSH access, using key pairs properly
- **Resource References:** Correctly referencing resources using Terraform's syntax
- **Dependencies:** Managing resource creation order with `depends_on`

### AWS Architecture Patterns

- **Public-Private Architecture:** Separating internet-facing and internal resources
- **Security Layers:** Implementing defense in depth with security groups and network ACLs
- **High Availability:** Distributing resources across availability zones

---

## Conclusion

This lab provided a deep understanding of Terraform’s core capability: resource provisioning. By building an AWS environment end-to-end—including networking, compute, storage, and security—you developed the foundational skills needed for more complex deployments. I also learned how to follow best practices such as using variables, organising resource dependencies, and securing access. Mastering the `resource` block is essential to becoming proficient in Terraform, as it is the core building unit that allows you to declaratively manage infrastructure across cloud providers.

---
