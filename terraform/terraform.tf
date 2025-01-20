terraform {
  cloud {
    organization = "MintTown"

    workspaces {
      name = "your-workspace-name"
    }
  }
}