# Example usage for cdn-module

A simple example

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.70 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| r53\_hosted\_zone | Route53 hosted zone name | `string` | n/a | yes |
| r53\_hostname | Route53 subdomain hostname | `string` | n/a | yes |
| s3\_origin\_hostname | Hostname of S3-bucket to be used as origin | `string` | n/a | yes |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
