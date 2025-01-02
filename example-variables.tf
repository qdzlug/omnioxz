variable "instance_count" {
  description = "Number of instances to create."
  type        = number
  default     = 6
}

variable "instance_prefix" {
  description = "Prefix for naming instances."
  type        = string
  default     = "talos"
}

variable "project_name" {
  description = "Name of the Oxide project."
  type        = string
  default     = "yourproject"
}

variable "boot_image_id" {
  description = "ID of the boot image to use for instances."
  type        = string
  default     = "your boot image uuid"
}

variable "public_ssh_key" {
  description = "Public SSH key for instance access."
  type        = string
  default     = "ssh-rsa..."
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
  default     = "talos"
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
