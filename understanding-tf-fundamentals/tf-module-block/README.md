# Terraform Module Block

## Overview

This lab demonstrates the use of **Terraform modules** to improve infrastructure scalability, reusability, and maintainability. Modules in Terraform encapsulate related resources into logical groupings, allowing infrastructure engineers to abstract repeated patterns and deploy consistent environments across development, staging, and production with minimal code duplication.

Modules are called by a `parent` or `root` module, and any modules called by the parent module are known as `child` modules. They can be sourced from a number of different locations, including remote registries or locally within a folder structure. While not required, local modules are commonly stored inside a `modules/` directory for clarity and consistency.

```plaintext
aws-architecture-root/
├── main.tf
├── variables.tf
├── outputs.tf
└── modules/
    ├── vpc_module/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── subnet_module/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

- The **root module** (top-level directory) manages global composition and invokes reusable **child modules**.
- Each child module (e.g., `vpc_module`, `subnet_module`) encapsulates its own set of Terraform files to isolate concerns and improve portability.
- This structure adheres to Terraform best practices for modularisation.

---

## Syntax

```hcl
module "<MODULE_NAME>" {
  source = <MODULE_SOURCE>
  <INPUT_NAME> = <VALUE>
  <INPUT_NAME> = <VALUE>
}
```

---

## Using a Remote Module

The following module block demonstrates how to consume a remote module from the Terraform Registry to dynamically calculate subnet CIDR ranges:

```hcl
module "subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "1.0.0"

  base_cidr_block = "10.0.0.0/22"
  networks = [
    {
      name     = "module_network_a"
      new_bits = 2
    },
    {
      name     = "module_network_b"
      new_bits = 2
    },
  ]
}

output "subnet_addrs" {
  value = module.subnet_addrs.network_cidr_blocks
}
```

---

### Terraform Init Output

```bash
$ terraform init
Initializing modules...
Downloading hashicorp/subnets/cidr 1.0.0 for subnet_addrs...
- subnet_addrs in .terraform/modules/subnet_addrs
...
Terraform has been successfully initialized!
```

### Terraform Apply Output

```bash
$ terraform apply -auto-approve
...
Outputs:

subnet_addrs = tomap({
  "module_network_a" = "10.0.0.0/24"
  "module_network_b" = "10.0.1.0/24"
})
```

---

## Real-World Value

This lab exemplifies how modules can be used to:

- Break complex infrastructure into smaller, manageable, reusable units.
- Increase collaboration between teams by creating a clear contract between modules.
- Simplify the creation of production-grade infrastructure that is portable and versionable.
- Reduce cognitive load by reusing trusted patterns, thus reducing the chance of configuration errors.

Additionally, the folder structure clearly demonstrates modular decomposition of infrastructure. Each component  (VPC, subnets, and supporting logic) is neatly separated, supporting better team collaboration and CI/CD integration.

---

## Conclusion

Terraform modules are the cornerstone of building clean, scalable, and production-ready infrastructure-as-code architectures. This lab not only demonstrated module creation and consumption but also reinforced the principle of DRY (Don't Repeat Yourself) and the importance of reusability in modern cloud operations. By using both local and remote modules, this project aims to reflect real-world implementation patterns and prepares infrastructure for long-term maintenance and scale.

---
