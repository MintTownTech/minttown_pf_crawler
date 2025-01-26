variable "organization_id" {
    description = "Session ID for Freecash API"
    type        = string
}
variable "bucket_name" {
    description = "AWS Account ID for the Crawler Account"
    type        = string
}

variable "crawler_aws_account_id" {
    description = "AWS Account ID for the Crawler Account [dev account]"
    type        = string
}

variable "sandbox_aws_account_id" {
    description = "AWS Account ID for the Sandbox Account"
    type        = string
}

variable "minttown_aws_account_ids" {
  description = "Array of AWS Account IDs for the Sandbox Account"
  type        = list(string)
}

variable "env" {
    description = "Environemnt name"
    type        = string
}

variable "tfc_aws_audience" {
  type        = string
  description = "The audience value to use in run identity tokens"
}

variable "tfc_hostname" {
  type        = string
  description = "The hostname of the TFC or TFE instance you'd like to use with AWS"
}

variable "tfc_organization_name" {
  type        = string
  description = "The name of your Terraform Cloud organization"
}

variable "tfc_project_name" {
  type        = string
  description = "The project under which a workspace will be created"
}

variable "TFC_AWS_PROVIDER_AUTH" {
  type        = bool
  description = "The project under which a workspace will be created"
}

variable "TFC_AWS_RUN_ROLE_ARN" {
  type        = string
  description = "The project under which a workspace will be created"
}

variable "TFC_AWS_WORKSPACE_NAME" {
  type        = string
  description = "The project under which a workspace will be created"
}

variable "TF_ORG" {
  type        = string
  description = "The project under which a workspace will be created"
}

variable "regions" {
  description = "List of AWS regions to deploy the Lambda function"
  type        = list(string)
}
