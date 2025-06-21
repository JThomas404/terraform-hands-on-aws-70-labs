variable "aws_region" {
  type        = string
  description = "region used to deploy workloads"
  default     = "us-east-1"
  validation {
    condition     = can(regex("^us-", var.aws_region))
    error_message = "The aws_region value must be a valid region in the US, starting with \"us-\"."
  }
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "variables_sub_cidr" {
  description = "CIDR Block for Variable Subnet"
  type        = string
  default     = "10.0.222.0/24"
}

variable "variables_sub_az" {
  description = "Availability Zone used Variable Subnet"
  type        = string
  default     = "us-east-1a"
}

variable "variables_sub_auto_ip" {
  description = "Set Automatic IP Assignment for Variables Subnet"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment for Deployment"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Default tags for this Project"
  type        = map(string)
  default = {
    Name        = "Terraform Mastery Project"
    Environment = "Dev"
  }
}

variable "us-east-1-azs" {
  type = list(string)
  default = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
    "us-east-1d",
    "us-east-1e"
  ]
}

variable "ip" {
  type = map(string)
  default = {
    prod = "10.0.150.0/24"
    dev  = "10.0.250.0/24"
  }
}

variable "env" {
  type = map(any)
  default = {
    prod = {
      ip = "10.0.150.0/24"
      az = "us-east-1a"
    }
    dev = {
      ip = "10.0.250.0/24"
      az = "us-east-1e"
    }
  }
}

variable "num_1" {
  type        = number
  description = "Numbers for function labs"
  default     = 88
}

variable "num_2" {
  type        = number
  description = "Numbers for function labs"
  default     = 73
}

variable "num_3" {
  type        = number
  description = "Numbers for function labs"
  default     = 52
}
