# SmartSpend AI - Terraform Module

This Terraform module deploys the SmartSpend AI infrastructure for AWS resource data collection.

## Quick Start

For the simplest deployment, use the quickstart file in the parent directory:

```bash
# Download the quickstart file
curl -O https://ssai-cloudformation-templates.s3.amazonaws.com/ssai-quickstart.tf

# Edit the file to add your external_id
# Then deploy:
terraform init
terraform apply
```

## Module Usage

```hcl
module "smartspend_ai" {
  # Option 1: GitHub (recommended)
  source = "github.com/smartspend-ai/terraform-aws-customer-stack?ref=v1.0.0"
  
  # Option 2: S3 bucket
  # source = "s3::https://ssai-terraform-modules.s3.amazonaws.com/ssai-customer-stack-v1.0.0.zip//terraform"

  # Required
  external_id = "your-external-id-from-ssai"
  stack_name  = "ssaiprod"  # lowercase alphanumeric only!

  # Optional
  collection_schedule       = "rate(1 day)"  # rate(1 hour), rate(6 hours), rate(12 hours), rate(1 day)
  enable_initial_collection = true
  tags = {
    Environment = "production"
  }
}

output "cross_account_role_arn" {
  value = module.smartspend_ai.cross_account_role_arn
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| external_id | External ID for secure cross-account access (provided by SmartSpend AI) | `string` | n/a | yes |
| stack_name | Stack name identifier (lowercase alphanumeric only) | `string` | n/a | yes |
| ssai_account_id | SmartSpend AI AWS Account ID for cross-account access | `string` | `"114656394878"` | no |
| collection_schedule | Schedule for running data collectors | `string` | `"rate(1 day)"` | no |
| lambda_package_bucket | S3 bucket containing Lambda deployment packages | `string` | `"ssai-lambda-packages"` | no |
| tags | Common tags to apply to all resources | `map(string)` | `{ Application = "SmartSpendAI" }` | no |
| enable_initial_collection | Whether to trigger initial data collection on first deploy | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_name | S3 bucket name for collected data |
| bucket_arn | S3 bucket ARN for collected data |
| cross_account_role_arn | IAM role ARN for SmartSpend AI cross-account access |
| aws_account_id | AWS Account ID where resources are deployed |
| athena_database | Glue database name for Athena queries |
| lambda_execution_role_arn | Lambda execution role ARN |
| all_collector_arns | Map of all collector Lambda function ARNs |
| eventbridge_rule_arns | Map of all EventBridge rule ARNs |

## Resources Created

This module creates the following AWS resources:

- **S3 Bucket**: Stores collected resource data with encryption and lifecycle policies
- **IAM Roles**: 
  - Lambda execution role with read access to AWS resources
  - Cross-account role for SmartSpend AI access
- **Lambda Functions**: 6 collector functions (EC2, RDS, S3, CUR, Orphaned, Inventory)
- **EventBridge Rules**: Scheduled triggers for each collector
- **Glue Database & Tables**: For Athena queries on collected data

## Important Notes

1. **Stack Name**: Must be lowercase alphanumeric only (no hyphens). Example: `ssaiprod`, `ssaitest`
2. **External ID**: Get this from your SmartSpend AI dashboard
3. **Region**: Deploy in the same region as your primary AWS resources
4. **S3 Bucket**: The data bucket has `prevent_destroy = true` to prevent accidental deletion

