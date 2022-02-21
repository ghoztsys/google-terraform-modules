# Terraform Modules

Terraform modules package cloud resources together to make up an enclosed, reusable system.

## Usage

Because often times a service has multiple environments and we want to be able to test module changes without affecting the production environment, all production plans should only refer to modules by this repo URL + release tag.

```hcl
module "k8s_cluster" {
  source = "git::https://github.com/0xGHOZT/terraform-modules//gke_cluster?ref=v0.50.0"
  # source = "git::git.com:0xGHOZT/terraform-modules//gke_cluster?ref=v0.50.0" # If using SSH to checkout private repos instead
}
```

### CI Environment

To checkout `terraform-modules` over HTTPS:

``` yaml
- env:
    GH_ACCESS_TOKEN: ${{ secrets.GH_ACCESS_TOKEN }}
  run: |
    git config --local --remove-section http."https://github.com/"
    git config --global url."https://username:${GH_ACCESS_TOKEN}@github.com/your-org".insteadOf "https://github.com/your-org"
```

## Creating a New Module

Follow the existing project directory structure. Create a folder in the project root with your module's name in `snake_case` and write your plan in there. At the very minimum you need to distinguish between supported variables, output and the main business logic, ideally between these 3 files:

1. `vars.tf` - All supported variables of the module (if any) with a detailed description in each variable. This is so consumers understand what they can customize.
2. `main.tf` - Defines the resources that the module will be provisioning. This should be black box, consumers shouldn't need to look at this file to understand what the module does.
3. `outputs.tf` - The outputs of the module (if any).

You should also provide a `README` file in the root of the module directory to describe what the module does and how to use it. Ideally all consumers need to look at (in order to be able to start using your module) are the `README`, `vars.tf` and `outputs.tf` files.

## Releasing a New Version of a Module

You must publish a release whenever you want to use a version of a module in production. Just create a tag and publish it. For example:

```sh
$ git tag v1.0.0
$ git push --tags
```

## Documentation

Check out the `README`'s of the individual modules to learn more.
