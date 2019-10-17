module "platform" {
    source = "../../../modules/droplet"
    name = "plat"
    public_tcp_ports = ["443", "80"]
    zone = ns1_zone.giantdino.zone
    number = 1
    inbound_services = [
        # nomad
        {
            protocol = "tcp"
            port_range = 4647
            source_tags = ["plat"]
        },
        # consul tcp
        {
            protocol = "tcp"
            port_range = 8301
            source_tags = ["plat"]
        },
        {
            protocol = "tcp"
            port_range = 8300
            source_tags = ["plat"]
        },
        # consul udp
        {
            protocol = "udp"
            port_range = 8301
            source_tags = ["plat"]
        }
    ]
}
