# Terraform Azure Security Lab

A hands-on Azure security environment built entirely with Terraform.

## What This Project Builds

- Resource group
- Virtual network
- Subnet
- Network Security Group
- HTTPS inbound rule
- Log Analytics workspace
- Azure Key Vault
- Key Vault diagnostic settings
- Linux App Service Plan
- Linux Web App
- System-assigned managed identity
- Azure RBAC role assignments
- Key Vault secret
- App Service Key Vault reference

## Security Controls

### Managed Identity

The Web App uses a system-assigned managed identity instead of a stored username, password, or client secret.

### Least-Privilege RBAC

The Web App is assigned the `Key Vault Secrets User` role at the Key Vault scope.

The signed-in deployment account uses `Key Vault Secrets Officer` only to manage the lab secret.

### Secure Secret Access

The Web App stores a Key Vault reference rather than the secret value directly in its app settings.

### Network Security

The subnet is protected by a Network Security Group with an inbound HTTPS rule.

### Centralised Monitoring

Key Vault audit logs are sent to Log Analytics through an Azure diagnostic setting.

## Terraform Workflow

```text
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
