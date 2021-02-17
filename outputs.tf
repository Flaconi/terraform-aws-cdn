output "this_certificate_arn" {
  description = "ARN of ACM SSL certificate created for CloudFront"
  value       = module.certificate.this_acm_certificate_arn
}

output "this_cloudfront_arn" {
  description = "ARN of CloudFront distribution creates"
  value       = module.cloudfront.this_cloudfront_distribution_arn
}

output "this_cloudfront_hosted_zone_id" {
  description = "Hosted Zone ID CloudFront distribution uses"
  value       = module.cloudfront.this_cloudfront_distribution_hosted_zone_id
}

output "this_cloudfront_alias" {
  description = "Alias hostname of CloudFront distribution"
  value       = aws_route53_record.this.fqdn
}
