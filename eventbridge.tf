# =============================================================================
# EVENTBRIDGE RULES - Scheduled Triggers
# =============================================================================

# -----------------------------------------------------------------------------
# Collector Schedule Rules (using for_each)
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "collector_schedules" {
  for_each = local.collectors

  name                = "ssai-${each.key}-collector-schedule-${var.stack_name}"
  description         = "Triggers ${each.value.description} collector Lambda on schedule"
  schedule_expression = var.collection_schedule
  state               = "ENABLED"

  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "collector_targets" {
  for_each = local.collectors

  rule      = aws_cloudwatch_event_rule.collector_schedules[each.key].name
  target_id = "${each.value.description}CollectorTarget"
  arn       = aws_lambda_function.collectors[each.key].arn
}

resource "aws_lambda_permission" "collector_permissions" {
  for_each = local.collectors

  statement_id  = "AllowEventBridgeInvoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.collectors[each.key].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.collector_schedules[each.key].arn
}

