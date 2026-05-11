resource "google_dataplex_entry" "metadata_aspects" {
  for_each = local.processed_rules

  project        = var.spoke_project
  location       = var.location
  entry_group_id = "@bigquery"
  
  entry_id   = "bigquery.googleapis.com/projects/${var.spoke_project}/datasets/tpc_h_prod_iac_${var.environment}/tables/${each.value.target_table}"
  
  # 1. FIXED: We are now using the hub_project_number to pass the strict Terraform validation!
  entry_type = "projects/${var.hub_project_number}/locations/${var.location}/entryTypes/table"

  # 2. ASPECT ATTACHMENT
  aspects {
    aspect_key = "${var.hub_project_number}.${var.location}.business-rule-v1-${var.environment}"
    aspect {
      data = jsonencode({
        rule_id     = each.key
        name        = each.value.name
        description = each.value.description
        sql_formula = each.value.sql_formula
        status      = each.value.status
      })
    }
  }

  # 3. Tell Terraform NOT to touch the system-managed parts of the auto-discovered BigQuery table
  lifecycle {
    ignore_changes = [entry_type, entry_source, parent_entry]
  }
}

# 4. Use an import block to pull the existing auto-discovered BigQuery entries into our state!
import {
  for_each = local.processed_rules
  to       = google_dataplex_entry.metadata_aspects[each.key]
  id       = "projects/${var.spoke_project}/locations/${var.location}/entryGroups/@bigquery/entries/bigquery.googleapis.com/projects/${var.spoke_project}/datasets/tpc_h_prod_iac_${var.environment}/tables/${each.value.target_table}"
}