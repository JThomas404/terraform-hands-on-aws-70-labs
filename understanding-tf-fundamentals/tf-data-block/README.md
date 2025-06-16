# Terraform Data Block&#x20;

## Overview

This lab demonstrates how Terraform **data blocks** are used to integrate existing AWS infrastructure metadata into a Terraform-managed deployment. Unlike `resource` blocks, data sources are read-only and enable dynamic retrieval of values such as the current AWS region, available availability zones, or the latest Amazon Machine Image (AMI).

Data sources are used in Terraform to load or query data from APIs or other Terraform workspaces. I used data blocks to make my configuration more flexible and to connect different workspaces that manage different parts of the infrastructure. These capabilities are especially useful for cross-workspace data sharing in Terraform Cloud and Terraform Enterprise.

To use a data source, declare it using a `data` block in the Terraform configuration. Terraform will perform the query and store the returned data.

Data blocks in Terraform HCL are comprised of the following components:

- **Data Block**: A top-level keyword like `resource`
- **Data Type**: Prefixed by the provider (e.g., `aws_ami`), indicates the kind of data being fetched
- **Data Local Name**: A user-defined identifier to reference the block
- **Data Arguments**: Provider-specific parameters required to perform the lookup

### Template

```hcl
data "<DATA TYPE>" "<DATA LOCAL NAME>" {
  # Block body
  <IDENTIFIER> = <EXPRESSION>
}
```

For example, a data block might retrieve an AWS AMI using `data "aws_ami" "ubuntu"` and reference it in a resource using `data.aws_ami.ubuntu.id`.

## Key Implementations

### Dynamic Tagging with Current Region

The following data source was used to retrieve the AWS region associated with the current credentials:

```hcl
data "aws_region" "current" {}
```

This region value was inputted into the VPC's tag block to reflect regional deployment dynamically:

```hcl
resource "aws_vpc" "tf_mastery_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = merge(
    var.tags,
    {
      region = data.aws_region.current.name
    }
  )
}
```

### Availability Zones Abstraction

The configuration uses a data source to query the availability zones within the current region:

```hcl
data "aws_availability_zones" "available" {}
```

This allows subnets to be assigned dynamically to an available AZ:

```hcl
resource "aws_subnet" "tf_mastery_private" {
  vpc_id            = aws_vpc.tf_mastery_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = tolist(data.aws_availability_zones.available.names)[0]

  tags = merge(var.tags, {
    Name = "${var.tags["Name"]}-private-subnet"
  })
}
```

This abstraction ensures compatibility across multiple AWS regions without hardcoding values.

### Querying Latest Ubuntu 22.04 AMI

To ensure EC2 instances use the most current Canonical Ubuntu 22.04 image, the following `aws_ami` data block was introduced:

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}
```

This data source was then referenced within the EC2 instance configuration:

```hcl
resource "aws_instance" "tf_mastery_ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
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
```

## Real-World Impact

Data blocks provide a foundational layer of abstraction critical in professional infrastructure deployments. By replacing hardcoded values with live AWS metadata, the infrastructure-as-code becomes:

- **Region-agnostic**: Automatically adapts to any AWS region based on current credentials
- **Environment-portable**: Promotes deployment to dev, staging, or prod by referencing current data
- **Future-proof**: Retrieves the latest AMIs or dynamically updated values instead of pinned static values

These characteristics are essential in production environments where flexibility, scalability, and maintainability are key.

## Conclusion

This implementation demonstrates strong adherence to Terraform best practices. By leveraging data sources effectively, the configuration becomes intelligent, resilient, and reusable. The ability to abstract data and inject dynamic values ensures consistency across environments and minimises hardcoded risk.

Real-world use case: Imagine deploying the same application stack to dev, test, and prod environments. By using data blocks to retrieve availability zones, AMI IDs, and current regions, we can maintain a single Terraform codebase and simply switch context via variables—enabling secure, scalable, and consistent multi-environment deployments.

---
