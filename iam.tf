# =============================================================================
# IAM ROLES AND POLICIES
# =============================================================================

# -----------------------------------------------------------------------------
# Lambda Execution Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "lambda_execution" {
  name = "ssai-lambda-execution-role-${var.stack_name}-${local.region}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

# Attach AWS managed policy for Lambda basic execution
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom policy for data collection
resource "aws_iam_role_policy" "lambda_data_collection" {
  name = "SSAIDataCollectionPolicy"
  role = aws_iam_role.lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 Write Access
      {
        Sid    = "S3WriteAccess"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.data_bucket.arn,
          "${aws_s3_bucket.data_bucket.arn}/*"
        ]
      },
      # EC2 Read Access
      {
        Sid    = "EC2ReadAccess"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:GetConsoleOutput"
        ]
        Resource = "*"
      },
      # RDS Read Access
      {
        Sid    = "RDSReadAccess"
        Effect = "Allow"
        Action = [
          "rds:Describe*",
          "rds:ListTagsForResource"
        ]
        Resource = "*"
      },
      # S3 Read Access (for bucket inventory)
      {
        Sid    = "S3ReadAccess"
        Effect = "Allow"
        Action = [
          "s3:GetBucket*",
          "s3:GetObject*",
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
          "s3:GetEncryptionConfiguration",
          "s3:GetLifecycleConfiguration",
          "s3:GetReplicationConfiguration"
        ]
        Resource = "*"
      },
      # CloudWatch Read Access
      {
        Sid    = "CloudWatchReadAccess"
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      },
      # Cost Explorer Read Access
      {
        Sid    = "CostExplorerReadAccess"
        Effect = "Allow"
        Action = [
          "ce:GetCostAndUsage",
          "ce:GetCostForecast",
          "ce:GetReservationUtilization",
          "ce:GetSavingsPlansUtilization"
        ]
        Resource = "*"
      },
      # Auto Scaling Read Access
      {
        Sid    = "AutoScalingReadAccess"
        Effect = "Allow"
        Action = [
          "autoscaling:Describe*"
        ]
        Resource = "*"
      },
      # ELB Read Access
      {
        Sid    = "ELBReadAccess"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:Describe*"
        ]
        Resource = "*"
      },
      # Resource Explorer Read Access
      {
        Sid    = "ResourceExplorerReadAccess"
        Effect = "Allow"
        Action = [
          "resource-explorer-2:Search",
          "resource-explorer-2:ListViews",
          "resource-explorer-2:GetView"
        ]
        Resource = "*"
      },
      # STS for Account Info
      {
        Sid    = "STSAccess"
        Effect = "Allow"
        Action = [
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      },
      # Glue Read Access
      {
        Sid    = "GlueReadAccess"
        Effect = "Allow"
        Action = [
          "glue:GetDatabase*",
          "glue:GetTable*",
          "glue:GetPartition*"
        ]
        Resource = "*"
      },
      # Pricing API Access
      {
        Sid    = "PricingAccess"
        Effect = "Allow"
        Action = [
          "pricing:GetProducts",
          "pricing:DescribeServices"
        ]
        Resource = "*"
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Cross-Account Access Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "cross_account_access" {
  name = "ssai-cross-account-role-${var.stack_name}-${local.region}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.ssai_account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

# Cross-account data access policy
resource "aws_iam_role_policy" "cross_account_data_access" {
  name = "SSAICrossAccountDataAccess"
  role = aws_iam_role.cross_account_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 Access to Data Bucket (read + write for Athena query results)
      {
        Sid    = "S3DataBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.data_bucket.arn,
          "${aws_s3_bucket.data_bucket.arn}/*"
        ]
      },
      # Athena Query Access
      {
        Sid    = "AthenaAccess"
        Effect = "Allow"
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:StopQueryExecution"
        ]
        Resource = "*"
      },
      # Glue Catalog Access
      {
        Sid    = "GlueCatalogAccess"
        Effect = "Allow"
        Action = [
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetPartition",
          "glue:GetPartitions"
        ]
        Resource = [
          "arn:aws:glue:${local.region}:${local.account_id}:catalog",
          "arn:aws:glue:${local.region}:${local.account_id}:database/${local.glue_database_name}",
          "arn:aws:glue:${local.region}:${local.account_id}:table/${local.glue_database_name}/*"
        ]
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Initial Trigger Lambda Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "initial_trigger" {
  name = "ssai-initial-trigger-role-${var.stack_name}-${local.region}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

# Attach AWS managed policy for Lambda basic execution
resource "aws_iam_role_policy_attachment" "initial_trigger_basic_execution" {
  role       = aws_iam_role.initial_trigger.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Policy to invoke collector Lambdas
resource "aws_iam_role_policy" "initial_trigger_invoke" {
  name = "InvokeCollectorLambdas"
  role = aws_iam_role.initial_trigger.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "InvokeLambdas"
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [for k, v in aws_lambda_function.collectors : v.arn]
      }
    ]
  })
}

