# Terraform Module Versions

## Overview

Terraform modules, like software packages, are versioned. This versioning allows infrastructure code to remain consistent and predictable over time. In this lab, I experimented with multiple versions of the AWS VPC Terraform module to understand how semantic versioning impacts compatibility and maintainability.

---

## Version Pinning and Registry Integration

I began by using the [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) module. Terraform supports selecting a specific version of a module directly within the `module` block.

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = "my-vpc-terraform"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Name        = "VPC from Module"
    Terraform   = "true"
    Environment = "dev"
  }
}
```

After applying this version, I then modified the `version` argument to an older release:

```hcl
version = "1.73.0"
```

This exposed compatibility issues. Warnings indicated that the module used deprecated syntax:

```text
| Warning: Quoted references are deprecated
| Remove the quotes surrounding this reference to silence this warning.
```

This demonstrated how older module versions may conflict with newer Terraform core versions. This experiment underscored the importance of aligning module versions with the expected Terraform version.

---

## Compatibility Challenges in Older Modules

Some older modules were authored for versions of Terraform prior to 0.12, which accepted syntax and behaviors that are now deprecated. One specific example is the use of quoted references such as:

```hcl
ignore_changes = ["propagating_vgws"]
```

In Terraform 0.12 and later, quoted references are no longer interpreted as dynamic references. Instead, they are treated as string literals. The corrected syntax would be:

```hcl
ignore_changes = [propagating_vgws]
```

Such outdated patterns can cause warnings or even execution errors. Modules that have not been updated to align with the syntax rules of the active Terraform version may require manual patching or selective versioning to ensure smooth deployments. This highlights the need to test older module versions and be cautious when retrofitting infrastructure code to newer Terraform runtimes.

---

## Version Constraints

Next, I tested using version constraints to avoid introducing incompatible changes during module upgrades. I updated the module to allow any version greater than `5.0.0`:

```hcl
version = ">5.0.0"
```

Upon re-initialisation with `terraform init`, Terraform selected version `5.21.0` (the latest matching the constraint):

```text
Downloading registry.terraform.io/terraform-aws-modules/vpc/aws 5.21.0...
```

Version constraints like this are supported only for modules sourced from registries. For local or Git-based modules, versioning must be handled via explicit source control references (e.g., Git tags).

---

## Advanced Version Control: Provider Constraints

To further enforce Terraform compatibility and avoid unexpected behaviors, I can also specify required provider versions using the `required_providers` block within `terraform {}`:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
```

This ensures that both the module and the provider meet the required version constraints. It's especially helpful in teams or CI pipelines where environment consistency is crucial. Combining module version constraints with provider constraints is a best practice for full version governance.

---

## Best Practices

- **Pin Exact Versions for Production:** Prevent unintentional upgrades by locking specific, tested versions in production environments.
- **Use Constraints in Development:** Use semver constraints (e.g., `~> 5.0`) to allow updates while avoiding breaking changes.
- **Avoid Latest Tag:** Always specify a version or constraint—never rely on the default "latest" version.
- **Verify Compatibility:** Test older module versions against your current Terraform version to avoid deprecated features or syntax errors.
- **Complement Constraints with Provider Blocks:** Use `required_providers` alongside module constraints to guard against mismatches.

---

## Real-World Relevance

In a production CI/CD pipeline, Terraform modules may be automatically fetched. Without explicit versioning, updates to remote modules could break deployments. Teams often rely on versioned modules to:

- Maintain infrastructure stability
- Facilitate change reviews
- Enable safe rollbacks

This lab mirrored such practices by demonstrating how modules evolve over time and why version management is vital for infrastructure as code.

---

## Conclusion

Through this lab, I learned how module versioning directly affects Terraform compatibility and reliability. By working with multiple versions of a popular module, I gained firsthand experience in pinning, upgrading, and constraining modules to ensure robust and maintainable infrastructure deployments.

---
