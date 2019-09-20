module "jack" {
    source = "../../../modules/droplet"

    name = "jack"
    public_tcp_ports = ["443", "80"]
    zone = "jackmuratore.com"
    domain = "jackmuratore.com"
    cnames = ["*.jackmuratore.com"]
}

