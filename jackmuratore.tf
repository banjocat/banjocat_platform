variable ny_jack_count {
    default = 1
}
resource "digitalocean_droplet" "jackmuratore" {
    name = "jack0${count.index + 1}"
    size = "s-1vcpu-1gb"
    image = "ubuntu-18-04-x64"
    region = "nyc3"
    ipv6 = true
    count = "${var.ny_jack_count}"
    private_networking = false
    ssh_keys = [
        "c9:37:26:2e:b3:7c:f1:56:1f:72:f0:61:98:61:ed:65"
        ]
    tags = [
        "jackmuratore",
        "jack"
    ]
}

resource "digitalocean_firewall" "jack" {
    name = "jack"

    tags = [
        "jack"
    ]

    droplet_ids = ["${digitalocean_droplet.jackmuratore.*.id}"]

    outbound_rule {
        protocol = "tcp"
        port_range = "1-65535"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }

    outbound_rule {
        protocol = "udp"
        port_range = "1-65535"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }

    outbound_rule {
        protocol                = "icmp"
        destination_addresses   = ["0.0.0.0/0", "::/0"]
    }

    inbound_rule {
        protocol                = "icmp"
        source_addresses   = ["0.0.0.0/0", "::/0"]
    }

    inbound_rule {
        protocol = "tcp"
        port_range = "443"
        source_addresses = ["0.0.0.0/0", "::/0"]
    }

    inbound_rule {
        protocol = "tcp"
        port_range = "80"
        source_addresses = ["0.0.0.0/0", "::/0"]
    }

    inbound_rule {
        protocol = "tcp"
        port_range = "22"
        source_addresses = ["0.0.0.0/0", "::/0"]
    }

    inbound_rule {
        protocol = "tcp"
        port_range = "10050-10051"
        source_tags = [
            "short",
            "data",
            "jack"
        ]
    }

    inbound_rule {
        protocol = "tcp"
        port_range = "10050-10051"
        source_addresses = ["142.93.202.135"]
    }

    # Mosh
    inbound_rule {
        protocol = "udp"
        port_range = "60000-61000"
        source_addresses = ["0.0.0.0/0", "::/0"]
    }
}


resource "ns1_record" "jackmuratore" {
    zone = "${ns1_zone.jackmuratore.zone}"
    domain = "${ns1_zone.jackmuratore.zone}"
    type = "A"
    ttl = 60
    answers {
        answer = "${digitalocean_droplet.jackmuratore.0.ipv4_address}"
    }
}
resource "ns1_record" "jackmuratore_cname" {
    zone = "${ns1_zone.jackmuratore.zone}"
    domain = "*.${ns1_zone.jackmuratore.zone}"
    type = "CNAME"
    ttl = 60
    answers {
        answer = "${ns1_zone.jackmuratore.zone}"
    }
}
