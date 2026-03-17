locals {
  # Load workspaces from the JSON file and fill in optional field defaults so
  # downstream expressions don't need to guard every field with try().
  _workspaces_raw = jsondecode(file("${path.module}/${var.workspaces_file}"))

  workspaces = [
    for ws in local._workspaces_raw : merge({
      description = null
      contacts    = []
      capacity    = null
      access = {
        admins       = []
        contributors = []
        viewers      = []
        members      = []
      }
    }, ws)
  ]

  normalized_workspaces = {
    for ws in local.workspaces :
    join("-", [
      lower(join("", regexall("[0-9A-Za-z]+", ws.department))),
      lower(join("", regexall("[0-9A-Za-z]+", ws.team))),
      lower(join("-", regexall("[0-9A-Za-z]+", ws.project_name))),
      lower(ws.env)
      ]) => merge(ws, {
      env = lower(ws.env)
      workspace_name = join("-", [
        lower(join("", regexall("[0-9A-Za-z]+", ws.department))),
        lower(join("", regexall("[0-9A-Za-z]+", ws.team))),
        lower(join("-", regexall("[0-9A-Za-z]+", ws.project_name))),
        lower(ws.env)
      ])
    })
  }

  workspace_role_assignments = {
    for item in flatten([
      for ws_key, ws in local.normalized_workspaces : concat(
        [for p in try(ws.access.admins, []) : {
          key           = "${ws_key}|Admin|${coalesce(try(trimspace(p.id), null), try(lower(trimspace(p.upn)), null), try(lower(trimspace(p.email)), null), try(trimspace(tostring(p)), "unknown"))}"
          workspace_key = ws_key
          role          = "Admin"
          principal_type = try(trimspace(p.type), null) != null ? trimspace(p.type) : (
            contains(["User", "Group", "ServicePrincipal", "ServicePrincipalProfile"], try(element(split(":", tostring(p)), 0), "")) ? element(split(":", tostring(p)), 0) : (
              try(length(trimspace(p.upn)) > 0, false) || try(length(trimspace(p.email)) > 0, false) || length(regexall("@", try(tostring(p), ""))) > 0 ? "User" : "Group"
            )
          )
          principal_id = try(length(trimspace(p.id)) > 0, false) ? trimspace(p.id) : (
            contains(["User", "Group", "ServicePrincipal", "ServicePrincipalProfile"], try(element(split(":", tostring(p)), 0), "")) ? trimspace(element(split(":", tostring(p)), length(split(":", tostring(p))) - 1)) : null
          )
          principal_upn = try(length(trimspace(p.upn)) > 0, false) ? lower(trimspace(p.upn)) : (
            try(length(trimspace(p.email)) > 0, false) ? lower(trimspace(p.email)) : (
              length(regexall("@", try(tostring(p), ""))) > 0 ? lower(trimspace(tostring(p))) : null
            )
          )
        }],
        [for p in try(ws.access.members, []) : {
          key           = "${ws_key}|Member|${coalesce(try(trimspace(p.id), null), try(lower(trimspace(p.upn)), null), try(lower(trimspace(p.email)), null), try(trimspace(tostring(p)), "unknown"))}"
          workspace_key = ws_key
          role          = "Member"
          principal_type = try(trimspace(p.type), null) != null ? trimspace(p.type) : (
            contains(["User", "Group", "ServicePrincipal", "ServicePrincipalProfile"], try(element(split(":", tostring(p)), 0), "")) ? element(split(":", tostring(p)), 0) : (
              try(length(trimspace(p.upn)) > 0, false) || try(length(trimspace(p.email)) > 0, false) || length(regexall("@", try(tostring(p), ""))) > 0 ? "User" : "Group"
            )
          )
          principal_id = try(length(trimspace(p.id)) > 0, false) ? trimspace(p.id) : (
            contains(["User", "Group", "ServicePrincipal", "ServicePrincipalProfile"], try(element(split(":", tostring(p)), 0), "")) ? trimspace(element(split(":", tostring(p)), length(split(":", tostring(p))) - 1)) : null
          )
          principal_upn = try(length(trimspace(p.upn)) > 0, false) ? lower(trimspace(p.upn)) : (
            try(length(trimspace(p.email)) > 0, false) ? lower(trimspace(p.email)) : (
              length(regexall("@", try(tostring(p), ""))) > 0 ? lower(trimspace(tostring(p))) : null
            )
          )
        }],
        [for p in try(ws.access.contributors, []) : {
          key           = "${ws_key}|Contributor|${coalesce(try(trimspace(p.id), null), try(lower(trimspace(p.upn)), null), try(lower(trimspace(p.email)), null), try(trimspace(tostring(p)), "unknown"))}"
          workspace_key = ws_key
          role          = "Contributor"
          principal_type = try(trimspace(p.type), null) != null ? trimspace(p.type) : (
            contains(["User", "Group", "ServicePrincipal", "ServicePrincipalProfile"], try(element(split(":", tostring(p)), 0), "")) ? element(split(":", tostring(p)), 0) : (
              try(length(trimspace(p.upn)) > 0, false) || try(length(trimspace(p.email)) > 0, false) || length(regexall("@", try(tostring(p), ""))) > 0 ? "User" : "Group"
            )
          )
          principal_id = try(length(trimspace(p.id)) > 0, false) ? trimspace(p.id) : (
            contains(["User", "Group", "ServicePrincipal", "ServicePrincipalProfile"], try(element(split(":", tostring(p)), 0), "")) ? trimspace(element(split(":", tostring(p)), length(split(":", tostring(p))) - 1)) : null
          )
          principal_upn = try(length(trimspace(p.upn)) > 0, false) ? lower(trimspace(p.upn)) : (
            try(length(trimspace(p.email)) > 0, false) ? lower(trimspace(p.email)) : (
              length(regexall("@", try(tostring(p), ""))) > 0 ? lower(trimspace(tostring(p))) : null
            )
          )
        }],
        [for p in try(ws.access.viewers, []) : {
          key           = "${ws_key}|Viewer|${coalesce(try(trimspace(p.id), null), try(lower(trimspace(p.upn)), null), try(lower(trimspace(p.email)), null), try(trimspace(tostring(p)), "unknown"))}"
          workspace_key = ws_key
          role          = "Viewer"
          principal_type = try(trimspace(p.type), null) != null ? trimspace(p.type) : (
            contains(["User", "Group", "ServicePrincipal", "ServicePrincipalProfile"], try(element(split(":", tostring(p)), 0), "")) ? element(split(":", tostring(p)), 0) : (
              try(length(trimspace(p.upn)) > 0, false) || try(length(trimspace(p.email)) > 0, false) || length(regexall("@", try(tostring(p), ""))) > 0 ? "User" : "Group"
            )
          )
          principal_id = try(length(trimspace(p.id)) > 0, false) ? trimspace(p.id) : (
            contains(["User", "Group", "ServicePrincipal", "ServicePrincipalProfile"], try(element(split(":", tostring(p)), 0), "")) ? trimspace(element(split(":", tostring(p)), length(split(":", tostring(p))) - 1)) : null
          )
          principal_upn = try(length(trimspace(p.upn)) > 0, false) ? lower(trimspace(p.upn)) : (
            try(length(trimspace(p.email)) > 0, false) ? lower(trimspace(p.email)) : (
              length(regexall("@", try(tostring(p), ""))) > 0 ? lower(trimspace(tostring(p))) : null
            )
          )
        }]
      )
    ]) : item.key => item
  }

  users_needing_lookup = toset(distinct([
    for a in values(local.workspace_role_assignments) : a.principal_upn
    if a.principal_type == "User" && a.principal_id == null && a.principal_upn != null
  ]))

  groups_needing_lookup = toset(distinct([
    for a in values(local.workspace_role_assignments) : a.principal_upn
    if a.principal_type == "Group" && a.principal_id == null && a.principal_upn != null
  ]))
}

data "azuread_user" "resolved_user" {
  for_each            = local.users_needing_lookup
  user_principal_name = each.value
}

data "azuread_group" "resolved_group" {
  for_each = local.groups_needing_lookup

  # For mail-enabled groups, look up by alias portion of the group email.
  mail_nickname = split("@", each.value)[0]
}

resource "fabric_workspace" "this" {
  for_each = local.normalized_workspaces

  display_name = each.value.workspace_name
  description = trimspace(join(" ", compact([
    try(length(trimspace(each.value.description)) > 0, false) ? trimspace(each.value.description) : null,
    "${each.value.workspace_name} created by Terraform."
  ])))
  capacity_id = var.capacity_assignment_mode == "strict" && try(length(trimspace(each.value.capacity)) > 0, false) ? each.value.capacity : null

  lifecycle {
    precondition {
      condition     = contains(["dev", "test", "prod", "sta"], lower(each.value.env))
      error_message = "Workspace '${each.value.project_name}': env must be one of dev, test, prod, sta. Got: '${each.value.env}'."
    }
    precondition {
      condition     = length(regexall("[0-9A-Za-z]", each.value.project_name)) > 0
      error_message = "project_name must contain at least one alphanumeric character."
    }
  }
}

resource "fabric_workspace_role_assignment" "this" {
  for_each = local.workspace_role_assignments

  workspace_id = fabric_workspace.this[each.value.workspace_key].id
  role         = each.value.role
  principal = {
    id = coalesce(
      each.value.principal_id,
      try(data.azuread_user.resolved_user[each.value.principal_upn].object_id, null),
      try(data.azuread_user.resolved_user[each.value.principal_upn].id, null),
      try(data.azuread_group.resolved_group[each.value.principal_upn].object_id, null),
      try(data.azuread_group.resolved_group[each.value.principal_upn].id, null)
    )
    type = each.value.principal_type
  }

  lifecycle {
    precondition {
      condition     = contains(["Admin", "Member", "Contributor", "Viewer"], each.value.role)
      error_message = "Role must be one of: Admin, Member, Contributor, Viewer."
    }
    precondition {
      condition     = contains(["User", "Group", "ServicePrincipal", "ServicePrincipalProfile"], each.value.principal_type)
      error_message = "Principal type must be one of: User, Group, ServicePrincipal, ServicePrincipalProfile."
    }
    precondition {
      condition = each.value.principal_type == "User" ? (
        coalesce(
          each.value.principal_id,
          try(data.azuread_user.resolved_user[each.value.principal_upn].object_id, null),
          try(data.azuread_user.resolved_user[each.value.principal_upn].id, null)
        ) != null
        ) : each.value.principal_type == "Group" ? (
        coalesce(
          each.value.principal_id,
          try(data.azuread_group.resolved_group[each.value.principal_upn].object_id, null),
          try(data.azuread_group.resolved_group[each.value.principal_upn].id, null)
        ) != null
        ) : (
        each.value.principal_id != null && length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$", each.value.principal_id)) > 0
      )
      error_message = "For User principals, provide upn/email or id. For Group principals, provide id or a resolvable group email alias. For ServicePrincipal/ServicePrincipalProfile, provide a valid UUID in id."
    }
  }
}

data "fabric_workspace_role_assignments" "actual" {
  for_each = fabric_workspace.this

  workspace_id = each.value.id
}

