terraform {
  backend "s3" {
    bucket = "banjocat-s3-bucket"
    key    = "banjocat_terraform/prod/jackmuratore"
    region = "us-east-1"
  }
}

