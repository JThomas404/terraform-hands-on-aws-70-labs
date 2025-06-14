# Terraform Basics

All interactions with Terraform occur via the CLI. The Terraform ecosystem also includes providers for many cloud services, and a module repository. HashiCorp also has products to help teams manage Terraform: Terraform Cloud and Terraform Enterprise.

# Overview

This lab demonstrates the foundational workflow of working with Terraform, helping users understand how to manage infrastructure declaratively using HCL (HashiCorp Configuration Language). It introduces the standard Terraform workflow and provides practical usage examples to:

- Verify and inspect Terraform installation
- Initialise a working directory
- Validate configuration syntax
- Preview infrastructure changes
- Apply and destroy Terraform-managed resources

These form the building blocks that all Terraform projects rely on.

---

## Verify Terraform installation and version

Find the version of Terraform with the following command:

```bash
terraform -version
```

Get a list of available commands and arguments:

```bash
terraform -help
```

---

## Initialise Terraform Working Directory

Create a simple Terraform configuration file `main.tf`:

```hcl
resource "random_string" "random" {
  length = 16
}
```

Run the following command to initialise the directory:

```bash
terraform init
```

Terraform will install required provider plugins and initialise the workspace.

---

## Validating a Configuration

Ensure your syntax and structure are valid:

```bash
terraform validate
```

Expected output:

```bash
Success! The configuration is valid.
```

---

## Generating a Terraform Plan

Preview changes Terraform would make without actually applying them:

```bash
terraform plan
```

Sample output:

```bash
Terraform will perform the following actions:

  # random_string.random will be created
  + resource "random_string" "random" {
      + id          = (known after apply)
      + length      = 16
      + lower       = true
      + min_lower   = 0
      + min_numeric = 0
      + min_special = 0
      + min_upper   = 0
      + number      = true
      + result      = (known after apply)
      + special     = true
      + upper       = true
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

You can also save the plan:

```bash
terraform plan -out myplan
```

---

## Applying a Terraform Plan

To apply the saved plan:

```bash
terraform apply myplan
```

Alternatively, apply directly:

```bash
terraform apply
```

Modify `main.tf` to:

```hcl
resource "random_string" "random" {
  length = 10
}
```

Then re-run:

```bash
terraform apply
```

Sample output:

```bash
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # random_string.random must be replaced
-/+ resource "random_string" "random" {
      ~ id          = "XW>5m{w8Ig96d1A&" -> (known after apply)
      ~ length      = 16 -> 10 # forces replacement
      ~ result      = "XW>5m{w8Ig96d1A&" -> (known after apply)
        # (8 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

---

## Destroying Terraform Resources

Preview what Terraform will destroy:

```bash
terraform plan -destroy
```

Sample output:

```bash
Terraform will perform the following actions:

  # random_string.random will be destroyed
  - resource "random_string" "random" {
      - id          = "1HIQs)moC0" -> null
      - length      = 10 -> null
      - lower       = true -> null
      - min_lower   = 0 -> null
      - min_numeric = 0 -> null
      - min_special = 0 -> null
      - min_upper   = 0 -> null
      - number      = true -> null
      - result      = "1HIQs)moC0" -> null
      - special     = true -> null
      - upper       = true -> null
    }

Plan: 0 to add, 0 to change, 1 to destroy.
```

Then destroy the resources:

```bash
terraform destroy
```

Final output and prompt:

```bash
Terraform will perform the following actions:

  # random_string.random will be destroyed
  - resource "random_string" "random" {
      - id          = "1HIQs)moC0" -> null
      - length      = 10 -> null
      - lower       = true -> null
      - min_lower   = 0 -> null
      - min_numeric = 0 -> null
      - min_special = 0 -> null
      - min_upper   = 0 -> null
      - number      = true -> null
      - result      = "1HIQs)moC0" -> null
      - special     = true -> null
      - upper       = true -> null
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value:
```

---

## Conclusion

This lab introduced the essential building blocks of working with Terraform through a hands-on, CLI-driven workflow. I began by verifying your local Terraform setup and progressed through initialising a working directory, validating configuration syntax, generating execution plans, applying infrastructure changes, and safely destroying resources.

Understanding this standard workflow is vital before progressing to more advanced Terraform features like modules, backends, input variables, and provisioning real cloud infrastructure. By mastering these basics, I now have a strong foundation to scale my skills toward building secure, automated infrastructure as code.

---
