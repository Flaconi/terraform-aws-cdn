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

variable "cf_functions" {
  description = <<EOT
  The Cloud Front function configuration
    {type = object{}} ie. {"viewer-request" = object{}}
  *type:*
    Allowed cf event types are viewer-request and viewer-response
  *name:*
    Name of the function
  *comment:*
    Description of the function
  *code:*
    Source code of the function
  *assign:*
    true for associating the function with the cf distribution,
    false to remove the association. (to remove the cf function firstly set it
    to false to dissociate from the cf distribution)
  EOT
  type = map(object({
    name    = string
    comment = string
    code    = string
    assign  = bool
  }))
  default = {}
  validation {
    condition     = alltrue([for type, func in var.cf_functions : contains(["viewer-request", "viewer-response"], type)])
    error_message = "Only the following event types are allowed: viewer-request, viewer-response."
  }
}

variable "default_root_object" {
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
  type        = string
  default     = null
}

variable "create_origin_access_identity" {
  description = "Controls if CloudFront origin access identity should be created"
  type        = bool
  default     = true
}

variable "create_origin_access_control" {
  description = "Controls if CloudFront origin access control should be created"
  type        = bool
  default     = false
}
