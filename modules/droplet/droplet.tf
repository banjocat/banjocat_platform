variable "number" {
  default = 1
}

variable "name" {
}

variable "zone" {
}

variable "region" {
    default = "nyc3"
}

variable "public_tcp_ports" {
    default = []
}

variable "domain" {
    default = ""
}

variable "cnames" {
    default = []
}

locals {
    domain = (var.domain != "" ? var.domain : "${var.name}.${var.zone}")
}



resource "digitalocean_droplet" "drop" {
  name               = "${var.name}0${count.index + 1}"
  size               = "s-1vcpu-1gb"
  image              = "ubuntu-18-04-x64"
  region             = var.region
  ipv6               = true
  count              = var.number
  private_networking = false
  tags = [
      "${var.name}"
  ]
  ssh_keys = [
    "c9:37:26:2e:b3:7c:f1:56:1f:72:f0:61:98:61:ed:65",
  ]
}

resource "digitalocean_firewall" "drop" {
  name = var.name

  tags = [
    var.name,
  ]

  droplet_ids = digitalocean_droplet.drop.*.id

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  dynamic "inbound_rule" {
      for_each = var.public_tcp_ports
      content {
          protocol = "tcp"
          port_range = inbound_rule.value
          source_addresses = ["0.0.0.0/0", "::/0"]
      }
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Mosh
  inbound_rule {
    protocol         = "udp"
    port_range       = "60000-61000"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "ns1_record" "domain" {
  zone   = var.zone
  domain = local.domain
  type   = "A"
  ttl    = 60
  answers {
    answer = digitalocean_droplet.drop[0].ipv4_address
  }
}

resource "ns1_record" "cname" {
  zone   = var.zone
  domain = var.cnames[count.index]
  type   = "CNAME"
  ttl    = 60
  answers {
    answer = local.domain
  }
  count = length(var.cnames)
}

