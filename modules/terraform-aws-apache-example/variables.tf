variable "vpc_id" {
  type = string
}

variable "access_ip" {
  type = string
  description = "Provide your IP address for access"
}

variable "public_key" {
  type= string
  description = "RSA public key for access to the VM"
}
