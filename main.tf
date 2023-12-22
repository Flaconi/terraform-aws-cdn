locals {
  origin_hostname_options = {
    use_host = var.s3_origin_hostname != "" ? var.s3_origin_hostname : null
    use_name = var.s3_origin_name != "" ? data.aws_s3_bucket.s3_origin[0].bucket_domain_name : null
  }

  origin_hostname        = local.origin_hostname_options[var.s3_origin_name != "" ? "use_name" : "use_host"]
  override_origin_policy = var.override_s3_origin_policy && var.s3_origin_name != ""

  function_association = { for type, func in var.cf_functions : type => { function_arn = aws_cloudfront_function.functions[type].arn } if func.assign }
}

# Workaround for the input variable validation
resource "null_resource" "either_s3_origin_hostname_or_s3_origin_name_is_required" {
  count = !(var.s3_origin_hostname == "" && var.s3_origin_name == "") ? 0 : "Either s3_origin_hostname or s3_origin_name is required"
}

# Workaround for the input variable validation
resource "null_resource" "s3_origin_name_is_required_to_override_the_s3_origin_policy" {
  count = !(var.override_s3_origin_policy && var.s3_origin_name == "") ? 0 : "s3_origin_name is required to override the origin bucket policy"
}

data "aws_s3_bucket" "s3_origin" {
  count  = var.s3_origin_name != "" ? 1 : 0
  bucket = var.s3_origin_name
}

module "certificate" {
  source = "github.com/terraform-aws-modules/terraform-aws-acm?ref=v3.2.0"
  tags   = var.tags

  domain_name = var.r53_hostname
  zone_id     = var.r53_zone_id

  providers = {
    aws = aws.us-east-1
  }
}

module "cloudfront" {
  source  = "github.com/terraform-aws-modules/terraform-aws-cloudfront?ref=v2.7.0"
  tags    = var.tags
  aliases = [var.r53_hostname]

  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = var.default_root_object

  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket = "Access identity for CDN (${var.r53_hostname})"
  }

  logging_config = var.s3_logging_hostname == "" ? {} : {
    bucket          = var.s3_logging_hostname
    include_cookies = false
    prefix          = var.cdn_logging
  }

  origin = {
    s3_origin = {
      domain_name = local.origin_hostname
      s3_origin_config = {
        origin_access_identity = "s3_bucket"
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3_origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods      = ["GET", "HEAD", "OPTIONS"]
    cached_methods       = ["GET", "HEAD"]
    compress             = true
    query_string         = false
    function_association = local.function_association

  }

  viewer_certificate = {
    acm_certificate_arn = module.certificate.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }
}

data "aws_iam_policy_document" "oai_policy" {
  count = local.override_origin_policy ? 1 : 0

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.s3_origin[0].arn}${var.s3_origin_policy_restrict_access}"]

    principals {
      type        = "AWS"
      identifiers = [element(module.cloudfront.cloudfront_origin_access_identity_iam_arns, 0)]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_origin_policy" {
  count = local.override_origin_policy ? 1 : 0

  bucket = data.aws_s3_bucket.s3_origin[0].id
  policy = data.aws_iam_policy_document.oai_policy[0].json
}

resource "aws_route53_record" "this" {
  zone_id = var.r53_zone_id
  name    = var.r53_hostname
  type    = "A"

  alias {
    zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
    name    = module.cloudfront.cloudfront_distribution_domain_name

    evaluate_target_health = false
  }
}

resource "aws_cloudfront_function" "functions" {
  for_each = var.cf_functions

  name    = each.value.name
  runtime = "cloudfront-js-1.0"
  comment = each.value.comment
  publish = true
  code    = each.value.code
}
