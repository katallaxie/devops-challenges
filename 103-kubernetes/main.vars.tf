variable "region" {
  type    = "string"
  default = "par1"
}

variable "k8s_nodes" {
  default     = "3"
  description = "Number of K8 nodes to launch"
}

variable "k8s_masters" {
  default     = "1"
  description = "Number of K8 masters to launch"
}

variable "enable_ipv6" {
  default     = true
  description = "Enabling IPv6"
}

variable "dynamic_ip" {
  default     = true
  description = "Enabling public_ip"
}

variable "private_key" {
  default     = "scaleway_rsa"
  description = "Private key"
}

variable "type" {
  default = "VC1S"
}

variable "archs" {
  default = {
    C1   = "arm"
    VC1S = "x86_64"
    VC1M = "x86_64"
    VC1L = "x86_64"
    C2S  = "x86_64"
    C2M  = "x86_64"
    C2L  = "x86_64"
  }
}
