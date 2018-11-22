# Terraform Modules

Terraform modules package cloud resources together to make up an enclosed, reusable system. This is the main repo Sybl's custom reusable Terraform modules.

## Usage

Because often times a service has multiple environments and we want to be able to test module changes without affecting the production environment, all production plans should only refer to modules by this repo URL + release tag. You must publish a release whenever you want to use a version of a module in production.

```hcl
module "k8s_cluster" {
  source = "git::git@github.com:sybl/terraform-modules//k8s_cluster?ref=v1.0.0"
}
```

## Documentation

Check out the README's of the individual modules to learn more.

## License

© Sybl
