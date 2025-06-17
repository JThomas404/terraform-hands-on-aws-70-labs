# Debugging Terraform

## Overview

This lab focused on debugging Terraform workflows using logging and trace techniques. I explored how to enable, configure, and interpret Terraform logs for troubleshooting issues during initialisation and apply phases. Understanding these logs is essential for diagnosing provider resolution problems, syntax errors, and state mismatches in Infrastructure as Code (IaC) workflows.

---

## Enable Logging

Terraform provides a built-in logging mechanism that helps diagnose internal behaviors. This can be enabled using the `TF_LOG` environment variable.

Set `TF_LOG` to one of the following levels depending on desired verbosity:

- `TRACE` – Most verbose
- `DEBUG`
- `INFO`
- `WARN`
- `ERROR` – Least verbose

### Example (Linux/macOS):

```bash
export TF_LOG=TRACE
```

### Example (PowerShell):

```shell
$env:TF_LOG="TRACE"
```

Run a Terraform command such as `apply` to see logs:

```bash
terraform apply
```

---

## Enable Logging Path

To persist logs for analysis, use the `TF_LOG_PATH` variable in combination with `TF_LOG`. This will append logs to a specified file.

### Example (Linux/macOS):

```bash
export TF_LOG=TRACE
export TF_LOG_PATH="terraform_log.txt"
```

### Example (PowerShell):

```shell
$env:TF_LOG="TRACE"
$env:TF_LOG_PATH="terraform_log.txt"
```

Run:

```bash
terraform init -upgrade
```

Open the `terraform_log.txt` file to inspect detailed trace output. For example, you can observe how Terraform resolves providers, loads modules, and interacts with remote backends.

### Tip:

Delete or comment out your `required_providers` block and re-run `terraform plan` to observe how Terraform tries to auto-discover the provider source. This is a useful debugging trick for understanding provider behavior.

---

## Disable Logging

To disable verbose logging, clear the `TF_LOG` variable.

### Linux/macOS:

```bash
unset TF_LOG
```

### PowerShell:

```shell
$env:TF_LOG=""
```

---

## Real-World Use Cases

- Troubleshooting failed Terraform operations (e.g., authentication, module resolution, provider plugin errors)
- Understanding hidden behavior during `terraform init`, `plan`, or `apply`
- Diagnosing issues with remote state, IAM roles, or resource dependencies
- Debugging CI/CD pipelines that use Terraform
- Auditing and logging for compliance in enterprise IaC workflows

---

## Conclusion

This project strengthened my ability to debug Terraform-based infrastructure by enabling, analysing, and managing detailed execution logs. I now understand how to use logging levels and persistent log files to uncover misconfigurations and internal errors.

This hands-on experience reflects my ability to apply diagnostic techniques for secure, reproducible, and efficient Terraform workflows in real-world DevOps environments.

---
