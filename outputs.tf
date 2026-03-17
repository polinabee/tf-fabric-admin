output "workspace_names" {
  description = "Created/managed Fabric workspace display names after sanitization."
  value       = { for k, ws in fabric_workspace.this : k => ws.display_name }
}

output "workspace_ids" {
  description = "Fabric workspace GUIDs."
  value       = { for k, ws in fabric_workspace.this : k => ws.id }
}

output "workspace_source_file" {
  description = "Workspace JSON file path used for this run."
  value       = var.workspaces_file
}

output "workspace_name_diagnostics" {
  description = "Per-workspace desired name vs provider-reported display name and role-assignment attempt counts."
  value = {
    for k, ws in local.normalized_workspaces : k => {
      desired_workspace_name = ws.workspace_name
      actual_display_name    = try(fabric_workspace.this[k].display_name, null)
      workspace_id           = try(fabric_workspace.this[k].id, null)
      role_assignments_requested = length([
        for ra in values(local.workspace_role_assignments) : ra
        if ra.workspace_key == k
      ])
      role_assignments_created = length([
        for ra_k, ra in fabric_workspace_role_assignment.this : ra_k
        if startswith(ra_k, "${k}|")
      ])
    }
  }
}

output "capacity_assignment_notes" {
  description = "Per-workspace note explaining whether capacity assignment was skipped (best_effort) or attempted (strict)."
  value = {
    for k, ws in local.normalized_workspaces : ws.workspace_name => (
      try(length(trimspace(ws.capacity)) > 0, false)
      ? (
        var.capacity_assignment_mode == "strict"
        ? "Capacity assignment requested and attempted in strict mode. If apply fails, ensure deployer is Capacity Admin on the target Fabric capacity."
        : "Capacity assignment requested but skipped in best_effort mode; workspace was created without capacity. Grant deployer Capacity Admin, then re-run with capacity_assignment_mode=\"strict\" to attach capacity."
      )
      : "No capacity requested."
    )
  }
}

output "workspace_role_assignments_reported_by_fabric" {
  description = "Role assignments returned by Fabric API for each workspace after apply."
  value = {
    for k, ds in data.fabric_workspace_role_assignments.actual : k => [
      for v in ds.values : {
        principal_id   = v.principal.id
        principal_type = v.principal.type
        role           = v.role
      }
    ]
  }
}
