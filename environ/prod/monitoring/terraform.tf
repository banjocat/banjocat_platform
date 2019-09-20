terraform {
  backend "s3" {
    bucket = "banjocat-s3-bucket"
    key    = "banjocat_terraform/prod/monitoring"
    region = "us-east-1"
  }
}

