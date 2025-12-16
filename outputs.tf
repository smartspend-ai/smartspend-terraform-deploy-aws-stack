# =============================================================================
# OUTPUTS
# =============================================================================

output "bucket_name" {
  description = "S3 bucket name for collected data"
  value       = aws_s3_bucket.data_bucket.id
}

output "bucket_arn" {
  description = "S3 bucket ARN for collected data"
  value       = aws_s3_bucket.data_bucket.arn
}

output "cross_account_role_arn" {
  description = "IAM role ARN for SmartSpend AI cross-account access"
  value       = aws_iam_role.cross_account_access.arn
}

output "aws_account_id" {
  description = "AWS Account ID where resources are deployed"
  value       = local.account_id
}

output "athena_database" {
  description = "Glue database name for Athena queries"
  value       = aws_glue_catalog_database.smartspend.name
}

output "lambda_execution_role_arn" {
  description = "Lambda execution role ARN"
  value       = aws_iam_role.lambda_execution.arn
}

output "ec2_collector_function_arn" {
  description = "EC2 Collector Lambda function ARN"
  value       = aws_lambda_function.collectors["ec2"].arn
}

output "rds_collector_function_arn" {
  description = "RDS Collector Lambda function ARN"
  value       = aws_lambda_function.collectors["rds"].arn
}

output "s3_collector_function_arn" {
  description = "S3 Collector Lambda function ARN"
  value       = aws_lambda_function.collectors["s3"].arn
}

output "cur_collector_function_arn" {
  description = "CUR Collector Lambda function ARN"
  value       = aws_lambda_function.collectors["cur"].arn
}

output "orphaned_collector_function_arn" {
  description = "Orphaned Resources Collector Lambda function ARN"
  value       = aws_lambda_function.collectors["orphaned"].arn
}

output "inventory_collector_function_arn" {
  description = "Resource Inventory Collector Lambda function ARN"
  value       = aws_lambda_function.collectors["inventory"].arn
}

output "initial_trigger_function_arn" {
  description = "Initial Trigger Lambda function ARN"
  value       = aws_lambda_function.initial_trigger.arn
}

# Additional useful outputs
output "all_collector_arns" {
  description = "Map of all collector Lambda function ARNs"
  value       = { for k, v in aws_lambda_function.collectors : k => v.arn }
}

output "eventbridge_rule_arns" {
  description = "Map of all EventBridge rule ARNs"
  value       = { for k, v in aws_cloudwatch_event_rule.collector_schedules : k => v.arn }
}

