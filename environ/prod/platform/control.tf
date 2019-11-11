module "control" {
    source = "../../../modules/droplet"
    name = "control"
    public_tcp_ports = []
    zone = ns1_zone.peanut.zone
    number = 1
    inbound_services = [
        # nomad
        {
            protocol = "tcp"
            port_range = 4647
            source_tags = ["plat", "control"]
        },
        # consul tcp
        {
            protocol = "tcp"
            port_range = 8301
            source_tags = ["plat", "control"]
        },
        {
            protocol = "tcp"
            port_range = 8300
            source_tags = ["plat", "control"]
        },
        # consul udp
        {
            protocol = "udp"
            port_range = 8301
            source_tags = ["plat", "control"]
        }
    ]
}
