variable "organization_id" {
    description = "Session ID for Freecash API"
    type        = string
}
variable "bucket_name" {
    description = "AWS Account ID for the Crawler Account"
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

variable "sandbox_aws_account_id" {
    description = "AWS Account ID for the Sandbox Account"
    type        = string
}

variable "env" {
    description = "AWS Account ID for the Sandbox Account"
    type        = string
}

variable "tfc_aws_audience" {
  type        = string
  default     = "aws.workload.identity"
  description = "The audience value to use in run identity tokens"
}

variable "tfc_hostname" {
  type        = string
  default     = "app.terraform.io"
  description = "The hostname of the TFC or TFE instance you'd like to use with AWS"
}

variable "tfc_organization_name" {
  type        = string
  default     = "MintTown"
  description = "The name of your Terraform Cloud organization"
}

variable "tfc_project_name" {
  type        = string
  default     = "minttown_pf_crawler"
  description = "The project under which a workspace will be created"
}

variable "TFC_AWS_PROVIDER_AUTH" {
  type        = bool
  default     = true
  description = "The project under which a workspace will be created"
}

variable "TFC_AWS_RUN_ROLE_ARN" {
  type        = string
  default     = "arn:aws:iam::340258365836:role/minttown-pf-oidc-terraform-cloud-role"
  description = "The project under which a workspace will be created"
}
