# =============================================================================
# TERRAFORM MODULE VARIABLES
# =============================================================================
# SmartSpend AI Customer Stack - Input Variables
#
# Required variables:
#   - external_id: Provided by SmartSpend AI for secure cross-account access
#   - stack_name: Unique identifier for this deployment (lowercase alphanumeric only)
# =============================================================================

# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "external_id" {
  type        = string
  description = "External ID for secure cross-account access (provided by SmartSpend AI)"
  sensitive   = true

  validation {
    condition     = length(var.external_id) > 0
    error_message = "External ID cannot be empty."
  }
}

variable "stack_name" {
  type        = string
  description = "Stack name identifier (use lowercase alphanumeric only - hyphens will cause Glue database creation to fail)"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.stack_name))
    error_message = "Stack name must be lowercase alphanumeric only (no hyphens or special characters)."
  }
}

# -----------------------------------------------------------------------------
# Optional Variables
# -----------------------------------------------------------------------------

variable "ssai_account_id" {
  type        = string
  default     = "114656394878"
  description = "SmartSpend AI AWS Account ID for cross-account access"
}

variable "collection_schedule" {
  type        = string
  default     = "rate(1 day)"
  description = "Schedule for running data collectors (CloudWatch Events rate expression)"

  validation {
    condition = contains([
      "rate(1 hour)",
      "rate(6 hours)",
      "rate(12 hours)",
      "rate(1 day)"
    ], var.collection_schedule)
    error_message = "Collection schedule must be one of: rate(1 hour), rate(6 hours), rate(12 hours), rate(1 day)."
  }
}

variable "lambda_package_bucket" {
  type        = string
  default     = "ssai-lambda-packages"
  description = "S3 bucket containing Lambda deployment packages"
}

variable "tags" {
  type = map(string)
  default = {
    Application = "SmartSpendAI"
  }
  description = "Common tags to apply to all resources"
}

variable "enable_initial_collection" {
  type        = bool
  default     = true
  description = "Whether to trigger initial data collection on first deploy"
}

