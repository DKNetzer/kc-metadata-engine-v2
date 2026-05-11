# 1. Create a custom Entry Group
resource "google_dataplex_entry_group" "engine_group" {
  project          = var.hub_project
  location         = var.location
  entry_group_id   = "metadata-engine-group"
  description      = "Custom entry group managed by the KC Metadata Engine"
  display_name     = "Metadata Engine Group"
}

# 2. Create the custom Entry Type ("table" blueprint)
resource "google_dataplex_entry_type" "table_type" {
  project       = var.hub_project
  location      = var.location
  entry_type_id = "table"
  description   = "Custom Entry Type for BigQuery Tables"
  display_name  = "Table"
}

# 3. Create the Entries (Aspects)
resource "google_dataplex_entry" "metadata_aspects" {
  for_each = local.processed_rules

  project        = var.hub_project
  location       = var.location
  entry_group_id = google_dataplex_entry_group.engine_group.entry_group_id
  entry_id       = "metadata_${each.key}"
  
  # FIX: We now point to the blueprint we just created above!
  entry_type     = google_dataplex_entry_type.table_type.id

  # The "Aspects" block
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