terraform { 
  cloud { 
    organization = var.TF_ORG
    workspaces { 
      name = var.TFC_AWS_WORKSPACE_NAME 
    } 
  } 
}
