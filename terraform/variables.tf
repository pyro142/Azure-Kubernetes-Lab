variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "uksouth"
}

variable "project" {
  description = "Short project name used in resource names"
  type        = string
  default     = "akslab"
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "node_vm_size" {
  description = "VM size for the AKS system node pool"
  type        = string
  default     = "Standard_D2ls_v6"
}

variable "node_count" {
  description = "Number of nodes in the system node pool"
  type        = number
  default     = 1

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 3
    error_message = "node_count must be between 1 and 3 to keep lab costs low."
  }
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "aks_subnet_prefix" {
  description = "Address range for the AKS node subnet"
  type        = list(string)
  default     = ["10.10.1.0/24"]
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    project     = "aks-terraform-lab"
    environment = "dev"
    managed_by  = "terraform"
  }
}