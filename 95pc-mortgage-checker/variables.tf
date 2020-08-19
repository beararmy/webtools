variable "location" {
  type = string
}

variable "shortname" {
  type = string
}

variable "env" {
  description = "live or dev"
  type        = string
  default     = "live"
}

variable "alert-email" {
  type = string
}

variable "alert-name" {
  type = string
}
