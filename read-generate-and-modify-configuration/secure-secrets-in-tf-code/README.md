# Secure Secrets in Terraform Code

## Overview

This project documents my direct implementation of secure secret handling within Terraform. It highlights the most effective techniques for managing sensitive data across CLI usage, environment variables, and secret managers. This hands-on experience demonstrates my understanding of security best practices and Terraform's native features for protecting sensitive values.

## Avoiding Plaintext Secrets in Code

Storing secrets like credentials, tokens, and API keys directly in `.tf` or `.tfvars` files introduces critical security vulnerabilities:

- Secrets are versioned and distributed with the code.
- Any collaborator with Git access can view the secrets.
- Revoking or rotating secrets becomes difficult to audit.

As a baseline, no secrets should be committed to source control. This aligns with DevSecOps practices and is essential for auditability and infrastructure hardening.

## Marking Variables as Sensitive

Terraform allows variables to be marked as `sensitive`. This prevents them from being printed in CLI output or logs.

```hcl
variable "phone_number" {
  type      = string
  sensitive = true
  default   = "867-5309"
}

output "phone_number" {
  value     = var.phone_number
  sensitive = true
}
```

Even though suppressed from output, these values still exist in plaintext inside `terraform.tfstate`. Therefore, access to state files must be tightly controlled.

## Securely Providing Secrets via Environment Variables

Sensitive variables should be provided at runtime via environment variables to avoid hardcoding.

Update `variables.tf` to remove the default value:

```hcl
variable "phone_number" {
  type      = string
  sensitive = true
}
```

Export the value securely:

```bash
export TF_VAR_phone_number="867-5309"
```

This ensures the secret is read at runtime without being saved to the source code. In a production workflow, this export would typically be handled by a CI/CD pipeline or configured in Terraform Cloud.

## Using HashiCorp Vault for Secrets Injection

To simulate secure secret management at scale, I integrated Vault as a provider for retrieving secrets.

### Setup Steps

1. Install Vault from [https://www.vaultproject.io/docs/install](https://www.vaultproject.io/docs/install).
2. Start Vault in dev mode:

```bash
vault server -dev
```

3. Export the Vault dev server address:

```bash
export VAULT_ADDR="http://127.0.0.1:8200"
```

4. Login using the root token output on Vault startup:

```bash
vault login <root_token>
```

5. Store a secret:

```bash
vault kv put secret/app phone_number=867-5309
```

### Terraform Configuration

Create a new `vault/main.tf` with:

```hcl
provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = "<root_token>"  # Note: Use AppRole in production
}

data "vault_generic_secret" "phone_number" {
  path = "secret/app"
}

output "phone_number" {
  value     = data.vault_generic_secret.phone_number.data["phone_number"]
  sensitive = true
}
```

### Apply and Output

After `terraform apply`, the sensitive value is suppressed in standard output but can be displayed explicitly:

```bash
terraform output phone_number
```

This prints:

```bash
<sensitive>
```

To reveal:

```bash
terraform output -raw phone_number
```

## Real-World Use Cases

- **CI/CD Pipelines**: Securely inject secrets into Terraform from Vault or environment variables managed by GitHub Actions, Jenkins, etc.
- **Multi-User Environments**: Ensure secrets are not exposed in logs or code repos.
- **Auditing and Compliance**: Secure state file access and remove human error from secret distribution.

## Conclusion

Through this lab, I validated secure techniques for managing secrets in Terraform:

- Avoiding plain text secrets in source files
- Using `sensitive = true` to suppress CLI exposure
- Injecting secrets through environment variables
- Retrieving secrets securely from Vault using the Vault provider

This experience demonstrates my ability to design secure infrastructure-as-code pipelines that align with enterprise-grade cloud security standards and DevSecOps practices.

---
