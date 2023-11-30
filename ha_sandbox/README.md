# `ha_sandbox`

This module defines a single node that contains all the services required to run an application (i.e. master, load balancer, database).

## Inputs

### Required

- `region_zone`: The [region zone](https://cloud.google.com/compute/docs/regions-zones/regions-zones) where the new resources will be created in, i.e. `us-central1-a`.
- `ssh_key`: The SSH public key that will be used for all generated resources. See [here](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys) for more information on how to generate an SSH key for GCP.

### Optional

- `app_id` [default=``]: The app ID (i.e. `api`, `www`, etc) to associate with this module. This value will be used for generating a unique resource name and resource tagging.
- `datacenter` [default=`default`]: The datacenter of this resource. This value becomes a tag.
- `environment` [default=`development`]: The environment of this resource, i.e. `development`, `staging`, etc. This value becomes a tag.
- `count` [default=`1`]: The number of resources to create for this particular module. Note that each resource is a standalone sandbox.
- `machine_type` [default=`f1-micro`]: The [machine type](https://cloud.google.com/compute/docs/machine-types) of the resource.
- `disk_image` [default=`ubuntu-1604-xenial-v20161214`]: The disk image of the resource. Ubuntu is preferred. You can find a list of images in your GCP console by selecting "Images" in the "Compute Engine" dashboard.
- `disk_type` [default=`pd-ssd`]: The disk type (i.e. local or persistent disk, standard or ssd) as specified by `pd-standard`, `pd-ssd`, or `local-ssd`. `pd-ssd` is preferred.
- `service_scopes`: The [service scopes](https://developers.google.com/identity/protocols/googlescopes). Both OAuth2 URLs and short names are supported.

## Outputs

- `public_ips`: List of all external ips of all created resources.
