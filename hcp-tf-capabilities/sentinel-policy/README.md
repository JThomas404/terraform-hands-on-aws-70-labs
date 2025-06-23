# Terraform Cloud - Sentinel Policy

## Overview

This documentation outlines the implementation of Sentinel policies within Terraform Cloud (TFC) to enforce policy-as-code guardrails during infrastructure provisioning. Sentinel, HashiCorp’s policy-as-code framework, enables logic-based decision enforcement at specific stages in the Terraform workflow. When enabled, Sentinel executes between the `plan` and `apply` phases, allowing enforcement of governance requirements.

---

## Terraform Cloud Sentinel Integration Prerequisites

To use Sentinel policies, the workspace must be part of a Terraform Cloud organisation with **Team & Governance** tier enabled. New TFC users can access this functionality during the 30-day trial.

---

## Enforcing EC2 Resource Constraints Using Sentinel

### Sentinel Policies Used

Two example Sentinel policies are applied to constrain EC2 configuration in alignment with organisational compliance:

- **Mandatory Tags**: All EC2 instances must have a `Name` tag.
- **Allowed Instance Types**: Only `t3.micro`, `t2.small`, and `t2.medium` instance types are permitted.

These are sourced from a version-controlled GitHub repository:

- [`enforce-mandatory-tags`](https://github.com/btkrausen/hashicorp/blob/master/terraform/Lab%20Prerequisites/Terraform%20Cloud%20Sentinel/global/enforce-mandatory-tags.sentinel)
- [`restrict-ec2-instance-type`](https://github.com/btkrausen/hashicorp/blob/master/terraform/Lab%20Prerequisites/Terraform%20Cloud%20Sentinel/global/restrict-ec2-instance-type.sentinel)

> These policies leverage reusable Sentinel modules from [terraform-guides](https://github.com/hashicorp/terraform-guides/tree/master/governance/third-generation)

---

## Sentinel Policy Set Configuration

A policy set groups related Sentinel policies and assigns enforcement levels. Below is the `sentinel.hcl` file used to define a policy set.

```hcl
module "tfplan-functions" {
  source = "https://raw.githubusercontent.com/hashicorp/terraform-guides/master/governance/third-generation/common-functions/tfplan-functions/tfplan-functions.sentinel"
}

module "tfconfig-functions" {
  source = "https://raw.githubusercontent.com/hashicorp/terraform-guides/master/governance/third-generation/common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

policy "enforce-mandatory-tags" {
  enforcement_level = "advisory"
}

policy "restrict-ec2-instance-type" {
  enforcement_level = "hard-mandatory"
}
```

### Enforcement Levels

- **Advisory**: Policy violations do not prevent deployment; logged as warnings.
- **Soft Mandatory**: Requires approval to override.
- **Hard Mandatory**: Cannot be overridden; policies must pass.

> The second policy (`restrict-ec2-instance-type`) is hard-mandatory, enforcing compliance for production-grade constraints.

---

## Applying Policy Sets to an Organisation

To enforce the policy set within Terraform Cloud:

1. Navigate to **Organisation Settings** > **Policy Sets**
2. Click **Connect a new policy set**
3. Use a GitHub integration to connect the repository
4. Set Name: `AWS-Global-Policies`
5. Description: `Sentinel Policies for AWS Governance`
6. Policies Path: `terraform/Lab Prerequisites/Terraform Cloud Sentinel/global`
7. Connect the policy set

---

## Validating Policy Execution in Terraform Cloud

### Queue a Terraform Plan

Trigger a plan in the `my-aws-app` workspace. A **Policy Check** stage will appear in the run.

![Policy Check Passed](img/tfc_sentinel_run_passed.png)

Navigate into the Policy Check section for detailed validation messages.

### Modify Terraform Configuration to Trigger Violation

In `aws_instance.web_server`, update the instance type to a non-compliant value:

```hcl
instance_type = "m5.large"
```

Queue a new plan:

```bash
terraform plan
```

The policy fails with:

```bash
aws_instance.web_server has instance_type with value m5.large that is not in the allowed list: [t3.micro, t2.small, t2.medium]
```

### Restore Compliant Configuration

Revert the change to:

```hcl
instance_type = "t2.medium"
```

Queue the plan again. It now passes all Sentinel checks.

---

## Skills Demonstrated

- Sentinel policy integration in Terraform Cloud
- Governance enforcement using policy sets and version control
- Use of advisory vs mandatory enforcement levels
- Validation and debugging of policy checks within TFC UI
- Policy-driven instance type and tagging compliance

---

## Real-World Use Cases

- Enforcing standardisation across cloud environments (e.g. tagging, sizing)
- Preventing non-compliant resources from being deployed
- Supporting audit and compliance workflows with versioned policies
- Limiting developer error through mandatory controls during the CI/CD lifecycle

---

## Versioning Rationale

All Sentinel policies and modules are version-controlled in GitHub and linked to TFC via integration. This enables:

- Transparent governance changes
- Policy promotion workflows (dev → staging → prod)
- Alignment of infrastructure changes with organisation policy evolution

Terraform versioning ensures deterministic Sentinel plan evaluations and minimises drift.

---

## Conclusion

This lab demonstrates the integration of Sentinel policies with Terraform Cloud for robust infrastructure governance. By codifying compliance checks into enforceable rules, teams can reduce human error, maintain alignment with organisational standards, and increase operational confidence.

The Sentinel framework, combined with Terraform Cloud’s versioned workflows, offers a scalable approach to policy enforcement in infrastructure provisioning pipelines.

---
