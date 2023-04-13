# Google Cloud Regional External HTTP(S) Load Balancer Terraform Module

This module creates a regional [external Google Cloud HTTP(S) load balancer](https://cloud.google.com/load-balancing/docs/https). External HTTP(S) load balancing is implemented by many proxies called Google Front Ends (GFEs), which are distributed globally and has automatic DDoS protection. You have the option to pass in the backend services and/or backend buckets behind the load balancer.

## Usage

```ruby
module "lb" {
  source = "git::git@github.com:ghoztsys/terraform-modules//http_lb_regional?ref=v0.28.0"

  name = "lb"
  region = "us-central1"
  ssl_domains = ["www.example.com"]

  backend_buckets = [{
    path_rules = ["/static", "/static/*"]
  }]

  backend_services = [{
    health_checks = [{
      path = "/health"
      port = 8080
    }]
    port_name = "http"
  }]

  backends = [[{
    port = 8080
    group = <instance_group_url>
    target_tags = ["with-lb"]
  }]]
}
```

## References

- [External HTTP(S) Load Balancing Overview](https://cloud.google.com/load-balancing/docs/https)
- [Network Service Tiers Overview](https://cloud.google.com/network-tiers/docs/overview#configuring_standard_tier_for_load_balancing)
- [Using Network Service Tiers](https://cloud.google.com/network-tiers/docs/using-network-service-tiers)
