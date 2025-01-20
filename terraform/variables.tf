variable "freecash_session_id" {
    description = "Session ID for Freecash API"
    type        = string
    default     = "xxx"
}

variable "crawler_aws_account_id" {
    description = "AWS Account ID for the Crawler Account"
    type        = string
    default     = "120849922260"
}


variable "sandbox_aws_account_id" {
    description = "AWS Account ID for the DEV Account"
    type        = string
    default     = "309217545237"
}

variable "organization_id" {
    description = "Organization ID"
    type        = string
    default     = "o-7572cdq8uc"
}

variable "bucket_name" {
    description = "Organization ID"
    type        = string
    default     = "minttown-pf-freecash-crawler-data-bucket"
}
