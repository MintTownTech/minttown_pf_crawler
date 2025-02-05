variable "freecash_session_id" {
    description = "freecash_session_id"
    type        = string
}

variable "sns_topic_arn" {
  description = "SNS Topic ARN"
  type        = string
}

variable "bucket_name" {
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

variable "commit_hash" {
  description = "Hash file"
  type        = string
}