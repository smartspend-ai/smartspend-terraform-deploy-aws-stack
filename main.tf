# =============================================================================
# SMARTSPEND AI - CUSTOMER AWS ACCOUNT INFRASTRUCTURE
# Terraform Module for AWS Resource Data Collection
# =============================================================================
# IMPORTANT: Use lowercase alphanumeric stack names only (e.g., ssaiprod, ssaitest)
# Hyphens will cause Glue database creation to fail.
#
# Usage:
#   module "smartspend_ai" {
#     source = "github.com/smartspend-ai/terraform-aws-customer-stack"
#
#     external_id = "your-external-id"
#     stack_name  = "ssaiprod"
#   }
# =============================================================================

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0.0"
    }
  }
}

# Note: Provider configuration should be done by the caller, not the module

# =============================================================================
# DATA SOURCES
# =============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# =============================================================================
# LOCAL VALUES
# =============================================================================

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  # Resource naming
  bucket_name        = "ssai-data-${var.stack_name}-${local.account_id}"
  glue_database_name = "smartspend_${var.stack_name}"

  # Common tags
  common_tags = merge(var.tags, {
    Purpose = "ResourceDataCollection"
  })

  # Lambda collectors configuration
  collectors = {
    ec2 = {
      name        = "ssai-ec2-collector-${var.stack_name}"
      s3_key      = "ec2-collector.zip"
      description = "EC2"
    }
    rds = {
      name        = "ssai-rds-collector-${var.stack_name}"
      s3_key      = "rds-collector.zip"
      description = "RDS"
    }
    s3 = {
      name        = "ssai-s3-collector-${var.stack_name}"
      s3_key      = "s3-collector.zip"
      description = "S3"
    }
    cur = {
      name        = "ssai-cur-collector-${var.stack_name}"
      s3_key      = "cur-collector.zip"
      description = "CUR"
    }
    orphaned = {
      name        = "ssai-orphaned-collector-${var.stack_name}"
      s3_key      = "orphaned-collector.zip"
      description = "Orphaned"
    }
    inventory = {
      name        = "ssai-inventory-collector-${var.stack_name}"
      s3_key      = "inventory-collector.zip"
      description = "Inventory"
    }
  }
}

