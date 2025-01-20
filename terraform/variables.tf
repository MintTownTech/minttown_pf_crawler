variable "freecash_session_id" {
    description = "Session ID for Freecash API"
    type        = string
}

variable "crawler_account" {
    description = "AWS Account ID for the Crawler Account"
    type        = string
    default     = "120849922260"
}


variable "dev_account_id" {
    description = "AWS Account ID for the DEV Account"
    type        = string
    default     = "309217545237"
}
