# `gcs_cdn`

This module creates a Google Cloud Storage bucket fronted by an HTTP(S) load balancer with Cloud CDN enabled. You have the option to specify your own SSL certificates. If not, the certificate will automatically created and managed by Google (recommended).

## Resources Created

1. A global address is created to reserve a static IP for the load balancer. This is useful because we can store the output IP of this resource so other modules can reference it. See [Reserve Static External IP Address](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address).
2. An HTTP and/or HTTPS [Target Proxy](https://cloud.google.com/load-balancing/docs/target-proxies) are created so global forwarding rules (see below) can reference them. They are used to route incoming requests to a URL map (see below). This is necessary for HTTP(S) load balancing.
3. An HTTP and/or HTTPS [global forwarding rule](https://cloud.google.com/load-balancing/docs/https/global-forwarding-rules) are created. Global forwarding rules route traffic by IP address, port and protocol to a load balancing target proxy.
4. A [self-managed SSL certificate](https://cloud.google.com/load-balancing/docs/ssl-certificates) resource is created if a certificate and private key are specified.
5. A [Google-managed SSL certificate](https://cloud.google.com/load-balancing/docs/ssl-certificates#managed-certs) is created for each domain in `ssl_domains`.
6. A [URL map](https://cloud.google.com/load-balancing/docs/https/url-map) that directs traffic to the Google Cloud Storage backend bucket.
7. A [Google Cloud Storage bucket](https://cloud.google.com/storage/) with default ACL set to public read.
8. A [backend bucket](https://cloud.google.com/load-balancing/docs/backend-bucket) that points to the GCS bucket created above.
