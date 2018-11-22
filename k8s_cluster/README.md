# k8s_cluster

This module provisions a Kubernetes cluster with an HTTPS load balancer using forwarding rules. The cluster assumes that the containerized application exposes a `NodePort` service on port `30000`.

## Secrets

You should define all your sensitive environment variables using [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/). To do so, prepare a `secret.yaml` file but make sure that **you don't submit that file to version control. An example `secret.yaml` file looks like this:

```yaml
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
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

To apply `secret.yaml`, simply do:

```sh
$ kubectl create -f secret.yaml
```

## Deployments

Next you need to tell Kubernetes to deploy your container. This step assumes that you already have a Docker image built somewhere and that Kubernetes has access rights to pull the image. You will need to create a file that defines your deployment, as specified in the official docs: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/. A deployment file looks like this:

```yaml
# deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: service-name
spec:
  replicas: 2
  template:
    metadata:
      labels:
        run: service-name
    spec:
      hostNetwork: false
      containers:
        - name: service-name
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
                  name: my-secret
                  key: bar
```

Note how the above example references an environment variable from an existing secret. Next, just apply the file:

```sh
$ kubectl create -f deployment.yaml
```

## Services

To route external traffic to your containers, you need to define a service. Use Kubernetes `NodePort` service for this purpose. You can set this up with yet another `yaml` file, like so:

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-nodeport-service
spec:
  type: NodePort
  ports:
    - nodePort: 30000
      port: 80
      protocol: TCP
      targetPort: 8080
      name: http
  selector:
    run: service-name
```

Apply is like so:

```sh
$ kubectl create -f service.yaml
```
