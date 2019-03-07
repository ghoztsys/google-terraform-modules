# `gke_cluster`

> For more information on how to deploy a containerized app to GKE, see [Deploying a Containerized App to GKE](https://github.com/sybl/codex/wiki/Deploying-a-Containerized-App-to-GKE).

This module provisions a new Kubernetes cluster on Google Kubernetes Engine. Note that this module creates a cluster with a `NodePort` service resource with the option to create a firewall rule that exposes that port to the public.
