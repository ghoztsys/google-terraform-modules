# `ha_cluster`

This module defines a high availability cluster that runs an application, consisting of the following nodes: the master node(s) for controlling all other nodes within the cluster, the load balancer node(s) for directing traffic to the nodes that actually run the app, the database node(s) for storing data, and the application node(s) for serving the app and handling requests.

## Inputs

### Required

- `region_zone`: The [region zone](https://cloud.google.com/compute/docs/regions-zones/regions-zones) where the new resources will be created in, i.e. `us-central1-a`.
- `ssh_key`: The SSH public key that will be used for all generated resources. See [here](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys) for more information on how to generate an SSH key for GCP.

### Optional

- `app_id` [default=``]: The app ID (i.e. `sybl-api`, `sybl-www`, etc) to associate with this module. This value will be used for generating a unique resource name and resource tagging.
- `datacenter` [default=`default`]: The datacenter of this resource. This value becomes a tag.
- `environment` [default=`development`]: The environment of this resource, i.e. `development`, `staging`, etc. This value becomes a tag.
- `{node_type}_count` [default=`1`]: The number of resources to create for this particular node type. `{node_type}` is one of `node`, `lb`, `db`, and `master`.
- `{node_type}_machine_type` [default=`f1-micro`]: The [machine type](https://cloud.google.com/compute/docs/machine-types) of the resources of this node type. `{node_type}` is one of `node`, `lb`, `db`, and `master`.
- `{node_type}_disk_image` [default=`ubuntu-1604-xenial-v20161214`]: The disk image of the resources of this node type. Ubuntu is preferred. You can find a list of images in your GCP console by selecting "Images" in the "Compute Engine" dashboard. `{node_type}` is one of `node`, `lb`, `db`, and `master`.
- `{node_type}_disk_type` [default=`pd-ssd`]: The disk type (i.e. local or persistent disk, standard or ssd) as specified by `pd-standard`, `pd-ssd`, or `local-ssd`. `pd-ssd` is preferred. `{node_type}` is one of `node`, `lb`, `db`, and `master`.
- `{node_type}_service_scopes`: The [service scopes](https://developers.google.com/identity/protocols/googlescopes) for this particular node type. Both OAuth2 URLs and short names are supported.

## Outputs

- `public_ips`: List of all external ips of all load balancer (`lb`) nodes.
- `node_public_ips`: List of all external ips of all application (`node`) nodes.
- `db_public_ips`: List of all external ips of all database (`db`) nodes.
- `master_public_ips`: List of all external ips of all master (`master`) nodes.
