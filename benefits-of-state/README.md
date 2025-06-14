# Benefits of State

## Overview

This lab demonstrates how Terraform uses its state file to track and manage infrastructure changes in a reliable and efficient manner. It walks through a scenario where an EC2 instance is added to an existing AWS VPC created in a previous lab. By showcasing the `terraform show`, `terraform plan`, and `terraform apply` workflows, the lab highlights how Terraform ensures only necessary changes are applied. This results in more consistent, safer, and faster infrastructure management.

![AWS Application Infrastructure Buildout](https://github.com/JThomas404/terraform-hands-on-aws-70-labs/blob/main/benefits-of-state/images/obj-2-hcl.png?raw=true)

## Terraform State

In order to properly and correctly manage infrastructure resources, Terraform stores the state of the managed infrastructure. Terraform uses this state on each execution to plan and make changes to the infrastructure. This state must be stored and maintained on each execution so future operations can perform correctly.

## Benefits of State

During execution, Terraform will examine the state of the currently running infrastructure, determine what differences exist between the current state and the revised desired state, and indicate the necessary changes that must be applied. When approved to proceed, only the necessary changes will be applied, leaving existing, valid infrastructure untouched.

- Task 1: Show Current State
- Task 2: Update my Configuration
- Task 3: Plan and Execute Changes
- Task 4: Show New State

---

## Task 1: Show Current State

In my previous lab ([Benefits of IaC](https://github.com/JThomas404/terraform-hands-on-aws-70-labs/tree/main/benefits-of-iac)), I wrote some Terraform configuration to create a new VPC in AWS. Now that the VPC exists, I have built an EC2 instance in one of the public subnets. Since the VPC is already present, the only change that Terraform needs to address is the addition of the EC2 instance.

### View the resources in the Terminal

```bash
terraform show
```

Sample output from `terraform show`:

```hcl
# aws_internet_gateway.internet_gateway:
resource "aws_internet_gateway" "internet_gateway" {
  id     = "igw-0be99153cf7f3c6ab"
  vpc_id = "vpc-064a97911d85e16d4"
  tags = {
    Name = "demo_igw"
  }
}
```

---

## Task 2: Update the Configuration to Include EC2 Instance

Terraform can perform in-place updates after changes are made to the `main.tf` configuration file. I updated the configuration to include an EC2 instance in the public subnet:

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnets["public_subnet_1"].id
  tags = {
    Name = "Ubuntu EC2 Server"
  }
}
```

---

## Task 3: Plan and Execute Changes

### Dry Run with Terraform Plan

```bash
terraform plan
```

Sample plan output:

```hcl
# aws_instance.web_server will be created
+ resource "aws_instance" "web_server" {
    ami           = "ami-xxxxxxxxxxxxxxx"
    instance_type = "t3.micro"
    subnet_id     = "subnet-xxxxxxxxxxxxx"
    ...
  }

Plan: 1 to add, 0 to change, 0 to destroy.
```

### Apply the Configuration

```bash
terraform apply
```

Terraform will provision the EC2 instance and confirm with a success message.

---

## Task 4: Show New State

Once the instance is created, confirm that it has been added to Terraform's state.

```bash
terraform show
```

Sample EC2 instance state:

```hcl
resource "aws_instance" "web_server" {
  ami           = "ami-036490d46656c4818"
  instance_type = "t3.micro"
  public_ip     = "18.234.248.120"
  tags = {
    Name = "Ubuntu EC2 Server"
  }
  ...
}
```

### List All Resources

```bash
terraform state list
```

Example:

```bash
data.aws_ami.ubuntu
aws_instance.web_server
aws_vpc.vpc
aws_internet_gateway.internet_gateway
...
```

---

## Conclusion

This lab showcases how Terraform maintains and utilises its state file to track infrastructure changes. It enables idempotent operations, efficient updates, and ensures only the necessary infrastructure components are modified, reducing manual errors and improving deployment safety.

---
