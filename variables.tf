variable "s3_origin_hostname" {
  description = "Hostname of S3-bucket to be used as origin"
  type        = string
}

variable "s3_logging_hostname" {
  description = "Hostname of S3-bucket to be used for logging"
  type        = string
  default     = ""
}

variable "cdn_logging" {
  description = "Prefix in s3 bucket for cdn logs"
  type        = string
  default     = ""
}

variable "r53_hostname" {
  description = "Hostname for CloudFront alias"
  type        = string
}

variable "r53_zone_id" {
  description = "Route53 zone ID to be used for hostname and certificate validation"
  type        = string
}

variable "tags" {
  description = "Map of custom tags for the provisioned resources"
  type        = map(string)
  default     = {}
}
