# The Engine ONLY creates the data entries and attaches them to existing infra
resource "google_dataplex_entry" "metadata_aspects" {
  for_each = local.processed_rules

  project        = var.hub_project
  location       = var.location
  
  # Pointing to the infrastructure that WILL exist
  entry_group_id = "metadata-engine-group"
  entry_id       = "metadata_${each.key}"
  entry_type     = "projects/${var.hub_project_number}/locations/${var.location}/entryTypes/table"

  aspects {
    aspect_key = "${var.hub_project_number}.${var.location}.business-rule-v1"

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
}