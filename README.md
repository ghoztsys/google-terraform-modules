# Terraform Modules

Terraform modules package cloud resources together to make up an enclosed, reusable system.

## Usage

Because often times a service has multiple environments and we want to be able to test module changes without affecting the live environments, all live plans should refer to modules by their release tags:

```hcl
module "k8s_cluster" {
  source = "git::https://github.com/0xGHOZT/terraform-modules//gke_cluster?ref=<release_tag>"
  # source = "git::git.com:0xGHOZT/terraform-modules//gke_cluster?ref=<release_tag>" # If using SSH to checkout private repos
}
```

### Consuming Modules from External Repositories for CI/CD Workflows

This is a private repository, so checking out these modules from an external repo requires proper access to be configured. The following assumes the use of GitHub Actions for CI/CD workflows and checking out GitHub repos over HTTPS protocol:

1. An external GitHub user will be responsible for checking out this repo. Add this user as an outside collaborator in repo settings with a minimum of read access.
2. Generate a GitHub Access Token for this user.
3. In the GitHub Actions workflow script, rewrite GitHub registry URL to include the GAT, either universally:

    ``` yaml
    - env:
        GH_ACCESS_TOKEN: ${{ secrets.GH_ACCESS_TOKEN }}
      run: |
        git config --global url."https://oauth2:${{ secrets.GH_ACCESS_TOKEN }}@github.com".insteadOf https://github.com
    ```

    ...or specifically for GHOZT:

    ```yaml
    - env:
        GH_ACCESS_TOKEN: ${{ secrets.GH_ACCESS_TOKEN }}
      run: |
        git config --local --remove-section http."https://github.com/"
        git config --global url."https://username:${GH_ACCESS_TOKEN}@github.com/0xGHOZT".insteadOf "https://github.com/0xGHOZT"
    ```

## Creating a New Module

Follow the existing project directory structure. Create a folder in the project root with your module's name in `snake_case` and write your plan in there. At the very minimum you need to distinguish between input variables, module output and the main script for resource creation, ideally between these 3 files:

1. `variables.tf` - All supported variables of the module (if any) with a detailed description in each variable. This is so consumers understand what they can customize.
2. `main.tf` - Defines the resources that the module will be provisioning. This should be a black box, consumers shouldn't need to look at this file to understand what the module does.
3. `outputs.tf` - The outputs of the module (if any).

You should also provide a `README` file in the root of the module directory to describe what the module does and how to use it. Ideally all consumers need to look at (in order to be able to start using your module) are the `README`, `variables.tf` and `outputs.tf` files.

## Releasing a New Version of a Module

You must publish a release whenever you want to use a version of a module in production. Just create a tag and publish it. For example:

```sh
$ git tag v1.0.0
$ git push --tags
```

## Documentation

Check out the `README`'s of the individual modules to learn more.

---

© GHOZT
