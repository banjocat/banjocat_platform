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

variable "inbound_services" {
    default = []
}


variable "cnames" {
    default = []
}

variable "tags" {
    default = []
}




resource "digitalocean_droplet" "drop" {
  name               = "${var.name}0${count.index + 1}"
  size               = "s-1vcpu-1gb"
  image              = "ubuntu-18-04-x64"
  region             = var.region
  ipv6               = true
  count              = var.number
  private_networking = false
  tags = concat(["${var.name}"], var.tags)
  ssh_keys = [
    "c9:37:26:2e:b3:7c:f1:56:1f:72:f0:61:98:61:ed:65",
  ]
  provisioner "remote-exec" {
      connection {
          type = "ssh"
          user = "root"
          private_key = file("~/.ssh/id_rsa")
          host = digitalocean_droplet.drop[count.index].ipv4_address
      }
      inline = [
          "apt-get update",
          "apt-get -y upgrade",
          "apt-get install -y mosh curl python3-dev python3-pip python-dev python-pip apt-transport-https ca-certificates gnupg-agent software-properties-common",
          "apt-get remove docker docker-engine docker.io containerd runc",
          "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -",
          "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
          "apt-get update",
          "apt-get install -y docker-ce docker-ce-cli containerd.io"
      ]
  }
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
}
