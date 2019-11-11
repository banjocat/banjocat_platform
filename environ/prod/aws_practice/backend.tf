terraform {
  backend "s3" {
    bucket = "banjocat-s3-bucket"
    key    = "banjocat_terraform/prod/aws_practice"
    region = "us-east-1"
  }
}

