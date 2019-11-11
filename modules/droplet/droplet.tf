variable "number" {
  default = 1
}

variable "name" {
}

variable "groups" {
    default = []
}

variable "zone" {
}

variable "region" {
    default = "nyc3"
}

variable "public_tcp_ports" {
    default = []
}

variable "inbound_services" {
    default = []
}


variable "cnames" {
    default = []
}

variable "tags" {
    default = []
}

variable "size" {
    default = "s-1vcpu-1gb"
}


resource "digitalocean_droplet" "drop" {
  name               = format("%s%02g", var.name, count.index + 1)
  size               = var.size
  image              = "ubuntu-18-04-x64"
  region             = var.region
  ipv6               = true
  count              = var.number
  private_networking = false
  tags = concat(["${var.name}"], var.tags)
  ssh_keys = [
    "c9:37:26:2e:b3:7c:f1:56:1f:72:f0:61:98:61:ed:65",
  ]
}

resource "digitalocean_firewall" "drop" {
  name = var.name

  tags = concat([var.name], var.groups)

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

  dynamic "inbound_rule" {
      for_each = var.inbound_services
      content {
        protocol = inbound_rule.value["protocol"]
        port_range = inbound_rule.value["port_range"]
        source_tags = inbound_rule.value["source_tags"]
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
  depends_on = [digitalocean_droplet.drop]
}

resource "ns1_record" "domain" {
  zone   = var.zone
  domain = format("%s%02g.%s", var.name, count.index + 1, var.zone)
  type   = "A"
  ttl    = 60
  answers {
    answer = digitalocean_droplet.drop[count.index].ipv4_address
  }
  count = var.number
  depends_on = [digitalocean_droplet.drop]
}

resource "ns1_record" "type_domain" {
    zone = var.zone
    domain = format("%s.%s", var.name, var.zone)
    type = "A"
    ttl = 60
    dynamic "answers" {
        for_each = digitalocean_droplet.drop
        content {
            answer = answers.value["ipv4_address"]
        }
    }
  depends_on = [digitalocean_droplet.drop]
}
