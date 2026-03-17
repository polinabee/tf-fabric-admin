variable "subscription_id" {
  description = "Azure subscription ID. Not required by the Fabric or AzureAD providers but kept for potential azurerm/data-source use."
  type        = string
  default     = null
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID for authentication."
  type        = string
}

variable "auth_mode" {
  description = "Authentication mode. Use 'user' for Azure CLI logged-in user or 'service_principal' to use app_id/secret."
  type        = string
  default     = "user"

  validation {
    condition     = contains(["user", "service_principal"], var.auth_mode)
    error_message = "auth_mode must be either 'user' or 'service_principal'."
  }
}

variable "service_principal_info" {
  description = "Service principal credentials, required when auth_mode is service_principal."
  type = object({
    name   = optional(string)
    app_id = optional(string)
    secret = optional(string)
  })
  default = {}

  validation {
    condition = var.auth_mode != "service_principal" || (
      try(length(trim(var.service_principal_info.app_id)) > 0, false) &&
      try(length(trim(var.service_principal_info.secret)) > 0, false)
    )
    error_message = "When auth_mode is 'service_principal', service_principal_info.app_id and service_principal_info.secret are required."
  }
}

variable "workspaces_file" {
  description = "Path to the JSON file containing workspace definitions. Resolved relative to the module root."
  type        = string
  default     = "workspaces.json"
}

variable "capacity_assignment_mode" {
  description = "Capacity assignment behavior: 'best_effort' skips assignment during workspace creation (never fails apply), 'strict' attempts assignment via capacity_id (may fail if caller is not capacity admin)."
  type        = string
  default     = "best_effort"

  validation {
    condition     = contains(["best_effort", "strict"], var.capacity_assignment_mode)
    error_message = "capacity_assignment_mode must be either 'best_effort' or 'strict'."
  }
}
