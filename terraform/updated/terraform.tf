terraform { 
  cloud { 
    organization = "MintTown" 
    workspaces { 
      name = "terraform_workspace_name_here" 
    } 
  } 
}
