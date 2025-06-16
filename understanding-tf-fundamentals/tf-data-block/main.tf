provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

locals {
  team        = "api_mgmt_dev"
  application = "corp_api"
  server_name = "ec2-${var.environment}-api-${var.variables_sub_az}"
}

# VPC and Internet Gateway
resource "aws_vpc" "tf_mastery_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = merge(
    var.tags,
    {
      region = data.aws_region.current.name
    }
  )

}

resource "aws_internet_gateway" "tf_mastery_igw" {
  vpc_id = aws_vpc.tf_mastery_vpc.id
  tags   = var.tags
}

# Subnets
resource "aws_subnet" "tf_mastery_public" {
  vpc_id                  = aws_vpc.tf_mastery_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags                    = merge(var.tags, { Name = "${var.tags["Name"]}-public-subnet" })
}

resource "aws_subnet" "tf_mastery_private" {
  vpc_id            = aws_vpc.tf_mastery_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]
  tags              = merge(var.tags, { Name = "${var.tags["Name"]}-private-subnet" })
}

# NAT Gateway with EIP
resource "aws_eip" "tf_mastery_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "tf_mastery_ngw" {
  subnet_id     = aws_subnet.tf_mastery_public.id
  allocation_id = aws_eip.tf_mastery_eip.id
  tags          = var.tags

  depends_on = [aws_internet_gateway.tf_mastery_igw]
}

# Route Tables
resource "aws_route_table" "tf_mastery_public_rt" {
  vpc_id = aws_vpc.tf_mastery_vpc.id
  tags   = merge(var.tags, { Name = "${var.tags["Name"]}-public-rt" })
}

resource "aws_route_table" "tf_mastery_private_rt" {
  vpc_id = aws_vpc.tf_mastery_vpc.id
  tags   = merge(var.tags, { Name = "${var.tags["Name"]}-private-rt" })
}

# Routes
resource "aws_route" "tf_mastery_public_igw" {
  route_table_id         = aws_route_table.tf_mastery_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tf_mastery_igw.id
}

resource "aws_route" "tf_mastery_private_ngw" {
  route_table_id         = aws_route_table.tf_mastery_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.tf_mastery_ngw.id
}

resource "aws_route_table_association" "tf_mastery_public" {
  subnet_id      = aws_subnet.tf_mastery_public.id
  route_table_id = aws_route_table.tf_mastery_public_rt.id
}

resource "aws_route_table_association" "tf_mastery_private" {
  subnet_id      = aws_subnet.tf_mastery_private.id
  route_table_id = aws_route_table.tf_mastery_private_rt.id
}

# Security Group
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

# S3 Bucket
resource "random_id" "random_s3_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "tf_mastery_bucket" {
  bucket        = "tf-mastery-s3-bucket-${random_id.random_s3_suffix.hex}"
  force_destroy = true
  tags          = var.tags
}

# EC2 Instance
resource "aws_key_pair" "tf_mastery_key" {
  key_name   = "tf_master_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

data "aws_ami" "ubuntu_22_04" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "tf_mastery_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  subnet_id                   = aws_subnet.tf_mastery_public.id
  vpc_security_group_ids      = [aws_security_group.tf_mastery_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.tf_mastery_key.key_name

  tags = {
    Name  = local.server_name
    Owner = local.team
    App   = local.application
  }
}


