terraform {
  cloud {
    organization = "MintTown"

    workspaces {
      name = "minttown_pf_crawler"
    }
  }
}