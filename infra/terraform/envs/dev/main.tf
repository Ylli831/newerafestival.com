# Hetzner SSH key
resource "hcloud_ssh_key" "yll_key" {
  name       = "yll_terraform_key"
  public_key = file("${path.module}/ssh/id_rsa.pub")
}

# Hetzner server
resource "hcloud_server" "dev_app" {
  name        = "dev-app-server"
  image       = "ubuntu-24.04"
  server_type = "cx23"     # still valid server type

  # Use location (e.g., nbg1, fsn1, hel1) — NOT nbg1-dc3
  location    = "hel1"

  ssh_keys    = [hcloud_ssh_key.yll_key.id]
  user_data   = file("${path.module}/cloud-init/dev.yaml")
}

# Firewall
resource "hcloud_firewall" "dev_firewall" {
  name = "dev-firewall"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["172.18.142.35/32"] # Your IP
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0"]
  }
}

resource "hcloud_firewall_attachment" "dev_firewall_attach" {
  firewall_id = hcloud_firewall.dev_firewall.id
  server_ids  = [hcloud_server.dev_app.id]
}

# Cloudflare DNS
resource "cloudflare_dns_record" "dev_dns" {
  zone_id = "182306ef02c4805fe246db3ff6d7f837"
  name    = "dev"
  content = hcloud_server.dev_app.ipv4_address
  type    = "A"
  ttl     = 1
  proxied = true
}
