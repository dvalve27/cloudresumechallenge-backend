terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "cloudresumechallenege" # Create this bucket manually once
    key    = "cloudresumechallenge/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region             = "us-west-2"
  shared_config_files      = ["../.aws/conf"]
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  shared_config_files      = ["../.aws/conf"]
}