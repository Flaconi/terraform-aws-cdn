output "certificate_arn" {
  description = "ARN of ACM SSL certificate created for CloudFront"
  value       = module.certificate.acm_certificate_arn
}

output "cloudfront_arn" {
  description = "ARN of CloudFront distribution creates"
  value       = module.cloudfront.cloudfront_distribution_arn
}

output "cloudfront_id" {
  description = "ID CloudFront distribution ID"
  value       = module.cloudfront.cloudfront_distribution_id
}

output "cloudfront_hosted_zone_id" {
  description = "Hosted Zone ID CloudFront distribution uses"
  value       = module.cloudfront.cloudfront_distribution_hosted_zone_id
}

output "cloudfront_alias" {
  description = "Alias hostname of CloudFront distribution"
  value       = aws_route53_record.this.fqdn
}
