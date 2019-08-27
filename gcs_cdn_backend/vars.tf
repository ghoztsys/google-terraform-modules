variable bucket_location {
  default = "US"
  description = "Location of the GCS bucket."
}

variable name {
  description = "Name of the bucket."
}

variable project_id {
  description = "Google Cloud Platform project ID."
}

variable region {
  description = "The region where the project resides."
}
