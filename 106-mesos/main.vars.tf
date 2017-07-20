variable "mesos_masters" {
  default     = "1"
  description = "Number of Mesos Masters"
}

variable "mesos_slaves" {
  default     = "1"
  description = "Number of Mesos Agent"
}

variable "weave_subnet" {
  default     = "10.2.0.0/16"
  description = "Weave Network"
}

variable "weave_subnet_default" {
  default     = "10.2.1.0/24"
  description = ""
}

variable "weave_subnet_mesos" {
  default     = "10.2.2.0/24"
  description = ""
}

variable "weave_network" {
  default     = "weave"
  description = ""
}

variable "weave_password" {
  default     = "SWaTytSX7RDlvEKpTmc9YM3Un0UgHyHeqJBZOLYfLHaE5u3zzY"
  description = ""
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

variable "region" {
  type    = "string"
  default = "ams1"
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
