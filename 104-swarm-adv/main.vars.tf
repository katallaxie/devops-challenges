variable "region" {
  type    = "string"
  default = "ams1"
}

variable "swarm_workers" {
  default     = "3"
  description = "Number of Swarm workers to launch"
}

variable "swarm_managers" {
  default     = "1"
  description = "Number of Swarm managers to launch"
}

variable "swarm_domain" {
  default     = "traefik"
  description = "Domain to be used with traefik"
}

variable "swarm_network" {
  default     = "proxy"
  description = "Default network for communication"
}

variable "sync_network" {
  default     = "sync"
  description = "Default network for syncing"
}

variable "sync_shared_secret" {
  default     = "YOUR_SHARED_SECRET"
  description = "Default secret for syncing"
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
