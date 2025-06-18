# Terraform Module Scope

## Overview

A well-scoped module is designed to do **one thing well**. It should be simple to explain and narrow in focus. Through this hands-on experience, I gained practical knowledge in evaluating and limiting the scope of Terraform child modules to avoid unnecessary complexity, promote reusability, and ensure clarity for collaborative teams.

---

## Exploring Resources Within a Child Module

A key takeaway was learning how to identify the appropriate granularity when designing modules. Overloading modules with too many responsibilities can reduce readability, introduce hidden dependencies, and increase maintenance overhead.

To explore this, I worked with the [`terraform-aws-autoscaling`](https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest) module from the Terraform Public Module Registry. This module was integrated into my root module to provision an EC2 Auto Scaling group:

```hcl
module "autoscaling" {
  source = "github.com/terraform-aws-modules/terraform-aws-autoscaling?ref=v8.3.0"

  name                 = "myasg"
  vpc_zone_identifier  = aws_subnet.tf_mastery_private.id
  min_size             = 0
  max_size             = 1
  desired_capacity     = 1
  image_id             = data.aws_ami.amazon_linux.id
  instance_type        = "t3.micro"
  instance_name        = "asg-instance"

  tags = {
    Name = "Web EC2 Server 2"
  }
}
```

After applying the configuration, I validated the resources provisioned by inspecting the Terraform state:

```bash
terraform state list
module.autoscaling.data.aws_default_tags.current
module.autoscaling.aws_autoscaling_group.this[0]
module.autoscaling.aws_launch_template.this[0]
```

This confirmed that the module had abstracted internal implementation details while remaining reusable. Despite supporting over 80 configurable inputs, only a minimal set of arguments was required, demonstrating thoughtful module design and a clean user interface.

---

## Scoping Inputs and Outputs Between Root and Child Modules

This project reinforced the architectural separation between root and child modules:

```
terraform/
├── main.tf           # Root module (entry point)
├── variables.tf      # Input variables for root
├── outputs.tf        # Outputs from child modules
├── modules/
│   └── server/
│       ├── server.tf     # EC2 instance resource
│       ├── variables.tf  # Input variables
│       └── outputs.tf    # Output values
```

**Root module responsibilities:**

- Declare required input variables
- Use `module` blocks to invoke child modules
- Reference outputs using `module.<name>.<output>` syntax

**Child module responsibilities:**

- Define provisioning logic
- Accept required variables
- Expose only necessary outputs

Example: Referencing the `autoscaling_group_max_size` output from the child module:

```hcl
output "asg_group_size" {
  value = module.autoscaling.autoscaling_group_max_size
}
```

Using `terraform console`, I confirmed the value returned:

```bash
terraform console
> module.autoscaling.autoscaling_group_max_size
```

---

## Best Practices Learned When Scoping Modules

Throughout the lab, I applied the following Terraform module design best practices:

- **Encapsulation:** Group only the resources that are logically deployed together.
- **Privilege Boundaries:** Keep resource ownership and permissions isolated to avoid cross-team conflicts.
- **Volatility Awareness:** Isolate long-lived infrastructure (e.g., databases) from frequently deployed components (e.g., app servers).
- **Minimal Interface:** Limit inputs to only the most commonly used variables to reduce cognitive load.
- **Avoid Edge Cases:** Avoid coding for rare exceptions within a module—prioritise general-purpose usage.
- **80% Rule:** Build modules that solve \~80% of use cases effectively. Let advanced usage be handled outside the module.

---

## Real-World Application

In production environments, Terraform modules form the foundation of reusable infrastructure. Platform teams design base modules (e.g., networking, compute, IAM), which are consumed by application teams with minimal configuration. This separation enables:

- Consistency across deployments
- Faster provisioning and reduced manual effort
- Improved security and governance

In this lab, I mirrored this workflow by using a published module, configuring a minimal set of inputs, and referencing key outputs to wire infrastructure together. This workflow aligns with scalable DevOps practices used in modern cloud engineering.

---

## Conclusion

This lab strengthened my understanding of Terraform module scope and design. I gained practical experience in:

- Creating focused, single-purpose modules
- Passing and referencing inputs and outputs
- Integrating open-source modules into root configurations

---
