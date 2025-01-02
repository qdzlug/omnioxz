terraform {
  # Specifies the required Terraform version and provider configuration
  required_version = ">= 1.0"

  required_providers {
    oxide = {
      source  = "oxidecomputer/oxide"  # The provider source
      version = "0.5.0"  # The provider version
    }
  }
}

provider "oxide" {
  # Configuration for the Oxide provider (currently no additional setup required)
}

data "oxide_project" "example" {
  # Fetch project data by its name
  name = var.project_name
}

resource "oxide_vpc" "example" {
  # Create a Virtual Private Cloud (VPC) in the specified project
  project_id  = data.oxide_project.example.id
  description = var.vpc_description  # Description of the VPC
  name        = var.vpc_name  # Name of the VPC
  dns_name    = var.vpc_dns_name  # DNS name for the VPC
}

data "oxide_vpc_subnet" "example" {
  # Fetch information about a specific subnet within the VPC
  project_name = data.oxide_project.example.name
  vpc_name     = oxide_vpc.example.name
  name         = "default"  # Name of the subnet
}


resource "oxide_disk" "compute_disks" {
  for_each = { for i in range(var.instance_count) : i => "disk-${var.instance_prefix}-${i + 1}" }

  project_id      = data.oxide_project.example.id
  description     = "Disk for instance ${each.value}"
  name            = each.value
  size            = var.disk_size
  source_image_id = var.boot_image_id
}

resource "oxide_instance" "compute" {
  for_each = { for i in range(var.instance_count) : i => "instance-${var.instance_prefix}-${i + 1}" }

  project_id       = data.oxide_project.example.id
  boot_disk_id     = oxide_disk.compute_disks[each.key].id
  description      = "Instance ${each.value}"
  name             = each.value
  host_name        = each.value
  memory           = var.memory
  ncpus            = var.ncpus
  start_on_create  = true
  disk_attachments = [oxide_disk.compute_disks[each.key].id]
  ssh_public_keys  = [oxide_ssh_key.example.id]
  external_ips = [
    {
      type = "ephemeral"
    }
  ]
  network_interfaces = [
    {
      subnet_id   = data.oxide_vpc_subnet.example.id
      vpc_id      = data.oxide_vpc_subnet.example.vpc_id
      description = "A sample NIC"
      name        = "nic-${each.value}"
    }
  ]
  user_data = filebase64("./init.sh")
}


resource "oxide_ssh_key" "example" {
  # Add an SSH key for instance access
  name        = "example"
  description = "Example SSH key."
  public_key  = var.public_ssh_key  # Public key string
}


