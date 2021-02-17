variable "s3_origin_hostname" {
  description = "Hostname of S3-bucket to be used as origin"
  type        = string
}

variable "r53_hosted_zone" {
  description = "Route53 hosted zone name"
  type        = string
}

variable "r53_hostname" {
  description = "Route53 subdomain hostname"
  type        = string
}
