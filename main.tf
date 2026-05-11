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

# 3. NEW: Create the Aspect Type (The metadata template blueprint)
resource "google_dataplex_aspect_type" "business_rule_type" {
  project        = var.hub_project
  location       = var.location
  aspect_type_id = "business-rule-v1"
  description    = "Template for Data Quality Business Rules"
  display_name   = "Business Rule Template"
}

# 4. Create the Entries (Attaching the metadata)
resource "google_dataplex_entry" "metadata_aspects" {
  for_each = local.processed_rules

  project        = var.hub_project
  location       = var.location
  entry_group_id = google_dataplex_entry_group.engine_group.entry_group_id
  entry_id       = "metadata_${each.key}"
  
  # Links to the Entry Type blueprint from Step 2
  entry_type     = "projects/${var.hub_project_number}/locations/${var.location}/entryTypes/${google_dataplex_entry_type.table_type.entry_type_id}"

  aspects {
    # Links to the Aspect Type blueprint from Step 3
    aspect_key = "${var.hub_project_number}.${var.location}.${google_dataplex_aspect_type.business_rule_type.aspect_type_id}"

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