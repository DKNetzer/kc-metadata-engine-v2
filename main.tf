# 1. Create a custom Entry Group
resource "google_dataplex_entry_group" "engine_group" {
  project          = var.hub_project
  location         = var.location
  entry_group_id   = "metadata-engine-group"
  description      = "Custom entry group managed by the KC Metadata Engine"
  display_name     = "Metadata Engine Group"
}

# 2. Create the Entries (Aspects)
resource "google_dataplex_entry" "metadata_aspects" {
  for_each = local.processed_rules

  project        = var.hub_project
  location       = var.location
  entry_group_id = google_dataplex_entry_group.engine_group.entry_group_id
  entry_id       = "metadata_${each.key}"
  
  # FIX: Uses project NUMBER for the type path
  entry_type     = "projects/${var.hub_project_number}/locations/${var.location}/entryTypes/table"

  # FIX: Flattened the aspects block (no nested 'aspect' block)
  aspects {
    # FIX: Aspect key must start with the project number
    aspect_type = "projects/${var.hub_project}/locations/${var.location}/aspectTypes/business-rule-v1"
    data = jsonencode({
      rule_id     = each.key
      name        = each.value.name
      description = each.value.description
      sql_formula = each.value.sql_formula
      status      = each.value.status
    })
  }
}
