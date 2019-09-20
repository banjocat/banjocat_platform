variable "ns1_apikey" {
}

provider "ns1" {
  apikey = var.ns1_apikey
}

# Main zones
resource "ns1_zone" "jackmuratore" {
  zone = "jackmuratore.com"
  ttl  = 60
}

