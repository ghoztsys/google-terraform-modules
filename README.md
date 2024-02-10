# Terraform Modules for Google Cloud Platform [![CD](https://github.com/ghoztsys/google-terraform-modules/workflows/CD/badge.svg)](https://github.com/ghoztsys/google-terraform-modules/actions/workflows/cd.yml)

Terraform modules package cloud resources together to make up an enclosed, reusable system. This repo contains modules used at GHOZT targeting Google Cloud Platform.

## Usage

To facilitate testing module changes without affecting live environments, all live Terraform plans should refer to modules by specific release tags:

```hcl
module "gke_cluster" {
  source = "git::https://github.com/ghoztsys/terraform-modules//gke_cluster?ref=<release_tag>"
  # source = "git::git.com:ghoztsys/terraform-modules//gke_cluster?ref=<release_tag>" # If using SSH to checkout private repos
}
```

## Creating a New Module

Follow the existing project directory structure. Create a folder in the project root with the new module's name in `snake_case` and compose Terraform plans in there. Separate input variables, module output and the main script for resource creation in different files:

1. `variables.tf` - Includes all supported variables of the module (if any) with a detailed description in each variable. This is so consumers understand what they can customize.
2. `main.tf` - Defines the resources that the module will be provisioning. This should be a black box, consumers shouldn't need to look at this file to understand what the module does.
3. `outputs.tf` - The outputs of the module (if any).
4. `versions.tf` - The version requirements for Terraform and providers.

Also provide a `README` file in the root of the module directory to describe what the module does and how it should be used. Ideally all consumers need to look at (in order to start using the module) are the `README`, `variables.tf` and `outputs.tf` files.

## Releasing a New Version of a Module

Publish tagged releases so modules can be directly referenced by a specific version in production:

```sh
$ git tag v1.0.0
$ git push --tags
```

## Documentation

Check out the `README`'s of the individual modules to learn more.
