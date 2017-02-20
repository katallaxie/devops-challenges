variable "region" {
  type    = "string"
  default = "par1"
}

variable "swarm_workers" {
  default     = "3"
  description = "Number of Swarm workers to launch"
}

variable "swarm_managers" {
  default     = "1"
  description = "Number of Swarm managers to launch"
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
