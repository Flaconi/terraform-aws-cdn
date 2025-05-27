moved {
  from = module.certificate.aws_route53_record.validation[0]
  to   = module.certificate-validations["single"].aws_route53_record.validation[0]
}

moved {
  from = aws_route53_record.this
  to   = aws_route53_record.this[0]
}

moved {
  from = module.certificate.aws_acm_certificate_validation.this[0]
  to   = aws_acm_certificate_validation.this
}

locals {
  origin_hostname_options = {
    use_host = var.s3_origin_hostname != "" ? var.s3_origin_hostname : null
    use_name = var.s3_origin_name != "" ? data.aws_s3_bucket.s3_origin[0].bucket_domain_name : null
  }

  origin_hostname        = local.origin_hostname_options[var.s3_origin_name != "" ? "use_name" : "use_host"]
  override_origin_policy = var.override_s3_origin_policy && var.s3_origin_name != "" && var.create

  function_association = { for type, func in var.cf_functions : type => { function_arn = aws_cloudfront_function.functions[type].arn } if func.assign }

  origin_access_identities = var.create_origin_access_identity ? {
    s3_bucket = "Access identity for CDN (${var.r53_hostname})"
  } : {}

  oac_key = "${var.r53_hostname}-origin-access-control"

  origin_access_control = var.create_origin_access_control ? {
    (local.oac_key) = {
      description      = "Origin access control for s3 bucket ${data.aws_s3_bucket.s3_origin[0].id}"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  } : {}

  origin_oai = var.create_origin_access_identity ? tomap({
    s3_origin = {
      domain_name = local.origin_hostname
      s3_origin_config = {
        origin_access_identity = "s3_bucket"
      }
    }
  }) : tomap({})
  origin_oac = var.create_origin_access_control ? tomap({
    s3_origin_oac = {
      domain_name           = data.aws_s3_bucket.s3_origin[0].bucket_domain_name
      origin_access_control = local.oac_key
    }
  }) : tomap({})

  r53_map = merge(tomap({
    single = {
      zone_id  = var.r53_zone_id
      hostname = var.r53_hostname
    }
  }), var.additional_zones)
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
  source = "github.com/terraform-aws-modules/terraform-aws-acm?ref=v5.0.1"
  tags   = merge(var.tags, { Region = "us-east-1" })

  domain_name               = local.r53_map["single"].hostname
  zone_id                   = local.r53_map["single"].zone_id
  validation_method         = "DNS"
  subject_alternative_names = [for s in values(local.r53_map) : s.hostname]
  create_route53_records    = false
  create_certificate        = var.create
  validate_certificate      = false
  providers = {
    aws = aws.us-east-1
  }
}

module "certificate-validations" {
  source   = "github.com/terraform-aws-modules/terraform-aws-acm?ref=v5.0.1"
  for_each = local.r53_map
  tags     = merge(var.tags, { Region = "us-east-1" })

  domain_name                               = each.value.hostname
  zone_id                                   = each.value.zone_id
  validation_method                         = "DNS"
  create_route53_records_only               = true && var.create
  create_certificate                        = false
  validate_certificate                      = false
  acm_certificate_domain_validation_options = [for s in module.certificate.acm_certificate_domain_validation_options : s if s.domain_name == each.value.hostname]
  providers = {
    aws = aws.us-east-1
  }

  dns_ttl = var.dns_ttl
}

module "cloudfront" {
  source  = "github.com/terraform-aws-modules/terraform-aws-cloudfront?ref=v3.4.0"
  tags    = var.tags
  aliases = [for s in values(local.r53_map) : s.hostname]

  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  retain_on_delete    = false
  wait_for_deployment = false

  create_distribution = var.create

  default_root_object = var.default_root_object

  create_origin_access_identity = var.create_origin_access_identity
  origin_access_identities      = local.origin_access_identities

  create_origin_access_control = var.create_origin_access_control
  origin_access_control        = local.origin_access_control

  logging_config = var.s3_logging_hostname == "" ? {} : {
    bucket          = var.s3_logging_hostname
    include_cookies = false
    prefix          = var.cdn_logging
  }

  origin = merge(local.origin_oai, local.origin_oac)
  default_cache_behavior = {
    target_origin_id       = keys(merge(local.origin_oai, local.origin_oac))[0]
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods      = ["GET", "HEAD", "OPTIONS"]
    cached_methods       = ["GET", "HEAD"]
    compress             = true
    query_string         = false
    function_association = local.function_association

  }

  viewer_certificate = {
    acm_certificate_arn      = module.certificate.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  custom_error_response = var.custom_error_response
}

data "aws_iam_policy_document" "oai_policy" {
  count = local.override_origin_policy && var.create_origin_access_identity ? 1 : 0

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.s3_origin[0].arn}${var.s3_origin_policy_restrict_access}"]

    principals {
      type        = "AWS"
      identifiers = [element(module.cloudfront.cloudfront_origin_access_identity_iam_arns, 0)]
    }
  }
}

data "aws_iam_policy_document" "oac_policy" {
  count = local.override_origin_policy && var.create_origin_access_control ? 1 : 0

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.s3_origin[0].arn}${var.s3_origin_policy_restrict_access}"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      values   = [module.cloudfront.cloudfront_distribution_arn]
      variable = "AWS:SourceArn"
    }
  }
}

resource "aws_s3_bucket_policy" "s3_origin_policy" {
  count = local.override_origin_policy ? 1 : 0

  bucket = data.aws_s3_bucket.s3_origin[0].id
  policy = var.create_origin_access_identity ? data.aws_iam_policy_document.oai_policy[0].json : data.aws_iam_policy_document.oac_policy[0].json
}

resource "aws_route53_record" "this" {
  count = var.create ? 1 : 0

  zone_id = var.r53_zone_id
  name    = var.r53_hostname
  type    = "A"

  alias {
    zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
    name    = module.cloudfront.cloudfront_distribution_domain_name

    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ipv6" {
  count = var.create && var.ipv6 ? 1 : 0

  zone_id = var.r53_zone_id
  name    = var.r53_hostname
  type    = "AAAA"

  alias {
    zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
    name    = module.cloudfront.cloudfront_distribution_domain_name

    evaluate_target_health = false
  }
}

resource "aws_route53_record" "additional_records" {
  for_each = var.additional_zones

  zone_id = each.value.zone_id
  name    = each.value.hostname
  type    = "A"

  alias {
    zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
    name    = module.cloudfront.cloudfront_distribution_domain_name

    evaluate_target_health = false
  }
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = module.certificate.acm_certificate_arn

  validation_record_fqdns = flatten([
    for val in module.certificate-validations : val.validation_route53_record_fqdns
  ])

  timeouts {
    create = var.validation_timeout
  }

  provider = aws.us-east-1
}

resource "aws_cloudfront_function" "functions" {
  for_each = var.cf_functions

  name    = each.value.name
  runtime = "cloudfront-js-1.0"
  comment = each.value.comment
  publish = true
  code    = each.value.code
}
