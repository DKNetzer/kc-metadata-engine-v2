# 1. Create a custom Entry Group for our Metadata Engine
resource "google_dataplex_entry_group" "engine_group" {
  project          = var.hub_project
  location         = var.location
  entry_group_id   = "metadata-engine-group"
  description      = "Custom entry group managed by the KC Metadata Engine"
  display_name     = "Metadata Engine Group"
}

# 2. Create the Entries (Aspects) inside our custom group
resource "google_dataplex_entry" "metadata_aspects" {
  for_each = local.processed_rules

  project        = var.hub_project
  location       = var.location
  # We now point to our custom group instead of @bigquery
  entry_group_id = google_dataplex_entry_group.engine_group.entry_group_id
  
  # We name the entry after the rule so it's easy to find
  entry_id       = "metadata_${each.key}"
  
  # This tells Dataplex which BigQuery table this metadata belongs to
  entry_type     = "projects/${var.spoke_project}/locations/${var.location}/entryTypes/table"

  aspects {
    aspect_key = "business-rule-v1"
    aspect {
      # Use your specific aspect type ID here
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
}