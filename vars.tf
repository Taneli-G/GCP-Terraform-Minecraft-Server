variable "project_id" {
  type        = string
  description = "Google Cloud Project ID"
  default     = "your-project-id"
}

variable "region" {
  type        = string
  description = "Region to run the Minecraft server on"
  default     = "europe-north1"
}

variable "zone" {
  type        = string
  description = "Zone to run the Minecraft server on"
  default     = "europe-north1-a"
}

variable "tf_state_bucket_name" {
  type        = string
  description = "Terraform state file bucket name"
  default     = "your-bucket-tfstate"
}

variable "tf_state_bucket_location" {
  type        = string
  description = "Terraform state filen bucketin location"
  default     = "EUROPE-NORTH1"
}

variable "cloudfunctions_bucket_location" {
  type        = string
  description = "Cloud functions source file bucketin location"
  default     = "EUROPE-NORTH1"
}

variable "service_account_email" {
  type        = string
  description = "GCP Porject Service account email"
}

variable "mc_disk_name" {
  type        = string
  description = "Minecraft server's disk name (where world data is persisted)"
  default     = "mc-data-disk"
}