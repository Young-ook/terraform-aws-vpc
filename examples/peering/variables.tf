# Variables for providing to module fixture codes

### network
variable "aws_region" {
  description = "The aws region to deploy"
  type        = string
}

variable "use_default_vpc" {
  description = "A feature flag for whether to use default vpc"
  type        = bool
}

variable "azs" {
  description = "A list of availability zones for the vpc to deploy resources"
  type        = list(string)
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
