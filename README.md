# Terraform Azure Security Lab

A hands-on Azure security environment deployed and managed using Terraform.

## Purpose

This project was created to practise building and securing Azure infrastructure with Terraform.

It focuses on:

* Infrastructure as Code
* Azure identity and access management
* Managed identities
* Azure Key Vault integration
* Centralised logging
* Azure Policy enforcement
* Remote Terraform state
* Terraform modules
* Resource imports
* Lifecycle protection
* Conditional resource deployment
* Safe Terraform state operations

## What This Project Builds

* Azure Resource Group
* Virtual Network and subnet
* Network Security Group with an inbound HTTPS rule
* Azure Storage Account
* Log Analytics Workspace
* Azure Key Vault and secret
* Linux App Service Plan
* Linux Web App
* System-assigned managed identity
* Azure RBAC role assignments
* Key Vault reference in App Service
* Key Vault diagnostic settings
* App Service diagnostic settings
* Azure Policy assignment
* Remote Terraform state backend

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

The Web App uses a system-assigned managed identity instead of stored usernames, passwords or client secrets.

The managed identity is used to authenticate to Azure Key Vault.

### Least-Privilege RBAC

The Web App managed identity is assigned the **Key Vault Secrets User** role at the Key Vault scope.

This allows the Web App to read secret values without granting unnecessary administrative permissions.

The deployment account uses the **Key Vault Secrets Officer** role to create and manage the lab secret.

### Secure Secret Access

The Web App application settings contain a Key Vault reference instead of storing the secret value directly.

The Key Vault reference was successfully verified with the status:

```text
Resolved
```

The secret value is marked as sensitive in Terraform.

Terraform state can still contain sensitive values and configuration information. For this reason, the remote state container is access-controlled and Terraform state files are excluded from Git.

### Network Security

The lab subnet is associated with a Network Security Group containing an inbound HTTPS rule.

The Linux Web App is an Azure App Service resource and is not directly hosted inside the lab subnet.

App Service VNet Integration was not configured as part of this phase.

The subnet NSG therefore applies to resources connected to the subnet, but it does not directly filter the Web App's public inbound traffic.

Additional controls such as the following would be required for private application connectivity:

* App Service VNet Integration
* App Service access restrictions
* Private endpoints
* Private DNS zones

### Centralised Monitoring

Key Vault and App Service diagnostic logs are sent to a Log Analytics Workspace.

The App Service diagnostic setting collects supported log categories including:

* HTTP logs
* Console logs
* Application logs
* Audit logs
* IP security audit logs
* Platform logs
* Authentication logs
* Performance metrics

HTTP requests were generated against the Web App and successfully confirmed in the `AppServiceHTTPLogs` table using KQL.

### Azure Policy

Microsoft's built-in **Allowed locations** policy is assigned to the lab resource group.

The policy uses the `Deny` effect to prevent supported regional resources from being deployed outside Australia East.

The policy was tested by attempting to validate a Storage Account deployment in West US.

Azure correctly returned:

```text
RequestDisallowedByPolicy
```

## Terraform Concepts Demonstrated

* Resources and data sources
* Input variables
* Output values
* Local values
* Resource references
* Implicit and explicit dependencies
* `for_each`
* Dynamic blocks
* `count`
* Conditional expressions
* Managed identities
* Azure RBAC
* Diagnostic settings
* Azure Policy
* Remote Terraform state
* Azure Blob state locking
* Reusable modules
* Terraform import
* Terraform state movement
* Lifecycle rules

## Remote State

Terraform state is stored in a non-public Azure Blob container using Microsoft Entra authentication.

The backend uses:

* A separate Resource Group for Terraform state
* A dedicated Azure Storage Account
* A Blob container named `tfstate`
* Azure Blob state locking
* Microsoft Entra authentication instead of Storage Account access keys

The active state file uses the backend key:

```text
azure-security-lab.tfstate
```

Inside the Storage Account, the state is stored in:

```text
tfstate/azure-security-lab.tfstate
```

Remote state allows Terraform operations to use a central state file rather than storing the active state only on a local machine.

## Reusable Network Module

The networking resources were moved into:

```text
modules/network/
```

The module creates:

* Virtual Network
* Subnet
* Network Security Group
* Subnet and NSG association

The existing Azure networking resources were preserved by moving their Terraform state addresses using:

```bash
terraform state mv
```

This allowed the resources to move into the module without being destroyed or recreated.

## Terraform Import

A Resource Group created outside Terraform was imported into Terraform state.

Terraform import demonstrated how Terraform can take ownership of an existing Azure resource without recreating it.

After importing the resource, the Terraform configuration was updated to match the existing Azure resource.

## Lifecycle Protection

The Key Vault uses Terraform lifecycle protection:

```hcl
lifecycle {
  prevent_destroy = true

  ignore_changes = [
    tags
  ]
}
```

### `prevent_destroy`

`prevent_destroy` protects the Key Vault from accidental deletion through Terraform.

Terraform rejects a plan that attempts to destroy the protected Key Vault unless the lifecycle rule is intentionally removed.

### `ignore_changes`

`ignore_changes` prevents Terraform from reversing changes to selected attributes that may be managed outside Terraform.

In this project, externally managed Key Vault tag changes are ignored.

## Conditional Resources

An optional backup Storage Account demonstrates `count` and conditional expressions:

```hcl
count = var.create_backup_storage ? 1 : 0
```

When the variable is set to `true`, Terraform creates one backup Storage Account.

When the variable is set to `false`, Terraform creates zero backup Storage Accounts.

Example variable:

```hcl
variable "create_backup_storage" {
  description = "Create an additional backup storage account"
  type        = bool
  default     = false
}
```

## Prerequisites

Before deploying this project, the following are required:

* Terraform
* Azure CLI
* An Azure subscription
* Permission to create Azure resources
* Permission to create Azure RBAC role assignments
* Access to the Terraform state Storage Account
* Access to the Terraform state Blob container
* Appropriate Key Vault data-plane permissions

## Authentication

Authenticate to Azure using the Azure CLI:

```bash
az login
```

Select the required Azure subscription:

```bash
az account set --subscription "<subscription-id>"
```

Confirm the active subscription:

```bash
az account show
```

Do not commit subscription IDs, tenant IDs, client IDs, passwords or secret values to the repository.

## Terraform Workflow

### 1. Initialise Terraform

```bash
terraform init
```

This downloads the required providers, initialises the modules and connects Terraform to the remote backend.

### 2. Format the configuration

```bash
terraform fmt -recursive
```

To check formatting without changing files:

```bash
terraform fmt -check -recursive
```

### 3. Validate the configuration

```bash
terraform validate
```

### 4. Review the execution plan

```bash
terraform plan
```

### 5. Deploy the infrastructure

```bash
terraform apply
```

### 6. Confirm the final state

After deployment, run another plan:

```bash
terraform plan
```

A completed and synchronised deployment should return:

```text
No changes. Your infrastructure matches the configuration.
```

## Validation Evidence

The following controls and Terraform operations were tested:

* The Web App successfully resolved its Key Vault reference
* The Web App accessed Key Vault using its managed identity
* The Web App managed identity received the Key Vault Secrets User role
* App Service HTTP requests appeared in Log Analytics
* Key Vault diagnostics were sent to Log Analytics
* A West US resource deployment was denied by Azure Policy
* Existing Azure resources were imported into Terraform state
* Networking resources were moved into a reusable module without recreation
* The optional backup Storage Account was tested using a conditional variable
* The Key Vault was protected with `prevent_destroy`
* Remote Terraform state was stored in Azure Blob Storage
* Microsoft Entra authentication was used for backend access
* Terraform state locking was provided by Azure Blob Storage
* The final Terraform plan returned no unexpected infrastructure changes

## Project Structure

```text
.
├── backend.tf
├── diagnostics.tf
├── import-demo.tf
├── keyvault.tf
├── monitoring.tf
├── network-module.tf
├── outputs.tf
├── policy.tf
├── policy-test.json
├── providers.tf
├── rbac.tf
├── resource-group.tf
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

The following files and directories are excluded from Git:

```text
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
*.tfplan
crash.log
```

Terraform state can contain:

* Resource identifiers
* Infrastructure configuration
* Secret values
* Access-related information
* Sensitive output values

Terraform state must therefore be treated as a protected asset and must not be committed to source control.

Local `.tfvars` files must also remain excluded when they contain environment-specific or sensitive values.

## Phase 3 Scope

This README documents the Terraform and Azure infrastructure work completed during Phase 3.

Phase 3 includes:

* Terraform configuration
* Azure resource deployment
* Security controls
* Remote state
* Modules
* Imports
* State movement
* Conditional resources
* Lifecycle rules
* Git workflow practice
* Infrastructure validation

The Azure DevOps deployment pipeline, security scanning, manual approval stage and automated Terraform apply process are part of Phase 4 and are not documented here.

## Future Infrastructure Improvements

* Configure App Service VNet Integration
* Add an App Service private endpoint
* Add private endpoints for Key Vault and Storage
* Configure private DNS zones
* Restrict public network access
* Add App Service access restrictions
* Add separate development and production configurations
* Add additional Azure Policy assignments
* Add resource locks for critical resources
* Add customer-managed encryption keys where appropriate
* Add Azure Firewall or Web Application Firewall
