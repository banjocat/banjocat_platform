resource "aws_codedeploy_app" "jack" {
    compute_platform    = "ECS"
    name                = "jack"
}

