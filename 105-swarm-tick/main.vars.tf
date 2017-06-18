variable "region" {
  type    = "string"
  default = "ams1"
}

variable "swarm_workers" {
  default     = "0"
  description = "Number of Swarm workers to launch"
}

variable "swarm_managers" {
  default     = "1"
  description = "Number of Swarm managers to launch"
}

variable "swarm_network" {
  default     = "proxy"
  description = "Default network for communication"
}

variable "monitor_network" {
  default     = "monitor"
  description = "Default network for logging"
}

variable "sync_network" {
  default     = "sync"
  description = "Default network for syncing"
}

variable "sync_shared_secret" {
  default     = "<YOUR SECRET>"
  description = "Default secret for syncing"
}

variable "traefik_email" {
  default     = "admin@acme"
  description = "Default email address to use for ACME"
}

variable "traefik_domain" {
  default     = "acme"
  description = "Default domain for traefik"
}

variable "influx_username" {
  default     = "admin"
  description = "Username to be used with influx"
}

variable "influx_password" {
  default     = "password"
  description = "Username to be used with influx"
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
