terraform {
  backend "s3" {
    bucket = "831981619011-terraform-vars"
    key    = "pow-faucet-node/terraform.tfstate"
    region = "eu-north-1"
  }
}