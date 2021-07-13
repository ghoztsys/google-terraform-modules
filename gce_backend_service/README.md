# `gce_backend_service`

This module creates a Backend Service/Bucket, depending on the specified `type` variable. Created resources may also be regional instead of global (default) if `regional` is set to `true` (defaults to `false`).

## Usage

```ruby
module "backend_service" {
  source = "git::git@github.com:sybl/terraform-modules//gce_backend_service?ref=v0.42.0"

  backends = [{
    port = 8080
    group = <instance_group_url>
    target_tags = ["foo"]
  }]
  enable_cdn = true
  health_checks = [{
    path = "/health"
    port = 8080
  }]
  name = "backend-service"
  port_name = "http"
  type = "service"
}

module "backend_bucket" {
  source = "git::git@github.com:sybl/terraform-modules//gce_backend_service?ref=v0.42.0"

  enable_cdn = true
  location = "US"
  name = "backend-bucket"
  type = "bucket"
}
```

## Resources Created

### When `type` is `service`

1. `google_compute_backend_service.default`: The Backend Service resource.
2. `google_compute_health_check.default.*`: The Health Check resources for the created Backend Service.
3. `google_compute_firewall.default`: Firewall rules to support health check ranges and exposed backend ports for the Backend Service.

### When `type` is `bucket`

1. `google_compute_backend_bucket.default`: The [Backend Bucket](https://cloud.google.com/load-balancing/docs/https/ext-load-balancer-backend-buckets) resource.
2. `google_storage_bucket.default`: The [Google Cloud Storage bucket](https://cloud.google.com/storage/) associated with the created Backend Bucket.
3. `google_storage_bucket_acl.default`: The ACL configuration for the GCS bucket.

## References

- [Setting up an external HTTP(S) load balancer with a Compute Engine backend](https://cloud.google.com/load-balancing/docs/https/ext-https-lb-simple)
- [Setting up a load balancer with backend buckets](https://cloud.google.com/load-balancing/docs/https/ext-load-balancer-backend-buckets)
