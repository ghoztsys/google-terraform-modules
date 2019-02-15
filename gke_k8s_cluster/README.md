# `gke_k8s_cluster`

> For more information on how to deploy a containerized app to GKE, see [Deploying a Containerized App to GKE](https://github.com/sybl/docs/wiki/Deploying-a-Containerized-App-to-GKE).

This module provisions a new Kubernetes cluster on Google Kubernetes Engine. Note that this module creates an **empty** cluster with no running resources. If you know that the cluster will be using a `NodePort` service that needs to be exposed to the public, you can predefine that port number by specifying it in one of the input variables.
