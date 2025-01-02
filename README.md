# Talos Kubernetes Deployment with Omni and Oxide

Welcome to the **Oxide + Talos Kubernetes Deployment Demo** repository! This project demonstrates how to use [Omni](https://omni.siderolabs.com/) from [Sidero Labs](https://www.siderolabs.com/) to easily deploy a Kubernetes installation on [Talos Linux](https://www.talos.dev/). The deployment leverages infrastructure provisioned with [Terraform](https://www.terraform.io/) and runs on an [Oxide](https://oxide.computer/) rack.

## Prerequisites
To replicate this demo, you will need the following:

### Accounts and Access
- Access to an **Oxide rack**.
- A **Sidero Omni account**.

### Tools Installed Locally
- [Omni CLI](https://www.siderolabs.com/docs/omni/installation/) for managing Omni.
- [Oxide CLI](https://github.com/oxidecomputer/cli) for interacting with Oxide resources.
- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) for infrastructure provisioning.

### Additional Requirements
- Basic familiarity with Kubernetes and infrastructure provisioning.

## Project Structure
This repository contains the following components:

- **`main.tf`**: Terraform configuration to provision resources on an Oxide rack.
- **`variables.tf`**: Defines variables used in the Terraform script for customization.
- **`init.sh`**: Initialization script for configuring Talos Linux nodes (currently unused).
- **`README.md`**: This documentation file.

## Quickstart Guide
Follow these steps to deploy Kubernetes on Talos Linux using Omni and Oxide:

1. Clone the Repository.
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Configure your Oxide and Sidero Omni credentials as environment variables:
   ```bash
   export OXIDE_API_TOKEN=<your-oxide-api-token>
   export OMNI_API_TOKEN=<your-omni-api-token>
   ```

3. Edit the `variables.tf` file to match your deployment needs, such as instance count and resource names.

4. Run Terraform to set up the Oxide resources:
   ```bash
   terraform init
   terraform apply
   ```

5. Now you can log into the Omni landing page and create your cluster; [this documentation](https://omni.siderolabs.com/tutorials/getting_started#create-cluster) provides an excellent walk through.


## Cleaning Up
1. Destroy the cluster in the Omni landing page; this will take around 5 minutes.
2. Run `terraform destroy` to remove the provisioned resources.

## Links and References
- **Sidero Labs Omni**: [https://omni.siderolabs.com/](https://omni.siderolabs.com/)
- **Talos Linux**: [https://www.talos.dev/](https://www.talos.dev/)
- **Oxide Computer**: [https://oxide.computer/](https://oxide.computer/)
- **Terraform**: [https://www.terraform.io/](https://www.terraform.io/)

## Contributions
This repository is a WIP and as such is not guaranteed to be working at all times; the more savvy user will fork the repo and use
that as a starting point for their own exploration. Contributions and suggestions are, of course, welcome via issues and pull requests,
although the turn around time can vary wildly.

## Disclaimer
This project is provided "as-is" without warranties or guarantees of functionality. It is intended for educational and demonstration purposes only. Users assume all responsibility for configuring and using the provided scripts. Additionally, this project assumes you have access to the necessary hardware and software accounts. Without access to an Oxide rack and a Sidero Omni account, duplication is not possible.

