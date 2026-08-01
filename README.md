# Terraform Azure Security Lab

A hands-on Azure security environment deployed using Terraform.

## What This Project Builds

- Resource group
- Virtual network and subnet
- Network Security Group with HTTPS inbound rule
- Storage account
- Log Analytics workspace
- Azure Key Vault and secret
- Linux App Service Plan
- Linux Web App
- System-assigned managed identity
- Azure RBAC role assignments
- Key Vault reference in App Service
- Key Vault diagnostic settings
- App Service diagnostic settings
- Azure Policy assignment

## Architecture

```text
Azure Resource Group
├── Virtual Network
│   └── Subnet
│       └── Network Security Group
├── Storage Account
├── Log Analytics Workspace
├── Key Vault
│   └── Secret
├── Linux App Service Plan
│   └── Linux Web App
│       ├── Managed Identity
│       └── Key Vault Reference
├── RBAC Role Assignments
├── Diagnostic Settings
│   ├── Key Vault → Log Analytics
│   └── Web App → Log Analytics
└── Azure Policy
    └── Allowed location: Australia East
```

## Security Controls

### Managed Identity

The Web App uses a system-assigned managed identity instead of stored usernames, passwords, or client secrets.

### Least-Privilege RBAC

The Web App is assigned the `Key Vault Secrets User` role at the Key Vault scope.

The deployment account uses `Key Vault Secrets Officer` to manage the lab secret.

### Secure Secret Access

The Web App stores a Key Vault reference rather than storing the secret value directly in its application settings.

The Key Vault reference was verified with the status:

```text
Resolved
```

### Network Security

The subnet is protected by a Network Security Group containing an inbound HTTPS rule.

### Centralised Monitoring

Key Vault and App Service diagnostic logs are sent to Log Analytics.

The App Service diagnostic setting collects:

- HTTP logs
- Console logs
- Application logs
- Audit logs
- IP security audit logs
- Platform logs
- Authentication logs
- Performance metrics

HTTP requests were generated against the Web App and successfully confirmed in the `AppServiceHTTPLogs` table using KQL.

### Azure Policy

Microsoft's built-in `Allowed locations` policy is assigned to the lab resource group.

The policy uses the `Deny` effect to prevent regional resources from being deployed outside Australia East.

The policy was tested by validating a storage account deployment in West US. Azure correctly returned:

```text
RequestDisallowedByPolicy
```

## Terraform Concepts Demonstrated

- Resources and data sources
- Variables and outputs
- Local values
- Resource references and dependencies
- `for_each`
- Dynamic blocks
- Managed identities
- Azure RBAC
- Diagnostic settings
- Azure Policy
- Terraform state protection

## Terraform Workflow

```powershell
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

## Project Files

```text
.
├── diagnostics.tf
├── keyvault.tf
├── monitoring.tf
├── network.tf
├── outputs.tf
├── policy.tf
├── policy-test.json
├── providers.tf
├── rbac.tf
├── storage.tf
├── variables.tf
├── webapp.tf
├── .gitignore
└── README.md
```

## Sensitive Files

The following files are excluded from Git:

```text
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
*.tfplan
crash.log
```

Terraform state may contain sensitive infrastructure information and must not be committed to GitHub.

## Future Improvements

- Move Terraform state to Azure Storage
- Enable remote state locking
- Refactor resources into reusable modules
- Demonstrate importing existing resources
- Add lifecycle rules
- Add automated validation with GitHub Actions