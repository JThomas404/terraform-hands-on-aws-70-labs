# Terraform Input Variables

## Overview

This project documents my direct implementation and testing of Terraform input variables, focusing on managing infrastructure configuration through clearly defined, flexible inputs. By avoiding hardcoded values and applying layered overrides, I ensured the configuration remains modular, secure, and environment-agnostic.

## Order of Precedence for Input Variables

The following hierarchy illustrates how Terraform determines which value to assign when multiple sources are defined for a variable:

<pre>
                    ↓ Order of Precedence (Lowest to Highest)

                    +---------------------------------------------+
                    |             Variable defaults               |
                    +---------------------------------------------+
                    |           Environment Variables             |
                    +---------------------------------------------+
                    |           terraform.tfvars file             |
                    +---------------------------------------------+
                    |         terraform.tfvars.json file          |
                    +---------------------------------------------+
                    |    *.auto.tfvars or *.auto.tfvars.json      |
                    +---------------------------------------------+
                    | Command Line: -var and --var-file (Highest) |
                    +---------------------------------------------+
</pre>

## Setting Variable Values via Environment Variables

To verify how environment variables affect configuration, I exported a new CIDR block using the required `TF_VAR_` prefix:

```bash
export TF_VAR_variables_sub_cidr="10.0.203.0/24"
```

Running `terraform plan` showed that Terraform proposed a replacement for the subnet resource. This validated that environment variables successfully override the default variable values defined in `variables.tf`.

## Using terraform.tfvars to Define Values

Next, I created a `terraform.tfvars` file to supply a new set of values:

```hcl
variables_sub_auto_ip = true
variables_sub_az      = "us-east-1d"
variables_sub_cidr    = "10.0.204.0/24"
```

Executing `terraform plan` again indicated a pending subnet replacement, demonstrating that `.tfvars` files take precedence over both default values and environment variables.

## Overriding Variables on the CLI

To test the highest-precedence method, I provided values directly via command-line flags:

```bash
terraform plan -var variables_sub_az="us-east-1e" -var variables_sub_cidr="10.0.205.0/24"
```

Terraform proposed another replacement. This confirmed that CLI input overrides all previous sources, including `.tfvars` and environment variables.

## Real-World Use Case

This input variable precedence structure is crucial in multi-environment infrastructure pipelines:

- **Defaults** define baseline configurations shared across all environments.
- **Environment Variables** support CI/CD and secure secret injection without exposing credentials.
- **.tfvars files** facilitate separate configurations for dev, staging, and production.
- **CLI flags** provide flexible, one-off overrides for QA and hotfix scenarios.

This separation enhances reproducibility, reduces configuration drift, and aligns with infrastructure as code best practices.

## Conclusion

Through this lab, I validated how Terraform assigns variable values from different sources and the order in which they are evaluated. Each configuration change was tested using `terraform plan` to ensure accuracy.

This practical work demonstrates my ability to:

- Implement secure, flexible input variable strategies
- Maintain infrastructure across multiple environments
- Apply reproducible and intentional configurations
- Troubleshoot and audit input precedence behaviors

These skills are essential for delivering reliable and modular cloud infrastructure at scale.

---
