########################################
# Policy - S3 
########################################
resource "aws_iam_policy" "s3" {
  name = "iam_policy_s3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:*"]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.jobs_bucket.arn,
          "${aws_s3_bucket.jobs_bucket.arn}/*"
        ]
      },
      {
        Action = ["s3:ListAllMyBuckets"]
        Effect = "Allow"
        Resource = ["*"]
      }
    ]
  })
}


########################################
# Policy - ECR 
########################################
resource "aws_iam_policy" "ecr" {
  name = "iam_policy_ecr"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["ecr:*"]
        Effect = "Allow"
        Resource = ["*"]
      }
    ]
  })
}

########################################
# Policy - Log 
########################################
resource "aws_iam_policy" "log" {
  name = "iam_policy_log"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
}


########################################
# Policy - SQS 
########################################
resource "aws_iam_policy" "sqs" {
  name = "iam_policy_sqs"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sqs:*"]
        Effect = "Allow"
        Resource = ["*"]
      }
    ]
  })
}

########################################
# Policy - Update Lambda 
########################################
resource "aws_iam_policy" "lambda_update" {
  name = "iam_policy_lambda_update"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["lambda:UpdateFunctionCode"]
        Effect = "Allow"
        Resource = ["*"]
      }
    ]
  })
}

########################################
# Policy - Snowflake_s3
########################################
resource "aws_iam_policy" "snowflake_access" {
  name = "iam_policy_snowflake_access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
              "s3:GetObject",
              "s3:GetObjectVersion"
            ]
        Effect = "Allow"
        Resource = ["${aws_s3_bucket.jobs_bucket.arn}/jobsdb/*"]
      },
      {
        Action = [
              "s3:ListBucket",
              "s3:GetBucketLocation"
            ]
        Effect = "Allow"
        Resource = ["${aws_s3_bucket.jobs_bucket.arn}"]

        Condition = {
          "StringLike" = {
            "s3:prefix" = "jobsdb/*"
          }
        }
      },
      {
        Action = [
              "ssm:GetParameter"
            ]
        Effect = "Allow"
        Resource = [
          data.aws_ssm_parameter.snowflake_user_arn.arn,
          data.aws_ssm_parameter.snowflake_external_id.arn
        ]
      }
    ]
  })
}

########################################
# IAM Role - Lambda
########################################
resource "aws_iam_role" "role_lambda_exec" {
  name               = "lambda_exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowLambdaExecute"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }

    ]
  })

  managed_policy_arns = [
    aws_iam_policy.s3.arn,
    aws_iam_policy.sqs.arn,
    aws_iam_policy.ecr.arn,
    aws_iam_policy.log.arn
    ]
}


########################################
# IAM Role - S3
########################################
resource "aws_iam_role" "role_s3_creator" {
  name               = "s3_creator"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowS3CreateObject"
        Principal = {
          AWS = "arn:aws:iam::402936097877:user/rws-adm-roger"
        }
      }
    ]
  })

  managed_policy_arns = [
    aws_iam_policy.s3.arn
    ]
}

########################################
# IAM User - rws-dev-meltano
########################################
resource "aws_iam_user" "rws_dev_meltano" {
  name = "rws-dev-meltano"
  permissions_boundary = aws_iam_policy.s3.arn
  force_destroy = true
  tags = {
    username = "meltano"
  }
}

data "aws_iam_policy_document" "rws_dev_meltano" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = [
          aws_s3_bucket.jobs_bucket.arn,
          "${aws_s3_bucket.jobs_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_user_policy" "rws_dev_meltano" {
  name   = "AllowMeltanoReadS3"
  user   = aws_iam_user.rws_dev_meltano.name
  policy = data.aws_iam_policy_document.rws_dev_meltano.json
}


########################################
# IAM Role - ECR_Creator
########################################
resource "aws_iam_role" "role_ecr_creator" {
  name               = "ecr_creator"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole", "sts:TagSession"]
        Effect = "Allow"
        Sid    = "AllowCreateECRImage"
        Principal = {
          AWS = "arn:aws:iam::402936097877:user/rws-adm-roger"
        }
      }
    ]
  })

  managed_policy_arns = [
    aws_iam_policy.ecr.arn,
    aws_iam_policy.lambda_update.arn
    ]
}


########################################
# IAM Role - Snowflake
########################################
resource "aws_iam_role" "role_snowflake_s3_reader" {
  name               = "snowflake_s3_reader"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Sid    = "AllowSnowflakeAccessS3"
        Principal = {
          "AWS": data.aws_ssm_parameter.snowflake_user_arn.value
        }
        Condition = {
          "StringEquals" = {
            "sts:ExternalId" = data.aws_ssm_parameter.snowflake_external_id.value
          }
        }
      }
    ]
  })

  managed_policy_arns = [
    aws_iam_policy.snowflake_access.arn
    ]
}
