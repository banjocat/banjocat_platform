module "control" {
    source = "../../../modules/droplet"
    name = "control"
    public_tcp_ports = []
    zone = ns1_zone.peanut.zone
    number = 3
    inbound_services = [
        # nomad tcp
        {
            protocol = "tcp"
            port_range = 4646
            source_tags = ["control"]
        },
        {
            protocol = "tcp"
            port_range = 4647
            source_tags = ["control"]
        },
        {
            protocol = "tcp"
            port_range = 4648
            source_tags = ["control"]
        },
        # nomad udp
        {
            protocol = "udp"
            port_range = 4648
            source_tags = ["control"]
        },
        # consul tcp
        {
            protocol = "tcp"
            port_range = 8301
            source_tags = ["control"]
        },
        {
            protocol = "tcp"
            port_range = 8300
            source_tags = ["control"]
        },
        {
            protocol = "tcp"
            port_range = 8302
            source_tags = ["control"]
        },
        # consul udp
        {
            protocol = "udp"
            port_range = 8301
            source_tags = ["control"]
        },
        {
            protocol = "udp"
            port_range = 8302
            source_tags = ["control"]
        },
        # vault
        {
            protocol = "tcp"
            port_range = 8201
            source_tags = ["control"]
        },

    ]
}
