terraform {
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
  region ="ap-south-1"
  access_key = "AKIA5PGRDO5EIKY2BDEG"
  secret_key = "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"
}


