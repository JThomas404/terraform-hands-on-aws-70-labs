# Terraform Local Values

## Overview

This project focused on using **local values** in Terraform to improve configuration clarity, reduce duplication, and centralise reusable expressions. Local values (or `locals`) assign names to expressions, allowing them to be reused throughout the configuration. These values can reference variables, other locals, or resource attributes.

The goal of this hands-on lab was to demonstrate how locals can simplify tagging strategies and centralise configuration logic, all while maintaining readability and flexibility for future changes.

---

## Defining Local Values

To start, I defined a basic set of local values in the `main.tf` file:

```hcl
locals {
  service_name = "Automation"
  app_team     = "Cloud Team"
  createdby    = "terraform"
}
```

These locals provided metadata for tagging AWS resources. This approach allowed me to avoid repeating values and to easily update them from a central place.

---

## Applying Locals to Resource Definitions

Next, I applied the defined locals to the `tags` block of the EC2 instance resource:

```hcl
tags = {
  Service   = local.service_name
  AppTeam   = local.app_team
  CreatedBy = local.createdby
}
```

I verified the changes by running:

```bash
terraform plan
terraform apply
```

Terraform detected updates to the tags and applied them as expected.

---

## Enhancing Locals with Variables and Nested Locals

To demonstrate more advanced use, I created a `common_tags` local that referenced both input variables and previously defined local values:

```hcl
locals {
  common_tags = {
    Name      = var.server_name
    Owner     = local.team
    App       = local.application
    Service   = local.service_name
    AppTeam   = local.app_team
    CreatedBy = local.createdby
  }
}
```

I then updated the `tags` block in the EC2 resource to:

```hcl
tags = local.common_tags
```

Running `terraform plan` again showed:

```text
No changes. Infrastructure is up-to-date.
```

This confirmed that the configuration logic had been refactored using locals without altering the deployed infrastructure.

---

## Real-World Use Case

This pattern is especially useful in real-world projects where multiple resources require standardised tags or metadata. Locals simplify maintaining consistency across modules, reduce duplication, and enhance collaboration across teams.

In production scenarios, local values often help with:

- Standardising tags across environments
- Managing environment-specific metadata
- Supporting dynamic naming conventions

---

## Conclusion

This hands-on implementation reinforced the practical advantages of using local values in Terraform. I demonstrated how locals improve maintainability, simplify tagging, and support dynamic infrastructure configuration.

By using locals purposefully, I reduced repetition and improved the clarity of my Terraform code—skills essential to working in team environments and managing scalable cloud infrastructure efficiently.

---
