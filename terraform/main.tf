########################################
# VPC
########################################
resource "aws_vpc" "main_vpc" {
 cidr_block = "10.0.0.0/16"
 
 tags = {
   Name = "Career Skills VPC"
 }
}


########################################
# Private Subnets
########################################
resource "aws_subnet" "private_subnets" {
 count             = length(var.private_subnet_cidrs)
 vpc_id            = aws_vpc.main_vpc.id
 cidr_block        = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.aws_azs, count.index)
 
 tags = {
   Name = "Career Skills Private Subnet ${count.index + 1}"
 }
}

########################################
# Security Group
########################################
resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "Allow No traffic"
  vpc_id      = aws_vpc.main_vpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }

  tags = {
    Name = "Private Security Group"
  }
}


########################################
# Internet Gateway
########################################
resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.main_vpc.id
 
 tags = {
   Name = "Career Skills VPC IG"
 }
}

########################################
# VPC Route Table
########################################
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "Career Skills vpc-private-route-table"
  }
}

########################################
# VPC Route Table Association
########################################
resource "aws_route_table_association" "private_subnet_asso" {
 count = length(var.private_subnet_cidrs)
 subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
 route_table_id = aws_route_table.private_rt.id
}


########################################
# VPC Endpoint - s3
########################################
resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.main_vpc.id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = ["${aws_route_table.private_rt.id}"]

  tags = {
    Name = "Career Skills s3-vpc-endpoint"
  }
}


########################################
# S3 Bucket
########################################
resource "aws_s3_bucket" "jobs_bucket" {
  bucket = var.bucket_name
}

# Bucket versioning
resource "aws_s3_bucket_versioning" "jobs_bucket_versioning" {
  bucket = aws_s3_bucket.jobs_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

########################################
# Server Encryption with CMK
########################################
resource "aws_s3_bucket_server_side_encryption_configuration" "jobs_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.jobs_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
    }
    bucket_key_enabled = true

  }
}

########################################
# Bucket Lifecycle
########################################
resource "aws_s3_bucket_lifecycle_configuration" "jobs_bucket_lifecycle_rule" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.jobs_bucket_versioning]

  bucket = aws_s3_bucket.jobs_bucket.bucket

  rule {
    id = "rws-career-jobs-lifecycle"
    status = "Disabled"

    filter {
      prefix = "rws-career-jobs/"
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }
    
    noncurrent_version_expiration {
      noncurrent_days = 180
    }
  }
}

########################################
# No Public Access to S3
########################################
resource "aws_s3_bucket_public_access_block" "jobs_bucket_access" {
  bucket = aws_s3_bucket.jobs_bucket.id

  # Block public access
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}


########################################
# S3 Bucket Notification
########################################
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.jobs_bucket.id

  queue {
      queue_arn     = aws_sqs_queue.s3_queue_json_parquet.arn
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = "jobsdb/raw/"
      filter_suffix = ".json"
  }

  queue {
      id            = "trigger_sqs_snowflake"
      queue_arn     = data.aws_ssm_parameter.snowflake_sqs_arn.value
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = "jobsdb/parquet/"
      filter_suffix = ".parquet"
  }  

  depends_on = [aws_sqs_queue.s3_queue_json_parquet]

}

########################################
# Lambda Python
########################################
data "aws_ecr_repository" "json-parquet" {
  name = "json-parquet"
}

resource "aws_lambda_function" "lambda_func_json_to_parquet" {
  function_name   = "func_json_to_parquet"

  image_uri       = "${data.aws_ecr_repository.json-parquet.repository_url}:latest"
  role            = aws_iam_role.role_lambda_exec.arn
  package_type    = "Image"
  timeout         = 10 # seconds
  # vpc_config {
  #       subnet_ids  = [aws_subnet.private_subnets[0].id]
  #       security_group_ids = [aws_security_group.private_sg.id]
  #     }
}


########################################
# SQS Trigger
########################################
resource "aws_lambda_event_source_mapping" "sqs_trigger_lambda" {
  event_source_arn = aws_sqs_queue.s3_queue_json_parquet.arn
  function_name    = aws_lambda_function.lambda_func_json_to_parquet.arn
  depends_on       = [aws_sqs_queue.s3_queue_json_parquet]
  enabled          = true
  batch_size       = 1
}

#######################################
# SQS Queue
#######################################
resource "aws_sqs_queue" "s3_queue_json_parquet" {
  name                      = "s3-queue-transforming-json"
  delay_seconds             = 5
  visibility_timeout_seconds = 30
  max_message_size          = 262144
  message_retention_seconds = 60
  receive_wait_time_seconds = 2
  sqs_managed_sse_enabled = true
}

data "aws_iam_policy_document" "sqs_policy" {
  statement {
    sid    = "AllowS3UseSQS"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.s3_queue_json_parquet.arn]

  }
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.s3_queue_json_parquet.id
  policy    = data.aws_iam_policy_document.sqs_policy.json
}

data "aws_ssm_parameter" "snowflake_sqs_arn" {
	name = "snowflake_sqs_arn"
	with_decryption = false
}

data "aws_ssm_parameter" "snowflake_user_arn" {
	name = "snowflake_user_arn"
	with_decryption = false
}

data "aws_ssm_parameter" "snowflake_external_id" {
	name = "snowflake_external_id"
	with_decryption = false
}