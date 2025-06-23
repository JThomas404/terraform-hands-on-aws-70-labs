# Terraform Cloud - Workspaces

## Overview

This documentation provides a detailed account of the Terraform Cloud Workspaces lab, capturing the purpose, design decisions, and implementation logic for hiring managers and cloud engineers. Terraform Cloud workspaces act as managed units of infrastructure, building upon the CLI workspace construct by introducing remote state storage, team-based access control, version control integration, and policy enforcement. Each workspace encapsulates separate state data and is capable of remote execution, environment-specific configuration, and automation triggers.

---

## Workspace Features and Governance

### Workspace Dashboard

The workspace landing page provides a summary of active infrastructure, including resource count, last update status, Terraform version, and cost changes. It enables:

- Historical log inspection via the **Runs** tab
- Action-triggering capabilities (e.g. lock workspace, queue runs)
- Display of outputs and current resources
- Tag-based workspace filtering for improved visibility and organisation

### Remote vs. Local Execution

Terraform operations (`plan`, `apply`) can run in the Terraform Cloud environment using the `remote` backend. This standardises execution, provides auditability, and ensures logs are centralised and accessible.

Execution mode can be set to `remote` or `local` per workspace, allowing flexibility in CI/CD pipelines or manual CLI use.

### Terraform Version Control

Each workspace supports independent Terraform version selection. This allows safe testing of infrastructure against specific versions (e.g. `1.1.2` for dev, `1.0.11` for prod), decoupling host dependencies.

**Versioning Rationale**:

- The development workspace (`devops-aws-myapp-dev`) uses Terraform 1.1.2 to validate newer features and syntax changes while isolating potential instability.
- The production workspace (`devops-aws-myapp-prod`) remains on 1.0.11 for stability and backward compatibility with previously deployed infrastructure modules.

This controlled versioning supports staged rollouts and safe upgrades.

### Team-Based Access Control

Workspaces allow fine-grained team-level access policies with standard or custom roles. Permissions include `read`, `plan`, `write`, and `admin`, aligning with enterprise access control strategies.

### Notification Channels

Event-based notifications can be configured to email, Slack, or webhook targets. These alert stakeholders on key events (e.g. approval required, apply success/failure), supporting operational observability.

### Workflow Integration Options

Three workflow models are available:

- **CLI**: Manual trigger via standard Terraform commands
- **VCS**: Automated plan/apply via Git commits (recommended for production)
- **API**: Custom integrations for CI/CD pipelines (e.g. Jenkins)

---

## Workspace Naming and Separation

Workspaces are named using a standardised convention for consistency and scalability:
`<team>-<cloud>-<app>-<environment>`

For example:

- `devops-aws-myapp-dev`
- `devops-aws-myapp-prod`

This naming scheme improves navigation, tagging, and automation filtering.

---

## Environment-Specific Workspaces and Variables

Separate workspaces were created to support environment isolation:

- **DEV**: `devops-aws-myapp-dev`
- **PROD**: `devops-aws-myapp-prod`

Each workspace includes:

- `aws_region` (e.g. `us-east-1`)
- `vpc_name` (e.g. `dev_vpc`, `prod_vpc`)
- `environment` (e.g. `dev`, `prod`)

AWS credentials were applied via secure variable sets.

Terraform versions were pinned uniquely:

- DEV: `1.1.2`
- PROD: `1.0.11`

---

## Deployment and State Selection via Partial Backend Configuration

Partial backend configurations allow the same codebase to deploy to multiple workspaces.

`dev.hcl`:

```hcl
workspaces { name = "devops-aws-myapp-dev" }
```

`prod.hcl`:

```hcl
workspaces { name = "devops-aws-myapp-prod" }
```

### Code Comments for Clarity

```bash
# Initialise Terraform in the dev workspace using partial configuration
terraform init -backend-config=dev.hcl -reconfigure

# Preview planned changes for dev
terraform plan

# Apply infrastructure changes in dev
terraform apply
```

```bash
# Initialise Terraform in the prod workspace
terraform init -backend-config=prod.hcl -reconfigure

# Preview and apply changes in production
terraform plan
terraform apply
```

State separation is maintained per environment, and the Terraform Cloud interface allows detailed inspection of each run and its outputs.

---

## Infrastructure Destruction (Cleanup)

From the Terraform Cloud dashboard:

- Navigate to `Settings > Destruction and Deletion`
- Select `Queue destroy plan`

This queues a destruction run that follows the same approval workflow and logs the action for traceability.

> ⚠️ Avoid deleting the workspace itself, as future labs will re-use them for VCS automation workflows.

---

## Design Considerations: Workspace Usage

A workspace should contain all infrastructure that logically belongs together and should be managed as a single unit. Teams must consider:

- Who manages the resources
- How frequently they change
- Whether they depend on other teams or external data

Examples include:

- Self-contained stacks for dev/test environments
- Core shared services (e.g. networking)
- Platform services (e.g. Kubernetes clusters)

---

## Skills Demonstrated

- Separation of infrastructure by environment (dev/prod)
- Workspace tagging and naming best practices
- Use of partial backend configuration for workspace targeting
- Terraform Cloud remote execution and log inspection
- Version control and team permission assignment
- Secure variable management and environment-specific deployment
- Notification and VCS/API integration overview

---

## Real-World Use Cases

In enterprise environments, infrastructure changes often differ by environment. This lab simulates real-world scenarios such as:

1. **Financial Services Workflow**:

   - Developers push changes to the dev workspace via CLI
   - After validation, CI triggers the prod workspace using pipeline-configured backend
   - Logs and plans are reviewed centrally

2. **Kubernetes Infrastructure Isolation**:

   - A platform engineering team manages a workspace for shared Kubernetes clusters
   - App teams consume workspace outputs to deploy microservices with cross-workspace references

3. **Cloud Centre of Excellence Model**:

   - Each cloud team (e.g. AWS, Azure) uses workspaces to test platform modules before releasing to business units

These scenarios demonstrate scalable infrastructure governance, modularity, and controlled rollout.

---

## Conclusion

This lab showcases how Terraform Cloud workspaces offer environment separation, secure state handling, access governance, and extensibility via workflows. The use of partial backend configuration, variable management, and execution logs make workspaces an enterprise-grade solution for collaborative infrastructure automation.

This documentation serves to evidence practical skill in:

- Infrastructure lifecycle automation
- State management
- Environment-aware deployment pipelines
- Secure and observable Terraform operations

---
