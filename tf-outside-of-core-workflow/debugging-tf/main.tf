provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = terraform.workspace
    }
  }
}

locals {
  team        = "api_mgmt_dev"
  application = "corp_api"
  server_name = "ec2-${var.environment}-api-${var.variables_sub_az}"
}

# VPC and Internet Gateway
resource "aws_vpc" "tf_mastery_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = var.tags
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
  availability_zone = "us-east-1a"
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

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

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
      "sudo yum install -y git",
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
