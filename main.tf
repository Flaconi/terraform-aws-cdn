module "certificate" {
  source = "github.com/terraform-aws-modules/terraform-aws-acm?ref=v2.13.0"
  tags   = var.tags

  domain_name = var.r53_hostname
  zone_id     = var.r53_zone_id

  providers = {
    aws = aws.us-east-1
  }
}

module "cloudfront" {
  source  = "github.com/Flaconi/terraform-aws-cloudfront?ref=v1.0.1"
  tags    = var.tags
  aliases = [var.r53_hostname]

  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket = "Access identity for CDN (${var.r53_hostname})"
  }

  logging_config = var.s3_logging_hostname == "" ? {} : { bucket = var.s3_logging_hostname }

  origin = {
    s3_origin = {
      domain_name = var.s3_origin_hostname
      s3_origin_config = {
        origin_access_identity = "s3_bucket"
      }
    }
  }

  cache_behavior = {
    default = {
      target_origin_id       = "s3_origin"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = false
    }
  }

  viewer_certificate = {
    acm_certificate_arn = module.certificate.this_acm_certificate_arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_route53_record" "this" {
  zone_id = var.r53_zone_id
  name    = var.r53_hostname
  type    = "A"

  alias {
    zone_id = module.cloudfront.this_cloudfront_distribution_hosted_zone_id
    name    = module.cloudfront.this_cloudfront_distribution_domain_name

    evaluate_target_health = false
  }
}
