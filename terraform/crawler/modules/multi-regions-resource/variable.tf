variable "freecash_session_id" {
    description = "freecash_session_id"
    type        = string
}

variable "sns_topic_arn" {
  description = "SNS Topic ARN"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 Bucket Name"
  type        = string
}

variable "crawler_function_role" {
  description = "Crawler Function Role"
  type        = string
}

variable "country" {
  description = "Country"
  type        = string
}

variable "hash_file" {
  description = "Hash file"
  type        = string
}