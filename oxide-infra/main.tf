terraform {
  required_version = ">= 1.0"

  required_providers {
    oxide = {
      source  = "oxidecomputer/oxide"
      version = "0.5.0"
    }
  }
}

provider "oxide" {}


data "oxide_project" "talos" {
  # Fetch project by name
  name = var.project_name
}

resource "oxide_ssh_key" "talos" {
  # Fetch project by name
  name        = "talos-sshkey"
  description = "SSH Key for Access"
  public_key  = var.public_ssh_key
}


data "oxide_instance_external_ips" "talos" {
  for_each = oxide_instance.compute
  instance_id = each.value.id
}

resource "oxide_vpc" "talos" {
  project_id  = data.oxide_project.talos.id
  description = var.vpc_description
  name        = var.vpc_name
  dns_name    = var.vpc_dns_name
}


data "oxide_vpc_subnet" "talos" {
  project_name = data.oxide_project.talos.name
  vpc_name     = oxide_vpc.talos.name
  name         = "default"
}

resource "oxide_disk" "compute_disks" {
  for_each = { for i in range(var.instance_count) : i => "disk-${var.instance_prefix}-${i + 1}" }

  project_id      = data.oxide_project.talos.id
  description     = "Disk for instance ${each.value}"
  name            = each.value
  size            = var.disk_size
  source_image_id = var.boot_image_id
}

resource "oxide_instance" "compute" {
  for_each = { for i in range(var.instance_count) : i => "${var.instance_prefix}-${i + 1}" }

  project_id       = data.oxide_project.talos.id
  boot_disk_id     = oxide_disk.compute_disks[each.key].id
  description      = "Instance ${each.value}"
  name             = each.value
  host_name        = each.value
  memory           = var.memory
  ncpus            = var.ncpus
  start_on_create  = true
  disk_attachments = [oxide_disk.compute_disks[each.key].id]
  ssh_public_keys  = [oxide_ssh_key.talos.id]
  external_ips = [
    {
      type = "ephemeral"
    }
  ]
  network_interfaces = [
    {
      subnet_id   = data.oxide_vpc_subnet.talos.id
      vpc_id      = data.oxide_vpc_subnet.talos.vpc_id
      description = "A sample NIC"
      name        = "nic-${each.value}"
    }
  ]
}

resource "oxide_disk" "lb_disk" {
  project_id      = data.oxide_project.talos.id
  description     = "Disk for load balancer"
  name            = "disk-${var.lb_instance_name}"
  size            = var.lb_disk_size
  source_image_id = var.lb_image_id
}



resource "oxide_instance" "load_balancer" {
  project_id       = data.oxide_project.talos.id
  boot_disk_id     = oxide_disk.lb_disk.id
  description      = "Load balancer instance"
  name             = var.lb_instance_name
  host_name        = var.lb_instance_name
  memory           = var.lb_memory
  ncpus            = var.lb_ncpus
  start_on_create  = true
  ssh_public_keys  = [oxide_ssh_key.talos.id]
  disk_attachments = [oxide_disk.lb_disk.id]
  external_ips = [
    {
      type   = "floating"
      id     =  var.talos_floating_ip
  } 
  ]
  network_interfaces = [
    {
      subnet_id   = data.oxide_vpc_subnet.talos.id
      vpc_id      = data.oxide_vpc_subnet.talos.vpc_id
      description = "NIC for load balancer"
      name        = "nic-${var.lb_instance_name}"
    }
  ]
}


resource "oxide_vpc_firewall_rules" "load_balancer" {
  vpc_id = oxide_vpc.talos.id

  rules = [
    {
      action      = "allow"
      description = "Allow inbound SSH traffic"
      name        = "allow-ssh"
      direction   = "inbound"
      priority    = 1000
      status      = "enabled"
      filters = {
        ports     = ["22"]
        protocols = ["TCP"]
      },
      targets = [
        {
          type  = "instance"
          value = oxide_instance.load_balancer.name
        }
      ]
    },
    {
      action      = "allow"
      description = "Allow inbound HTTP traffic"
      name        = "allow-http"
      direction   = "inbound"
      priority    = 1001
      status      = "enabled"
      filters = {
        ports     = ["80"]
        protocols = ["TCP"]
      },
      targets = [
        {
          type  = "instance"
          value = oxide_instance.load_balancer.name
        }
      ]
    },
    {
      action      = "allow"
      description = "Allow inbound HTTPS traffic"
      name        = "allow-https"
      direction   = "inbound"
      priority    = 1002
      status      = "enabled"
      filters = {
        ports     = ["443"]
        protocols = ["TCP"]
      },
      targets = [
        {
          type  = "instance"
          value = oxide_instance.load_balancer.name
        }
      ]
    }
  ]
}


resource "local_file" "hosts_ini" {
  filename = "${path.root}/../ansible/hosts.ini"
  content  = templatefile("${path.root}/templates/hosts.ini.tpl", {
    loadbalancer_ip   = data.oxide_instance_external_ips.load_balancer.external_ips[0].ip,
    control_plane_ips = [
      for key, instance in data.oxide_instance_external_ips.talos : instance.external_ips.0.ip
      if tonumber(key) < 3
    ],
    worker_ips = [
      for key, instance in data.oxide_instance_external_ips.talos : instance.external_ips.0.ip
      if tonumber(key) >= 3
    ]
  })
}



data "oxide_instance_external_ips" "load_balancer" {
  instance_id = oxide_instance.load_balancer.id
}

resource "local_file" "nginx_conf" {
  filename = "${path.root}/../ansible/files/nginx.conf"
  content  = templatefile("${path.root}/templates/nginx.conf.tpl", {
    control_plane_ips = [
      for key, instance in data.oxide_instance_external_ips.talos : instance.external_ips[0].ip
      if tonumber(key) < 3
    ]
  })
}

resource "local_file" "cluster_yaml" {
  filename = "${path.root}/../talos/cluster.yaml"
  content  = templatefile("${path.root}/templates/cluster.yaml.tpl", {
    cluster_name        = var.cluster_name,
    kubernetes_version  = var.kubernetes_version,
    talos_version       = var.talos_version,
    control_plane_uuids = [
      for key, instance in data.oxide_instance_external_ips.talos : instance.id
      if tonumber(key) < 3
    ],
    worker_uuids = [
      for key, instance in data.oxide_instance_external_ips.talos : instance.id
      if tonumber(key) >= 3
    ],
    all_machine_uuids = [
      for instance in data.oxide_instance_external_ips.talos : instance.id
    ]
  })
}


output "talos_node_ips" {
  value = [for instance in data.oxide_instance_external_ips.talos : instance.external_ips.0.ip]
}

output "hosts_ini" {
  value = templatefile("${path.root}/templates/hosts.ini.tpl", {
    loadbalancer_ip = data.oxide_instance_external_ips.load_balancer.external_ips[0].ip,
    control_plane_ips = [
      for key, instance in data.oxide_instance_external_ips.talos : instance.external_ips.0.ip
      if tonumber(key) < 3
    ],
    worker_ips = [
      for key, instance in data.oxide_instance_external_ips.talos : instance.external_ips.0.ip
      if tonumber(key) >= 3
    ]
  })
}

output "nginx_conf" {
  description = "Rendered NGINX configuration file with dynamic control plane IPs"
  value = templatefile("${path.root}/templates/nginx.conf.tpl", {
    control_plane_ips = [
      for key, instance in data.oxide_instance_external_ips.talos : instance.external_ips[0].ip
      if tonumber(key) < 3
    ]
  })
}

output "cluster_yaml" {
  description = "Rendered cluster.yaml for Kubernetes cluster creation"
  value = templatefile("${path.root}/templates/cluster.yaml.tpl", {
    cluster_name        = var.cluster_name,
    kubernetes_version  = var.kubernetes_version,
    talos_version       = var.talos_version,
    control_plane_uuids = [
      for key, instance in data.oxide_instance_external_ips.talos : instance.id
      if tonumber(key) < 3
    ],
    worker_uuids = [
      for key, instance in data.oxide_instance_external_ips.talos : instance.id
      if tonumber(key) >= 3
    ],
    all_machine_uuids = [
      for instance in data.oxide_instance_external_ips.talos : instance.id
    ]
  })
}
