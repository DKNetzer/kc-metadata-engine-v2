terraform {
  # Add this empty backend block
  backend "gcs" {} 
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.50" # <-- Update this line to the 6.x series
    }
  }
}

provider "google" {
  # We will pass the project dynamically later
}