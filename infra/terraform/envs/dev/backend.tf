terraform {
  cloud {
    organization = "atlas-studio"


    workspaces {
      name = "newerafestival-dev"
    }
  }
}
