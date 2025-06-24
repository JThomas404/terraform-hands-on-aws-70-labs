# Terraform Hands-On AWS – 70+ Labs

## Table of Contents

- [Overview](#overview)
- [Real-World Business Value](#real-world-business-value)
- [Project Folder Structure](#project-folder-structure)
- [Conclusion](#conclusion)

---

## Overview

This repository contains over 70 hands-on Terraform labs completed as part of the **"Master the Terraform Associate with 70+ AWS-Based Labs"** course. These labs are aligned with the **Terraform Associate 003 exam objectives** and use Amazon Web Services (AWS) as the primary cloud platform.

Each lab is implemented within its own directory, accompanied by individual documentation (e.g. `README.md`), code, and assets. The goal of this repository is to capture applied infrastructure-as-code (IaC) expertise using Terraform, with emphasis on security, clarity, version control, and modular architecture.

---

## Real-World Business Value

This project mirrors how cloud engineers operate in professional settings to provision, manage, and secure cloud infrastructure. By leveraging Terraform across isolated AWS-based scenarios, this body of work demonstrates how automation, modular design, and stateful configuration improve deployment consistency and reduce human error.

Key outcomes reflected in these labs include:

- Reduced manual provisioning through declarative automation
- Controlled infrastructure changes via versioned code and remote state
- Security-focused variable handling using Terraform Cloud
- Reusable modules and components for multi-environment consistency

---

## Project Folder Structure

```
terraform-hands-on-aws-70-labs/
├── README.md
├── benefits-of-iac
│   ├── images/
│   ├── README.md
│   └── terraform/
├── benefits-of-state
│   ├── images/
│   ├── README.md
│   └── terraform/
├── hcp-tf-capabilities/
│   ├── remote-state/
│   ├── secure-variables/
│   ├── sentinel-policy/
│   ├── tfc-getting-started/
│   └── workspaces/
├── read-generate-and-modify-configuration/
│   ├── dynamic-blocks/
│   ├── input-variables/
│   ├── local-variables/
│   ├── secure-secrets-in-tf-code/
│   ├── tf-built-in-functions/
│   ├── tf-graph/
│   ├── tf-outputs/
│   ├── tf-resource-lifecycles/
│   ├── variable-collection-and-structure-types/
│   ├── variable-validation-and-suppression/
│   └── working-with-data-blocks/
├── tf-modules/
│   ├── inputs-and-outputs/
│   ├── local-modules/
│   ├── public-registry/
│   ├── scope/
│   ├── sources/
│   └── versioning/
├── tf-outside-of-core-workflow/
│   ├── debugging-tf/
│   ├── tf-state-cli/
│   └── tf-workspaces-oss/
└── understanding-tf-fundamentals/
    ├── ssh-keys-tf-tls-provider/
    ├── tf-basics/
    ├── tf-configuration-block/
    ├── tf-data-block/
    ├── tf-input-variables-block/
    ├── tf-local-variables-block/
    ├── tf-module-block/
    ├── tf-multiple-providers/
    ├── tf-output-block/
    ├── tf-provider-block/
    ├── tf-provider-installation-and-versioning/
    ├── tf-provisioners/
    └── tf-resource-block/

50 directories, 3 files
```

Each folder represents a thematic grouping of labs, tied to specific Terraform capabilities or workflows.

---

## Conclusion

This repository represents a comprehensive, applied walkthrough of Terraform's capabilities on AWS. It documents not only the technical implementation of each lab, but also the rationale behind key infrastructure decisions, module design, state handling, and environment management.

The content reflects real-world proficiency in IaC, with a strong emphasis on reliability, security, and repeatability across environments.

Special thanks to Bryan and Gabe, official HashiCorp Ambassadors, for delivering the course that inspired and supported this work. Their instruction was instrumental in building my practical Terraform expertise. I highly recommend their course to anyone seeking to deepen their infrastructure automation skills:
[Terraform Hands-On Course](https://www.udemy.com/course/terraform-hands-on-labs)

---
