# =============================================================================
# LAMBDA FUNCTIONS
# =============================================================================

# -----------------------------------------------------------------------------
# Collector Lambda Functions (using for_each)
# -----------------------------------------------------------------------------

resource "aws_lambda_function" "collectors" {
  for_each = local.collectors

  function_name = each.value.name
  role          = aws_iam_role.lambda_execution.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 900
  # CUR collector needs more memory (3008 MB) for processing large CUR files
  memory_size   = each.key == "cur" ? 3008 : 1024

  s3_bucket = var.lambda_package_bucket
  s3_key    = each.value.s3_key

  environment {
    variables = merge(
      {
        OUTPUT_BUCKET = aws_s3_bucket.data_bucket.id
        OUTPUT_PREFIX = "data"
      },
      # EC2 collector specific
      each.key == "ec2" ? {
        AWS_REGION_OVERRIDE = local.region
      } : {},
      # CUR collector specific
      each.key == "cur" ? {
        CUR_S3_BUCKET = "cur-standard-hourly-${local.account_id}"
        CUR_S3_PREFIX = "cur/"
      } : {}
    )
  }

  tags = merge(local.common_tags, {
    Collector = each.value.description
  })
}

# -----------------------------------------------------------------------------
# Initial Trigger Lambda Function
# -----------------------------------------------------------------------------

# Create the initial trigger Lambda code
data "archive_file" "initial_trigger" {
  type        = "zip"
  output_path = "${path.module}/files/initial_trigger.zip"

  source {
    content  = <<-EOF
import json
import boto3
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    """
    Triggers all collector Lambdas.
    Called by null_resource on first apply.
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    # List of collector Lambda function names from environment variables
    collector_functions = [
        os.environ.get('EC2_COLLECTOR_FUNCTION'),
        os.environ.get('RDS_COLLECTOR_FUNCTION'),
        os.environ.get('S3_COLLECTOR_FUNCTION'),
        os.environ.get('CUR_COLLECTOR_FUNCTION'),
        os.environ.get('ORPHANED_COLLECTOR_FUNCTION'),
        os.environ.get('INVENTORY_COLLECTOR_FUNCTION')
    ]
    # Filter out any None values
    collector_functions = [f for f in collector_functions if f]
    
    lambda_client = boto3.client('lambda')
    triggered = []
    errors = []
    
    for func_name in collector_functions:
        try:
            logger.info(f"Triggering Lambda: {func_name}")
            response = lambda_client.invoke(
                FunctionName=func_name,
                InvocationType='Event',  # Async invocation
                Payload=json.dumps({'source': 'initial-trigger'})
            )
            status_code = response.get('StatusCode', 0)
            logger.info(f"Triggered {func_name}, StatusCode: {status_code}")
            triggered.append(func_name)
        except Exception as e:
            error_msg = f"Failed to trigger {func_name}: {str(e)}"
            logger.error(error_msg)
            errors.append(error_msg)
    
    response_data = {
        'Message': f'Triggered {len(triggered)} collectors',
        'TriggeredFunctions': triggered,
        'Errors': errors
    }
    
    logger.info(f"Trigger complete. Response: {json.dumps(response_data)}")
    
    return response_data
EOF
    filename = "index.py"
  }
}

resource "aws_lambda_function" "initial_trigger" {
  function_name = "ssai-initial-trigger-${var.stack_name}"
  role          = aws_iam_role.initial_trigger.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 128

  filename         = data.archive_file.initial_trigger.output_path
  source_code_hash = data.archive_file.initial_trigger.output_base64sha256

  environment {
    variables = {
      EC2_COLLECTOR_FUNCTION       = aws_lambda_function.collectors["ec2"].function_name
      RDS_COLLECTOR_FUNCTION       = aws_lambda_function.collectors["rds"].function_name
      S3_COLLECTOR_FUNCTION        = aws_lambda_function.collectors["s3"].function_name
      CUR_COLLECTOR_FUNCTION       = aws_lambda_function.collectors["cur"].function_name
      ORPHANED_COLLECTOR_FUNCTION  = aws_lambda_function.collectors["orphaned"].function_name
      INVENTORY_COLLECTOR_FUNCTION = aws_lambda_function.collectors["inventory"].function_name
    }
  }

  tags = merge(local.common_tags, {
    Purpose = "InitialDataCollection"
  })
}

# -----------------------------------------------------------------------------
# Initial Data Collection Trigger (equivalent to CloudFormation Custom Resource)
# -----------------------------------------------------------------------------

# Use terraform_data resource to trigger initial collection only on first create
# This mimics CloudFormation CustomResource behavior (runs once on create, not on every apply)
resource "terraform_data" "initial_data_collection" {
  count = var.enable_initial_collection ? 1 : 0

  # Only re-trigger if the initial_trigger function ARN changes (effectively once on create)
  triggers_replace = [
    aws_lambda_function.initial_trigger.arn
  ]

  provisioner "local-exec" {
    command = <<-EOT
      aws lambda invoke \
        --function-name ${aws_lambda_function.initial_trigger.function_name} \
        --invocation-type Event \
        --payload '{"source": "initial-trigger", "RequestType": "Create"}' \
        --cli-binary-format raw-in-base64-out \
        /tmp/initial_trigger_response.json
    EOT
  }

  depends_on = [
    aws_lambda_function.collectors,
    aws_lambda_function.initial_trigger,
    aws_iam_role_policy.initial_trigger_invoke
  ]
}

