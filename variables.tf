variable "environment" {
  type        = string
  description = "The target environment (e.g., dev, test, prod)"
  default     = "dev" # Defaulting to dev for our local test
}

variable "spoke_project" {
  type        = string
  description = "The Spoke project ID (e.g., jutomate-playground)"
  default     = "jutomate-playground"
}

variable "hub_project_number" {
  type        = string
  description = "The Project Number of the Hub project (Required for Aspect Keys)"
  default     = "111111111111" # We will inject the real number later
}

variable "location" {
  type        = string
  default     = "us-central1"
}