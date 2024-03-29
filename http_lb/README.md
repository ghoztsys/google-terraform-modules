# Google Cloud Global External HTTP(S) Load Balancer Terraform Module

This module creates a global [external Google Cloud HTTP(S) load balancer](https://cloud.google.com/load-balancing/docs/https). External HTTP(S) load balancing is implemented by many proxies called Google Front Ends (GFEs), which are distributed globally and has automatic DDoS protection. Since this is a global load balancer, it is configured to operate in Premium Tier where GFEs offer global, cross-regional load balancing, directing traffic to the closest healthy backend that has capacity and terminating HTTP(S) as close as possible to the client. You have the option to define the Backend Services and/or Backend Buckets behind the load balancer.

## Usage

```ruby
module "lb" {
  source = "git::git@github.com:ghoztsys/terraform-modules//http_lb?ref=<release_tag>"

  name = "lb"
  ssl_domains = ["www.example.com"]

  backend_services = [{
    type = "service"
    enable_cdn = true
    health_checks = [{
      path = "/health"
      port = 8080
    }]
    port_name = "http"
    backends = [{
      port = 8080
      group = <instance_group_url>
      target_tags = ["with-lb"]
    }]
  }, {
    type = "bucket"
    enable_cdn = true
    location = "US"
  }]

  url_map = [{
    hosts = ["*"]
    default_backend_service_index = 0
    path_rules = [{
      paths = ["/static", "/static/*"]
      backend_service_index = 1
    }]
  }]
}
```

## Resources Created

1. `google_compute_global_address.default`: A global address is created to reserve a static IP for the load balancer. This is useful because we can store the output IP of this resource so other modules can reference it. See [Reserve Static External IP Address](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address).
2. `google_compute_target_http_proxy.http` and/or `google_compute_target_https_proxy.https`: An HTTP and/or HTTPS [Target Proxy](https://cloud.google.com/load-balancing/docs/target-proxies) are created so global forwarding rules (see below) can reference them. They are used to route incoming requests to a URL map (see below). This is necessary for HTTP(S) load balancing.
3. `google_compute_global_forwarding_rule.http` and/or `google_compute_global_forwarding_rule.https`: An HTTP and/or HTTPS [global forwarding rule](https://cloud.google.com/load-balancing/docs/https/global-forwarding-rules) are created. Global forwarding rules route traffic by IP address, port and protocol to a load balancing target proxy.
4. `google_compute_ssl_certificate.https`: A [self-managed SSL certificate](https://cloud.google.com/load-balancing/docs/ssl-certificates) resource is created if a certificate and private key are specified.
5. `google_compute_managed_ssl_certificate.https`: A [Google-managed SSL certificate](https://cloud.google.com/load-balancing/docs/ssl-certificates#managed-certs) is created for each domain in `ssl_domains`.
6. `google_compute_url_map.default`: A [URL map](https://cloud.google.com/load-balancing/docs/https/url-map) is automatically generated to direct traffic to the specified backend services and/or backend buckets. A custom one can also be provided.
7. `module.backend_service.*`: A set of backend services are created based on the provided parameters (see [`backend_service`](https://github.com/ghoztsys/terraform-modules/tree/master/backend_service) module).

## References

- [External HTTP(S) Load Balancing Overview](https://cloud.google.com/load-balancing/docs/https)
- [Network Service Tiers Overview](https://cloud.google.com/network-tiers/docs/overview#configuring_standard_tier_for_load_balancing)
- [Using Network Service Tiers](https://cloud.google.com/network-tiers/docs/using-network-service-tiers)
