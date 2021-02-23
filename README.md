# Terraform module for CDN

This module will create cdn endpoint with alias and SSL-certificate

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| aws | >= 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| r53\_hostname | Hostname for CloudFront alias | `string` | n/a | yes |
| r53\_zone\_id | Route53 zone ID to be used for hostname and certificate validation | `string` | n/a | yes |
| s3\_origin\_hostname | Hostname of S3-bucket to be used as origin | `string` | n/a | yes |
| s3\_logging\_hostname | Hostname of S3-bucket to be used for logging | `string` | `""` | no |
| tags | Map of custom tags for the provisioned resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| this\_certificate\_arn | ARN of ACM SSL certificate created for CloudFront |
| this\_cloudfront\_alias | Alias hostname of CloudFront distribution |
| this\_cloudfront\_arn | ARN of CloudFront distribution creates |
| this\_cloudfront\_hosted\_zone\_id | Hosted Zone ID CloudFront distribution uses |
| this\_cloudfront\_id | ID CloudFront distribution ID |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
