resource "aws_vpc" "tf_mastery_vpc" {
  cidr_block = "10.0.0.0/16"
}


resource "aws_subnet" "variables-subnet" {
  vpc_id                  = aws_vpc.tf_mastery_vpc.id
  cidr_block              = var.variables_sub_cidr
  availability_zone       = var.variables_sub_az
  map_public_ip_on_launch = var.variables_sub_auto_ip

  tags = {
    Name      = "sub-variables-${var.aws_region}"
    Terraform = "true"
  }
}
