# Terraform Provider Block

Using the AWS provider to interact with the many resources supported by AWS. Configure the provider with the proper credentials before using it.

---

# Overview

This lab explains the purpose and configuration of the `provider` block in Terraform. The provider block allows Terraform to interact with APIs of cloud platforms or services. In this case, we demonstrate the AWS provider, which is used to provision and manage AWS resources.

Providers are responsible for understanding API interactions and exposing resources. Specifying the provider is the first step in enabling infrastructure deployment with Terraform.

---

## Check Terraform Version

Run the following command to check the Terraform version:

```bash
terraform -version
```

Sample output:

```text
Terraform v1.12.2
on darwin_arm64
```

---

## Configure Terraform AWS Provider

Create a basic `main.tf` file:

```hcl
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
```

This informs Terraform that all infrastructure will be deployed into the `us-east-1` AWS region.

---

## Task 2: Configure AWS Credentials for Terraform Provider

Terraform supports multiple ways to authenticate to AWS. Below are common approaches:

### 1. Static Credentials (Not Recommended)

```hcl
provider "aws" {
  region     = "us-east-1"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}
```

⚠️ This is insecure and not recommended, especially in shared or version-controlled environments.

### 2. Environment Variables (Recommended)

```bash
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
export AWS_DEFAULT_REGION="us-east-1"
```

In Terraform:

```hcl
provider "aws" {}
```

Terraform automatically reads credentials from the environment.

### 3. Shared Credentials File (\~/.aws/credentials)

```hcl
provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "/Users/tf_user/.aws/creds"
  profile                 = "customprofile"
}
```

Or export the profile:

```bash
export AWS_PROFILE=customprofile
```

---

## Conclusion

The provider block is foundational to all Terraform configurations. It tells Terraform _how_ and _where_ to deploy resources. While hardcoding credentials is functional, it breaks security best practices. Use environment variables or shared credentials files instead to follow the principle of least privilege and avoid leaking secrets in version control.

Understanding how Terraform authenticates to AWS lays the groundwork for building secure, reusable infrastructure workflows.

---
