variable "do_token" {}
variable "ny_short_count" {
    default = 1
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "${var.do_token}"
}
