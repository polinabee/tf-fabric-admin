# auth_mode = "user"              → client_id / client_secret stay null;
#                                   both providers fall back to the ambient
#                                   Azure CLI token (requires `az login`).
#
# auth_mode = "service_principal" → explicit credentials are used and no
#                                   CLI session is needed.

provider "fabric" {
  tenant_id     = var.tenant_id
  client_id     = var.auth_mode == "service_principal" ? var.service_principal_info.app_id : null
  client_secret = var.auth_mode == "service_principal" ? var.service_principal_info.secret : null
}

provider "azuread" {
  tenant_id     = var.tenant_id
  client_id     = var.auth_mode == "service_principal" ? var.service_principal_info.app_id : null
  client_secret = var.auth_mode == "service_principal" ? var.service_principal_info.secret : null
}
