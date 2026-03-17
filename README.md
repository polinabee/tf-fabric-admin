# Terraform Module: Microsoft Fabric Workspace Management

This repository provides a Terraform module to create and manage Microsoft Fabric workspaces and workspace role assignments.

## Features

- Creates or updates Fabric workspaces with the `microsoft/fabric` provider.
- Assigns workspace roles for four role types:
	- `Admin`
	- `Member`
	- `Contributor`
	- `Viewer`
- Supports principal resolution for role assignments:
	- `User`: by `id` or `upn`/email
	- `Group`: by `id` or group email alias lookup
	- `ServicePrincipal`: by `id`
	- `ServicePrincipalProfile`: by `id`
- Applies deterministic workspace naming and lowercases names automatically.
- Appends a default description postscript:
	- `"{workspace-name} created by Terraform."`
- Supports capacity assignment modes:
	- `best_effort` (skip capacity attachment during workspace create)
	- `strict` (attempt capacity attachment)
- Exposes diagnostics outputs for desired vs actual names and role assignment counts.

## Naming Convention

Workspace names are generated from:

`{department}-{team}-{project-name}-{env}`

Rules:

- Lowercase enforced.
- Non-alphanumeric separators in `project_name` are normalized.
- `project_name` is rendered in kebab-case.

Example:

- `department = "Data"`
- `team = "Platform"`
- `project_name = "Analytics Workspace"`
- `env = "dev"`

Result:

- `data-platform-analytics-workspace-dev`

## Authentication

`auth_mode` supports:

- `user`: use Azure CLI context (`az login`)
- `service_principal`: use `service_principal_info.app_id` and `service_principal_info.secret`

Both require `tenant_id`.

## Input Model

Workspace definitions are loaded from a JSON file path provided by `workspaces_file`.

Each workspace object includes:

- `project_name`
- `description` (optional)
- `env` (`dev`, `test`, `prod`, `sta`)
- `department`
- `team`
- `contacts` (optional)
- `capacity` (optional)
- `access` with role buckets (`admins`, `members`, `contributors`, `viewers`)

Recommended principal object shape in `access` arrays:

```json
{
	"type": "User",
	"upn": "user@contoso.com"
}
```

```json
{
	"type": "Group",
	"upn": "group@contoso.com"
}
```

```json
{
	"type": "ServicePrincipal",
	"id": "00000000-0000-0000-0000-000000000000"
}
```

## Usage

1. Configure input values in `terraform.tfvars`.
2. Provide a workspace definition JSON file and point `workspaces_file` to it.
3. Run Terraform from your execution environment:

```bash
terraform init -upgrade
terraform validate
terraform plan
terraform apply
```

## Key Variables

- `tenant_id`
- `auth_mode`
- `service_principal_info`
- `workspaces_file`
- `capacity_assignment_mode`

## Outputs

- `workspace_names`
- `workspace_ids`
- `workspace_source_file`
- `workspace_name_diagnostics`
- `capacity_assignment_notes`
- `workspace_role_assignments_reported_by_fabric`

These outputs are intended to make troubleshooting straightforward in CI or remote VM execution contexts.