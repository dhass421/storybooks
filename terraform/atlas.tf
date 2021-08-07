provider "mongodbatlas" {
  public_key = var.mongodbatlas_public_key
  private_key  = var.mongodbatlas_private_key
}

# CLUSTER
resource "mongodbatlas_cluster" "storybooks" {
  project_id   = var.atlas_project_id
  name         = "${var.app_name}-${terraform.workspace}"
  cluster_type = "REPLICASET"
  replication_specs {
    num_shards = 1
    regions_config {
      region_name     = "CENTRAL_US"
      electable_nodes = 3
      priority        = 7
      read_only_nodes = 0
    }
  }
  provider_backup_enabled      = false
  auto_scaling_disk_gb_enabled = false
  mongo_db_major_version       = "4.2"

  //Provider Settings "block"
  provider_name               = "GCP"
  disk_size_gb                = 10
  provider_instance_size_name = "M10"
}

# DB USER
resource "mongodbatlas_database_user" "mongo_user" {
  username           = "storybooks-user-${terraform.workspace}"
  password           = var.atlas_user_password
  project_id         = var.atlas_project_id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "storybooks"
  }

  roles {
    role_name     = "readAnyDatabase"
    database_name = "admin"
  }
}

# IP WHITELIST
resource "mongodbatlas_project_ip_whitelist" "storybooks" {
  project_id = var.atlas_project_id
  ip_address = google_compute_address.ip_address.address
}