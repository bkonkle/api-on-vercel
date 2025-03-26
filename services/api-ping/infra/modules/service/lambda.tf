module "label_publisher_kinesis" {
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.25.0"
  namespace = var.namespace
  stage     = var.environment
  name      = "publisher-kinesis"
  tags      = local.common_tags
  delimiter = "-"
}

module "lambda_publisher_kinesis" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = module.label_publisher_kinesis.id
  description   = "The Kinesis domain event Publisher"
  handler       = "bootstrap"
  runtime       = "provided.al2023"

  source_path = "../../target/lambda/publisher_kinesis"

  environment_variables = {
    EVENT_STREAM_NAME = aws_kinesis_stream.event_stream.name
  }

  attach_dead_letter_policy = true
  dead_letter_target_arn    = module.sqs_publisher_kinesis_dead_letter.queue_arn

  event_source_mapping = {
    dynamodb = {
      event_source_arn           = module.dynamodb_event_log.dynamodb_table_stream_arn
      starting_position          = "LATEST"
      maximum_retry_attempts     = 5
      destination_arn_on_failure = module.sqs_publisher_kinesis_dead_letter.queue_arn
    }
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect = "Allow",
      actions = [
        "dynamodb:GetRecords",
        "dynamodb:GetShardIterator",
        "dynamodb:DescribeStream",
        "dynamodb:ListStreams"
      ]
      resources = [module.dynamodb_event_log.dynamodb_table_stream_arn]
    }
    kinesis = {
      effect = "Allow",
      actions = [
        "kinesis:PutRecord",
        "kinesis:PutRecords"
      ]
      resources = [aws_kinesis_stream.event_stream.arn]
    },
  }

  cloudwatch_logs_retention_in_days = 7
}
