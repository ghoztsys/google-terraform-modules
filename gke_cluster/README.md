# `gke_cluster`

This module provisions a new Kubernetes cluster on Google Kubernetes Engine. Note that this module creates a cluster with a `NodePort` service resource with the option to create a firewall rule that exposes that port to the public.
