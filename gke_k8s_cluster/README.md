# gke_k8s_cluster

This module provisions a new Kubernetes cluster on Google Kubernetes Engine.

## Concept

Some terms you should be familiar with before using Kubernetes:

1. **Pod**: A pod is the smallest deployable unit in Kubernetes. A pod consists of one or more Docker containers. Containers have access to each other because they coexist in the same enclosed network (within the pod), hence they can ping each other via `localhost`.
2. **Deployment**: A deployment controller is a configuration file that declaratively defines how pod instances are created, deployed and maintained. This is how you create Pods.
3. **Service**: A service controller organizes Pods into logical units and exposes ports on these logical units so the service can be accessed from outside of the cluster.
4. **Cluster**: A cluster is the largest unit of Kubernetes. It consists of pod(s), deployment controller(s) and service controller(s).
5. **Node**: A node is a VM instance that hosts a cluster. A cluster can be hosted on multiple nodes. Kubernetes automatically distributes resources among these nodes depending on resource usage (CPU, RAM, etc).

## Usage

After provisioning this module, go to Kubernetes Engine dashboard and grab the command to connect to the provisioned cluster via `kubectl`. It should look something like this:

```sh
$ gcloud container clusters get-credentials sybl-core-dc0-dev-cluster-2641b9bb --zone us-central1-a --project sybl-core
```

You can then use `kubectl` to interact with the cluster.

## Deploying an Application On the Cluster

To deploy an application, need to create **deployment** controller(s) and **secret** controller(s) (only if you need to secure environment variables for the application).

### Secrets

You should define all your sensitive environment variables using [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/). To do so, prepare a `secret.yaml` file but make sure that **you don't submit that file to version control**. An example `secret.yaml` file looks like this:

```yaml
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret-name
type: Opaque
data:
  db-host: "redacted"
  storage-location: "redacted"
  apn-provider-key: "redacted"
  apn-provider-key-id: "redacted"
  apn-provider-team-id: "redacted"
  sentry-dsn-url: "redacted"
  twilio-auth-token: "redacted"
  twilio-sid: "redacted"
  twilio-number: "redacted"
```

In fields where it says `redacted`, pass in an encoded string of the original environment variable value. For example:

```sh
# Encode this sensitive password
$ echo -n "password" | base64
> cGFzc3dvcmQ=

$ Decode the encoded value
$ echo "cGFzc3dvcmQ=" | base64 --decode
> password
```

To apply `secret.yaml`, simply run:

```sh
$ kubectl create -f secret.yaml
```

### Deployments

Next you need to tell Kubernetes to deploy your containerized application. This step assumes that you already have a Docker image built somewhere and that Kubernetes has access rights to pull the image. You will need to create a file that defines your deployment, as specified in the official docs: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/. A deployment file looks like this:

```yaml
# deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: app-name
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: app-name
    spec:
      hostNetwork: false
      containers:
        - name: app-name
          image: "docker-image-location"
          ports:
            - containerPort: 8080
              hostPort: 8080
          env:
            - name: FOO
              value: "foo"
            - name: BAR
              valueFrom:
                secretKeyRef:
                  name: secret-name
                  key: secret-key
```

Note how the above example references an environment variable from an existing secret. Next, just apply the file:

```sh
$ kubectl create -f deployment.yaml
```

## Exposing the Application to the Internet

### Services

To route external traffic to your containers, you need to define a service. There are two types of services you can use to expose a port on your clsuter.

#### LoadBalancer Service

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: service-name
spec:
  type: LoadBalancer
  selector:
    app: app-name
  ports:
    - protocol: TCP
      name: http
      port: 8080
```

Apply the service:

```sh
$ kubectl create -f service.yaml
```

Look up the public IP of the service which you can then access it by `<public_ip>:<port>`:

```sh
$ kubectl get services
```

#### NodePort Service

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: service-name
spec:
  type: NodePort
  selector:
    app: app-name
  ports:
    - protocol: TCP
      name: http
      nodePort: 30000
      port: 80
      targetPort: 8080
```

Create the service:

```sh
$ kubectl create -f service.yaml
```

You can now access the service via 3 different addresses:

1. `<node_external_ip>:30000` - Available from anywhere: outside of cluster or inside a cluster (in a pod or node)
2. `<service_ip>:80` - Only available inside a cluster (in a pod or node)
3. `<pod_ip>:8080` - Only available inside a cluster (in a pod or node)

You can always grab the opened NodePort and the service IP by running:

```sh
# IP is the service IP, NodePort is NodePort
$ kubectl describe services <service_name>
```

You can list your node instances by running:

```sh
$ gcloud compute instances list
```

To get the IP of a pod, run:

```sh
# IP is the pod IP
$ kubectl describe pods
```

If you are accessing the service via `<node_external_ip>:<node_port>`, be sure to create a firewall rule that allows TCP access to the node port.