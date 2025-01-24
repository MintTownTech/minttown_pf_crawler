terraform { 
  cloud { 
    organization = "MintTown" 
    workspaces { 
      name = "minttown_pf_infra_crawler_sb" 
    } 
  } 
}
