variable "env" {
  description = "AWS Account ID for the Sandbox Account"
  type        = string
}

variable "crawler_aws_account_id" {
  type        = string
  description = "Crawler AWS Account ID"
  default     = "340258365836"
}

variable "commit_hash" {
  type        = string
  description = "Commit Hash"
}