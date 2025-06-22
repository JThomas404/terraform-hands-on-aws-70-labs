# Terraform Resource Lifecycle Management

## Overview

Terraform provides lifecycle customisation to give engineers more granular control over the creation, modification, and destruction of infrastructure resources. While Terraform’s resource graph ensures optimal execution order for deployments, there are edge cases—especially in production environments—where fine-tuning this behaviour is essential. Terraform’s `lifecycle` block enables control over replacement order and safeguards against accidental deletion.

These lifecycle directives are vital in scenarios where the default destroy-then-create behaviour could break dependencies, interrupt services, or delete critical infrastructure components.

This documentation outlines the use of lifecycle directives such as `create_before_destroy` and `prevent_destroy`, with real-world use cases demonstrating their significance.

---

## Managing Resource Replacements with `create_before_destroy`

Terraform by default follows a destroy-then-create strategy for resources marked for replacement. In scenarios where this behaviour causes dependency violations—such as with AWS security groups attached to EC2 instances—engineers must override this logic using `create_before_destroy`.

### Scenario

An AWS EC2 instance references a security group. Upon renaming the security group, Terraform attempts to destroy the original group before creating the new one. Since the EC2 instance still depends on the old security group, this action fails with a dependency violation.

### Solution

By applying the following lifecycle directive:

```hcl
lifecycle {
  create_before_destroy = true
}
```

Terraform alters the plan to create the new security group first, reassign it to the EC2 instance, and only then destroy the obsolete one—preserving system continuity.

### Visualising the Difference

```text
# Default Behaviour:
Destroy (old SG) → Create (new SG) ❌ Dependency Error

# With Lifecycle Override:
Create (new SG) → Attach → Destroy (old SG) ✅ No Downtime
```

---

## Protecting Critical Resources with `prevent_destroy`

`prevent_destroy` is a lifecycle directive that blocks the destruction of a resource—even when explicitly invoked. This is crucial for resources containing persistent or production-critical data (e.g., RDS, S3 buckets, long-lived compute instances).

### Example Use Case

When added to a resource block:

```hcl
lifecycle {
  create_before_destroy = true
  prevent_destroy       = true
}
```

Terraform will raise an error during `terraform destroy` or if the resource is otherwise targeted for deletion:

```text
Error: Instance cannot be destroyed
Resource aws_security_group.main has lifecycle.prevent_destroy set.
```

---

## Real-World Use Case

Imagine a production environment where a security group controls traffic to multiple application servers. During an update to the group name or configuration, Terraform’s default behaviour could interrupt live services by first deleting the group.

Using `create_before_destroy`, the new security group is provisioned before the old one is removed, ensuring uninterrupted access. Additionally, using `prevent_destroy` on stateful resources like RDS instances guards against irreversible data loss.

These lifecycle controls reflect operational maturity and are essential for production-grade infrastructure automation.

---

## Skills Demonstrated

- Application of Terraform lifecycle directives to real infrastructure challenges
- Avoidance of dependency conflicts during replacement
- Infrastructure protection against accidental data loss
- Implementation of resilient and production-safe IaC workflows

---

## Conclusion

Terraform’s lifecycle configuration allows engineers to override the default execution plan where necessary. `create_before_destroy` ensures uninterrupted transitions between resources, and `prevent_destroy` serves as a fail-safe against accidental deletions.

Mastery of these features is critical in high-availability and production-sensitive deployments.

These mechanisms reinforce Terraform’s role not just as a declarative tool, but as a precise and controllable infrastructure automation platform for modern DevOps workflows.

---
