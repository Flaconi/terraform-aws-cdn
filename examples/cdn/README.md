# Example usage for cdn-module

A simple example

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
| <a name="module_main"></a> [main](#module\_main) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_r53_hosted_zone"></a> [r53\_hosted\_zone](#input\_r53\_hosted\_zone) | Route53 hosted zone name | `string` | n/a | yes |
| <a name="input_r53_hostname"></a> [r53\_hostname](#input\_r53\_hostname) | Route53 subdomain hostname | `string` | n/a | yes |
| <a name="input_s3_origin_hostname"></a> [s3\_origin\_hostname](#input\_s3\_origin\_hostname) | Hostname of S3-bucket to be used as origin | `string` | n/a | yes |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
