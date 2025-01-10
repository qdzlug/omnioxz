variable "instance_count" {
  description = "Number of instances to create."
  type        = number
  default     = 6
}

variable "instance_prefix" {
  description = "Prefix for naming instances."
  type        = string
  default     = "talos-"
}

variable "project_name" {
  description = "Name of the Oxide project."
  type        = string
}


variable "boot_image_id" {
  description = "ID of the boot image to use for instances."
  type        = string
}

variable "public_ssh_key" {
  description = "Public SSH key for instance access."
  type        = string
}

variable "disk_size" {
  description = "Size of the boot disk in bytes."
  type        = number
  default     = 137438953472
}

variable "memory" {
  description = "Memory size for each instance in bytes."
  type        = number
  default     = 8589934592
}

variable "ncpus" {
  description = "Number of virtual CPUs for each instance."
  type        = number
  default     = 4
}

variable "vpc_name" {
  description = "Name of the VPC."
  type        = string
  default     = "talos-vpc"
}

variable "vpc_dns_name" {
  description = "DNS name for the VPC."
  type        = string
  default     = "talos"
}

variable "vpc_description" {
  description = "Description of the VPC."
  type        = string
  default     = "Talos VPC"
}


variable "lb_instance_name" {
  description = "Name of the load balancer instance."
  type        = string
  default     = "talos-lb"
}

variable "lb_image_id" {
  description = "Boot image ID for the load balancer node."
  type        = string # Process assumes an Ubuntu Image
}

variable "lb_memory" {
  description = "Memory size for the load balancer node in bytes."
  type        = number
  default     = 4294967296
}

variable "lb_ncpus" {
  description = "Number of virtual CPUs for the load balancer node."
  type        = number
  default     = 2
}

variable "lb_disk_size" {
  description = "Disk size for the load balancer node in bytes."
  type        = number
  default     = 17179869184
}

variable "talos_floating_ip" {
  description = "Pre-created Floating IP to attach to the load balancer instance"
  type        = string
}
