variable "s3_origin_hostname" {
  description = "Hostname of S3-bucket to be used as origin"
  type        = string
  default     = ""
}

variable "s3_origin_name" {
  description = "Name of S3-bucket to be used as origin"
  type        = string
  default     = ""
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

variable "override_s3_origin_policy" {
  description = "Overrides the S3-bucket policy to set OAI"
  type        = bool
  default     = false
}

variable "s3_origin_policy_restrict_access" {
  description = "Folder/files to add as an condition to the S3-bucket policy resource"
  type        = string
  default     = "/*"
}
