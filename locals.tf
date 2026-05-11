locals {
  # 1. Read the raw YAML file from the neighboring repository
  raw_yaml_data = file("../kc-app-governance-v2/business_rules.yaml")

  # 2. Decode the YAML into a Terraform object
  decoded_yaml = yamldecode(local.raw_yaml_data)

  # 3. Extract the list of business rules
  business_rules = local.decoded_yaml["business_rules"]

  # 4. Map the rules and inject the environment suffix dynamically!
  processed_rules = {
    for rule in local.business_rules : rule.rule_id => {
      name         = rule.name
      description  = rule.description
      sql_formula  = rule.sql_formula
      status       = rule.status
      target_table = rule.target_table    }
  }
}

# Output the result so we can see it during our test
output "test_processed_rules" {
  value = local.processed_rules
}