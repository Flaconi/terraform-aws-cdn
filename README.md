# Terraform module for CDN

This module will create cdn endpoint with alias and SSL-certificate and optional Cloud Front functions.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_certificate"></a> [certificate](#module\_certificate) | github.com/terraform-aws-modules/terraform-aws-acm | v5.2.0 |
| <a name="module_certificate-validations"></a> [certificate-validations](#module\_certificate-validations) | github.com/terraform-aws-modules/terraform-aws-acm | v5.2.0 |
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | github.com/terraform-aws-modules/terraform-aws-cloudfront | v5.0.0 |
| <a name="module_s3_origin"></a> [s3\_origin](#module\_s3\_origin) | github.com/terraform-aws-modules/terraform-aws-s3-bucket | v5.6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate_validation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_function.functions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) | resource |
| [aws_route53_record.additional_records](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_iam_policy_document.oac_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.oai_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_r53_hostname"></a> [r53\_hostname](#input\_r53\_hostname) | Hostname for CloudFront alias | `string` | n/a | yes |
| <a name="input_r53_zone_id"></a> [r53\_zone\_id](#input\_r53\_zone\_id) | Route53 zone ID to be used for hostname and certificate validation | `string` | n/a | yes |
| <a name="input_s3_bucket_config"></a> [s3\_bucket\_config](#input\_s3\_bucket\_config) | S3 bucket configuration | <pre>object({<br>    create                   = optional(bool, true)<br>    lifecycle_rule           = optional(any, [])<br>    bucket                   = string<br>    versioning               = optional(map(string), {})<br>    control_object_ownership = optional(bool, false)<br>    object_ownership         = optional(string, "BucketOwnerPreferred")<br>  })</pre> | n/a | yes |
| <a name="input_additional_zones"></a> [additional\_zones](#input\_additional\_zones) | Map containing the Route53 Zone IDs and hostnames for additional domains | <pre>map(object({<br>    zone_id  = string<br>    hostname = string<br>  }))</pre> | `{}` | no |
| <a name="input_cdn_logging"></a> [cdn\_logging](#input\_cdn\_logging) | Prefix in s3 bucket for cdn logs | `string` | `""` | no |
| <a name="input_cf_functions"></a> [cf\_functions](#input\_cf\_functions) | The Cloud Front function configuration<br>    {type = object{}} ie. {"viewer-request" = object{}}<br>  *type:*<br>    Allowed cf event types are viewer-request and viewer-response<br>  *name:*<br>    Name of the function<br>  *comment:*<br>    Description of the function<br>  *code:*<br>    Source code of the function<br>  *assign:*<br>    true for associating the function with the cf distribution,<br>    false to remove the association. (to remove the cf function firstly set it<br>    to false to dissociate from the cf distribution) | <pre>map(object({<br>    name    = string<br>    comment = string<br>    code    = string<br>    assign  = bool<br>  }))</pre> | `{}` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether to create the resources | `bool` | `true` | no |
| <a name="input_create_origin_access_control"></a> [create\_origin\_access\_control](#input\_create\_origin\_access\_control) | Controls if CloudFront origin access control should be created | `bool` | `false` | no |
| <a name="input_create_origin_access_identity"></a> [create\_origin\_access\_identity](#input\_create\_origin\_access\_identity) | Controls if CloudFront origin access identity should be created | `bool` | `true` | no |
| <a name="input_custom_error_response"></a> [custom\_error\_response](#input\_custom\_error\_response) | One or more custom error response elements | <pre>list(object({<br>    error_caching_min_ttl = optional(number)<br>    error_code            = number<br>    response_code         = optional(number)<br>    response_page_path    = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL. | `string` | `null` | no |
| <a name="input_dns_ttl"></a> [dns\_ttl](#input\_dns\_ttl) | dns ttl for the cert validation records | `number` | `60` | no |
| <a name="input_ipv6"></a> [ipv6](#input\_ipv6) | create also alias records for ipv6 | `bool` | `false` | no |
| <a name="input_s3_logging_hostname"></a> [s3\_logging\_hostname](#input\_s3\_logging\_hostname) | Hostname of S3-bucket to be used for logging | `string` | `""` | no |
| <a name="input_s3_origin_policy_restrict_access"></a> [s3\_origin\_policy\_restrict\_access](#input\_s3\_origin\_policy\_restrict\_access) | Folder/files to add as an condition to the S3-bucket policy resource | `string` | `"/*"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of custom tags for the provisioned resources | `map(string)` | `{}` | no |
| <a name="input_validation_timeout"></a> [validation\_timeout](#input\_validation\_timeout) | Define maximum timeout to wait for the validation to complete | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certificate_arn"></a> [certificate\_arn](#output\_certificate\_arn) | ARN of ACM SSL certificate created for CloudFront |
| <a name="output_cloudfront_alias"></a> [cloudfront\_alias](#output\_cloudfront\_alias) | Alias hostname of CloudFront distribution |
| <a name="output_cloudfront_alias_additional_zones"></a> [cloudfront\_alias\_additional\_zones](#output\_cloudfront\_alias\_additional\_zones) | Alias hostname of CloudFront distribution for additional zones |
| <a name="output_cloudfront_arn"></a> [cloudfront\_arn](#output\_cloudfront\_arn) | ARN of CloudFront distribution creates |
| <a name="output_cloudfront_hosted_zone_id"></a> [cloudfront\_hosted\_zone\_id](#output\_cloudfront\_hosted\_zone\_id) | Hosted Zone ID CloudFront distribution uses |
| <a name="output_cloudfront_id"></a> [cloudfront\_id](#output\_cloudfront\_id) | ID CloudFront distribution ID |
| <a name="output_s3_origin"></a> [s3\_origin](#output\_s3\_origin) | S3 origin bucket output |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
