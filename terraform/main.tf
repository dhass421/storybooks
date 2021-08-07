terraform {
    backend "gcs" {
        bucket = "storybooks-devops-314100-terraform"
        prefix = "/state/storybooks"
    }
    required_providers {
        cloudflare = {
            source = "cloudflare/cloudflare"
            version = "~> 2.0"
        }
        mongodbatlas = {
            source = "mongodb/mongodbatlas"
            version = "~> 0.6"
        }
    }
}