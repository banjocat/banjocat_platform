resource "aws_codecommit_repository" "jack" {
    repository_name = "jack"
    description = "Jack's website"
}

output "clone_url_ssh" {
    value = aws_codecommit_repository.jack.clone_url_ssh
    description = "ssh github for jackmuratore.com"
}
