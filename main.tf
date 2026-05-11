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
  
  # Requirement: Entry Type must use the Project Number
  entry_type     = "projects/${var.hub_project_number}/locations/${var.location}/entryTypes/table"

  # The "Aspects" block
  aspects {
    # Requirement: aspect_key MUST be in the format: project_number.location.aspect_type_id
    aspect_key = "${var.hub_project_number}.${var.location}.business-rule-v1"

    # Requirement: The actual data must be inside a nested "aspect" block
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