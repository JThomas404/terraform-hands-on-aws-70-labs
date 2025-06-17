# Terraform Module Inputs and Outputs

## Overview

In this project lab, I explored how to make Terraform modules more flexible and reusable by implementing input variables and output values. Input variables allow users to configure modules with custom parameters, while output values enable modules to return key information back to the calling configuration. This approach improves module modularity, testability, and real-world applicability in complex infrastructure environments.

---

## Folder Structure

To keep the configuration organised, the project follows the structure below:

```
inputs-and-outputs/
├── main.tf
├── modules
│   ├── server
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── web_server
│       └── server.tf
├── README.md
├── terraform.tf
└── variables.tf
```

### Breakdown:

- `main.tf`: Root configuration where the module is called.
- `modules/server/main.tf`: Main logic for the EC2 instance.
- `modules/server/variables.tf`: Declares configurable input variables.
- `modules/server/outputs.tf`: Defines output values to be returned to the root module.

This structure promotes code modularity, clarity, and reusability.

---

## Input Variables in Modules

Variables in a module act like parameters that allow configuration from the calling module. These can be required or optional:

- **Required variables**: No default value defined, must be passed explicitly.
- **Optional variables**: Include default values and can be overridden.

Defined in `variables.tf` inside the module:

```hcl
variable "size" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}
```

This allows the root configuration to set or override values when calling the module.

---

## Outputs in Modules

Output values from a module allow other parts of the configuration to consume results from that module. Outputs are defined using `output` blocks inside `outputs.tf` and are referenced using the `module.<module_name>.<output_name>` syntax.

In `modules/server/outputs.tf`:

```hcl
output "public_ip" {
  description = "IP Address of server built with Server Module"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "DNS Address of server built with Server Module"
  value       = aws_instance.web.public_dns
}

output "size" {
  description = "Size of server built with Server Module"
  value       = aws_instance.web.instance_type
}
```

In the root module's `main.tf`, I referenced the module's output:

```hcl
output "size" {
  value = module.server.size
}
```

This demonstrates how values produced by the module can be surfaced at a higher level in the Terraform configuration.

---

## Running and Testing

I reinitialised Terraform and applied the changes to validate the inputs and outputs:

```bash
terraform init
terraform apply
```

I then verified outputs via the CLI or the Terraform state:

```bash
terraform output public_ip
```

This returned the actual IP address provisioned by the `server` module.

---

## Referencing Module Outputs

Outputs defined in the module can be referenced using:

```hcl
module.server.public_ip
```

This is useful for passing values between modules or dynamically configuring other resources. For example, referencing an instance IP to register it in a load balancer.

While both module and root outputs may share the same name (e.g. `public_ip`), they operate at different scopes:

- Module-level output: Pulls data from a resource inside the module
- Root-level output: Exposes the returned value from the module

---

## Real-World Use Cases

- Parameterising infrastructure templates to support different environments (e.g. dev, test, prod)
- Building shareable modules in public or private registries
- Returning sensitive or computed values to upstream systems
- Dynamically wiring resources together based on outputs from multiple modules

This mirrors how professional teams use Terraform to standardise and scale infrastructure provisioning.

---

## Conclusion

This project solidified my understanding of how input variables and output values enhance the flexibility and modularity of Terraform configurations. By encapsulating configuration logic and returning only essential values, modules can be reused across teams and environments with minimal duplication or error.

Key takeaways:

- Created input variables to parameterise modules
- Defined module outputs to pass back critical data
- Demonstrated the syntax and lifecycle of input/output use
- Reinforced infrastructure-as-code best practices through modular design

---
