data "aws_route53_zone" "this" {
  name         = "${var.r53_hosted_zone}."
  private_zone = false
}

module "main" {
  source = "../.."

  s3_origin_hostname = var.s3_origin_hostname
  r53_zone_id        = data.aws_route53_zone.this.zone_id
  r53_hostname       = "${var.r53_hostname}.${var.r53_hosted_zone}"
  custom_error_response = [
    {
      error_caching_min_ttl = 0
      error_code            = 403
      response_code         = 200
      response_page_path    = "/index.html"
    },
    {
      error_caching_min_ttl = 0
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
    }
  ]
}
