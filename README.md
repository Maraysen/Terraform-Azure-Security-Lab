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
- `count`
- Conditional expressions
- Managed identities
- Azure RBAC
- Diagnostic settings
- Azure Policy
- Remote Terraform state
- State locking
- Reusable modules
- Terraform import
- Lifecycle rules

## Remote State

Terraform state is stored in a private Azure Storage container using Microsoft Entra authentication.

The backend uses:

- A separate resource group for Terraform state
- A private Azure Storage account
- A blob container named `tfstate`
- Azure Blob state locking
- Microsoft Entra authentication instead of storage account keys

The active state file is stored as:

```text
tfstate/azure-security-lab.tfstate
```

## Reusable Network Module

The networking resources were moved into:

```text
modules/network/
```

The module creates:

- Virtual network
- Subnet
- Network Security Group
- Subnet and NSG association

Existing Azure resources were preserved by moving their Terraform state addresses with:

```powershell
terraform state mv
```

This allowed the resources to move into the module without being destroyed or recreated.

## Terraform Import

A resource group created outside Terraform was imported into Terraform state.

```powershell
terraform import
```

This demonstrated how Terraform can take ownership of an existing Azure resource without recreating it.

## Lifecycle Protection

The Key Vault uses lifecycle protection:

```hcl
lifecycle {
  prevent_destroy = true

  ignore_changes = [
    tags
  ]
}
```

- `prevent_destroy` protects the Key Vault from accidental destruction through Terraform.
- `ignore_changes` prevents Terraform from reversing tag changes managed outside Terraform.

## Conditional Resources

An optional backup storage account demonstrates `count` and conditional expressions:

```hcl
count = var.create_backup_storage ? 1 : 0
```

When the variable is `true`, Terraform creates one backup storage account.

When the variable is `false`, Terraform creates zero backup storage accounts.

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
├── backend.tf
├── diagnostics.tf
├── import-demo.tf
├── keyvault.tf
├── monitoring.tf
├── network-module.tf
├── network.tf
├── outputs.tf
├── policy.tf
├── policy-test.json
├── providers.tf
├── rbac.tf
├── storage.tf
├── variables.tf
├── webapp.tf
├── modules/
│   └── network/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
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

- Add automated Terraform validation with GitHub Actions
- Add multiple environment configurations for development and production
- Add private endpoints for Key Vault and Storage
- Add Azure Firewall or Web Application Firewall
- Add security scanning with tools such as Checkov or Trivy