variable "organization_id" {
    description = "Session ID for Freecash API"
    type        = string
}
variable "bucket_name" {
    description = "AWS Account ID for the Crawler Account"
    type        = string
}
variable "TFC_AWS_RUN_ROLE_ARN" {
    description = "AWS Account ID for the DEV Account"
    type        = string
}

variable "freecash_session_id" {
    description = "AWS Account ID for the DEV Account"
    type        = string
}

variable "crawler_aws_account_id" {
    description = "AWS Account ID for the Crawler Account"
    type        = string
}

variable "env" {
    description = "AWS Account ID for the Sandbox Account"
    type        = string
}