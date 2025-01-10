# Talos Kubernetes Deployment Demo with Omni and Oxide

Welcome to the **Talos Kubernetes Deployment Demo** repository! This project demonstrates how to use [Omni](https://omni.siderolabs.com/) from [Sidero Labs](https://www.siderolabs.com/) to easily deploy a Kubernetes installation on [Talos Linux](https://www.talos.dev/). The deployment leverages infrastructure provisioned with [Terraform](https://www.terraform.io/) and runs on an [Oxide](https://oxide.computer/) rack.

## Prerequisites
To replicate this demo, you will need the following:

### Accounts and Access
- Access to an **Oxide rack**.
- A **Sidero Omni account**.

### Tools Installed Locally
- [Sidero CLI](https://www.siderolabs.com/docs/omni/installation/) for managing Omni.
- [Oxide CLI](https://github.com/oxidecomputer/cli) for interacting with Oxide resources.
- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) for infrastructure provisioning.
- [Ansible](https://www.ansible.com/) for managing the load balancer configuration.

### Additional Requirements
- Basic familiarity with Kubernetes, infrastructure provisioning, and Ansible.

## Project Structure
This repository contains the following components:

- **`main.tf`**: Terraform configuration to provision resources on an Oxide rack.
- **`variables.tf`**: Defines variables used in the Terraform script for customization.
- **`init.sh`**: Initialization script for configuring Talos Linux nodes.
- **`nginstall.sh`**: Script to install and configure NGINX.
- **`nginx.conf`**: Predefined NGINX configuration file.
- **`ansible/`**: Directory containing Ansible playbook for NGINX setup.
- **`README.md`**: This documentation file.

## Talos Install Media
```
customization:
  systemExtensions:
    officialExtensions:
      - siderolabs/iscsi-tools
      - siderolabs/util-linux-tools``
```

## Quickstart Guide
Follow these steps to deploy Kubernetes on Talos Linux using Omni and Oxide:

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Set Up Environment Variables**:
   Configure your Oxide and Sidero Omni credentials as environment variables:
   ```bash
   export OXIDE_API_TOKEN=<your-oxide-api-token>
   export OMNI_API_TOKEN=<your-omni-api-token>
   ```

3. **Customize Configuration**:
   Edit the `variables.tf` file to match your deployment needs, such as instance count and resource names.

4. **Provision Infrastructure**:
   Run Terraform to set up the Oxide resources:
   ```bash
   terraform init
   terraform apply
   ```

5. **Initialize Talos Nodes**:
   Use Omni to configure the provisioned nodes with Talos Linux:
   ```bash
   sideroctl apply cluster --file cluster-config.yaml
   ```

6. **Deploy Kubernetes**:
   Follow the [Talos Kubernetes setup guide](https://www.talos.dev/v1.0/kubernetes/) to deploy Kubernetes.

7. **Set Up Load Balancer**:
   Use Ansible to configure the load balancer node with NGINX:
   ```bash
   ansible-playbook ansible/nginx-setup.yml -i ansible/inventory.yml
   ```

## Links and References
- **Sidero Labs Omni**: [https://omni.siderolabs.com/](https://omni.siderolabs.com/)
- **Talos Linux**: [https://www.talos.dev/](https://www.talos.dev/)
- **Oxide Computer**: [https://oxide.computer/](https://oxide.computer/)
- **Terraform**: [https://www.terraform.io/](https://www.terraform.io/)
- **Ansible**: [https://www.ansible.com/](https://www.ansible.com/)

## Contributions
This repository is a demo and is not actively maintained. Contributions and suggestions are welcome via issues and pull requests.

## Disclaimer
This project is provided "as-is" without warranties or guarantees of functionality. It is intended for educational and demonstration purposes only. Users assume all responsibility for configuring and using the provided scripts. Additionally, this project assumes you have access to the necessary hardware and software accounts. Without access to an Oxide rack and a Sidero Omni account, duplication is not possible.
