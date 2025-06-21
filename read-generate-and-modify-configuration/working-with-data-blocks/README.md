# Working with Data Blocks in Terraform

## Overview

This lab demonstrates how Terraform uses data sources to query and reuse information about existing cloud infrastructure. In real-world environments, many resources are not created within the same configuration or even within Terraform at all. Data sources enable modules and configurations to dynamically retrieve resource attributes—improving flexibility, minimising hardcoding, and supporting multi-team collaboration.

This project specifically focuses on:

- Fetching existing resource metadata (e.g., an S3 bucket)
- Referencing data block attributes in new resource configurations
- Exporting resource metadata using outputs

---

## Key Implementations

### Query Existing Resources with `data` Blocks

Terraform data sources allow you to pull information about resources that already exist outside your Terraform codebase.

For example, we queried a manually created AWS S3 bucket:

```hcl
data "aws_s3_bucket" "data_bucket" {
  bucket = "my-data-lookup-bucket-tfm"
}
```

This allows you to reference this existing resource's attributes elsewhere in the configuration.

---

### Reference Data Source Attributes in New Resources

We created an IAM policy that allows access to the S3 bucket identified via the data block:

```hcl
resource "aws_iam_policy" "policy" {
  name        = "data_bucket_policy"
  description = "Deny access to my bucket"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:Get*",
          "s3:List*"
        ],
        "Resource": "${data.aws_s3_bucket.data_bucket.arn}"
      }
    ]
  })
}
```

This highlights how data lookups can be embedded into other Terraform resources.

---

### Export Data Block Attributes with `output`

We used Terraform outputs to view key S3 attributes obtained from the data source:

```hcl
output "data_bucket_arn" {
  value = data.aws_s3_bucket.data_bucket.arn
}

output "data_bucket_domain_name" {
  value = data.aws_s3_bucket.data_bucket.bucket_domain_name
}

output "data_bucket_region" {
  value = "The ${data.aws_s3_bucket.data_bucket.id} bucket is located in ${data.aws_s3_bucket.data_bucket.region}."
}
```

This is useful for debugging, visibility, and downstream configuration sharing.

---

## Real-World Use Case

In enterprise scenarios, cloud environments often consist of manually provisioned or separately managed infrastructure (e.g., S3 buckets, AMIs, or VPCs).

Terraform data sources allow platform and infrastructure teams to:

- Integrate Terraform with legacy or non-IaC-managed resources.
- Look up AMI IDs, DNS zones, KMS keys, and existing network configurations.
- Create reusable modules that adapt to their environment without needing hardcoded values.
- Support multi-team workflows where one team produces infrastructure and another consumes it.

Example: A security team manages an encrypted S3 bucket manually. An application team writing Terraform modules can use a data block to fetch the bucket ARN and configure IAM roles without needing direct bucket creation rights.

---

## Skills Demonstrated

- Retrieved and consumed resource metadata using `data` blocks
- Wrote IAM policy referencing data source attributes
- Exported resource data using Terraform outputs
- Demonstrated cross-resource referencing with existing infrastructure

---

## Conclusion

This lab illustrated the value of using Terraform data sources to build flexible and maintainable configurations. By querying and incorporating external infrastructure into Terraform workflows, teams can reduce duplication, centralise control, and ensure environment compatibility—key traits of scalable cloud infrastructure-as-code practices.

---
