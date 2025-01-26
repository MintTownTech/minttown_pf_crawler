module "base-resources" {
  source                   = "./modules/base-resources"
  organization_id          = var.organization_id
  bucket_name              = var.bucket_name
  crawler_aws_account_id   = var.crawler_aws_account_id
  sandbox_aws_account_id   = var.sandbox_aws_account_id
  minttown_aws_account_ids = var.minttown_aws_account_ids
  env                      = var.env
  tfc_aws_audience         = var.tfc_aws_audience
  tfc_hostname             = var.tfc_hostname
  tfc_organization_name    = var.tfc_organization_name
  tfc_project_name         = var.tfc_project_name
  TFC_AWS_PROVIDER_AUTH    = var.TFC_AWS_PROVIDER_AUTH
  TFC_AWS_RUN_ROLE_ARN     = var.TFC_AWS_RUN_ROLE_ARN
  TFC_AWS_WORKSPACE_NAME   = var.TFC_AWS_WORKSPACE_NAME
  TF_ORG                   = var.TF_ORG
  regions                  = var.regions

  providers = {
    aws = aws
  }
}

# Lambda function
module "multi-regions-resource" {
  source                = "./modules/multi-regions-resource"
  freecash_session_id   = var.freecash_session_id
  sns_topic_arn         = module.base-resources.sns_topic_arn
  s3_bucket_name        = module.base-resources.s3_bucket_name
  crawler_function_role = module.base-resources.crawler_function_role
  country               = "eu-west-2"

  providers = {
    aws = aws.eu-west-2
  }
}
