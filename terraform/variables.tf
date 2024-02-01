variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "rws-career-jobs"

  validation {
    condition = length(var.bucket_name) > 2 && length(var.bucket_name) < 64 && can(regex("^[0-9A-Za-z-]+$", var.bucket_name))
    error_message = "The bucket_name must follow naming rules. Check them out at: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html."
  }
}

variable "kms_key_alias" {
  description = "The KMS key used for encryption"
  type = string
  default = "rws-dev-kms-key-s3"
}

variable "access_logging_bucket_name" {
  description = "S3 bucket name for access logging storage"
  type        = string
  default     = "rws-jobs-logging"
}

variable "kms_s3_key_arn" {
  description = "The arn of KMS key used for S3 Encrypt and Decrypt"
  type        = string
  default     = "arn:aws:kms:ap-southeast-1:668479700230:key/75c5f843-d6d7-4957-991f-8d377750fc65"
}
 
variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "aws_azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "lambda_python_folder" {
  type        = string
  description = "The relative path to the source of the lambda python script"
  default     = "./lambda_script/python"
}

variable "lambda_concurrent_executions" {
  type        = number
  description = "The concurrent for Lambda"
  default     = 10
}