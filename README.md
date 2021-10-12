# Terraform module for CDN

This module will create cdn endpoint with alias and SSL-certificate

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.26 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_certificate"></a> [certificate](#module\_certificate) | github.com/terraform-aws-modules/terraform-aws-acm | v3.2.0 |
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | github.com/terraform-aws-modules/terraform-aws-cloudfront | v2.7.0 |

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_r53_hostname"></a> [r53\_hostname](#input\_r53\_hostname) | Hostname for CloudFront alias | `string` | n/a | yes |
| <a name="input_r53_zone_id"></a> [r53\_zone\_id](#input\_r53\_zone\_id) | Route53 zone ID to be used for hostname and certificate validation | `string` | n/a | yes |
| <a name="input_s3_origin_hostname"></a> [s3\_origin\_hostname](#input\_s3\_origin\_hostname) | Hostname of S3-bucket to be used as origin | `string` | n/a | yes |
| <a name="input_cdn_logging"></a> [cdn\_logging](#input\_cdn\_logging) | Prefix in s3 bucket for cdn logs | `string` | `""` | no |
| <a name="input_s3_logging_hostname"></a> [s3\_logging\_hostname](#input\_s3\_logging\_hostname) | Hostname of S3-bucket to be used for logging | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of custom tags for the provisioned resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certificate_arn"></a> [certificate\_arn](#output\_certificate\_arn) | ARN of ACM SSL certificate created for CloudFront |
| <a name="output_cloudfront_alias"></a> [cloudfront\_alias](#output\_cloudfront\_alias) | Alias hostname of CloudFront distribution |
| <a name="output_cloudfront_arn"></a> [cloudfront\_arn](#output\_cloudfront\_arn) | ARN of CloudFront distribution creates |
| <a name="output_cloudfront_hosted_zone_id"></a> [cloudfront\_hosted\_zone\_id](#output\_cloudfront\_hosted\_zone\_id) | Hosted Zone ID CloudFront distribution uses |
| <a name="output_cloudfront_id"></a> [cloudfront\_id](#output\_cloudfront\_id) | ID CloudFront distribution ID |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
