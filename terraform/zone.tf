provider "cloudflare" {
}

resource "cloudflare_zone" "com_li7g" {
  zone = "li7g.com"
}

# ttl = 1 for automatic

resource "cloudflare_record" "li7g_aws_a" {
  name    = "aws"
  proxied = true
  ttl     = 1
  type    = "A"
  value   = aws_eip.main.public_ip
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_aws_aaaa" {
  name    = "aws"
  proxied = true
  ttl     = 1
  type    = "AAAA"
  value   = aws_instance.main.ipv6_addresses[0]
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_vultr_a" {
  name    = "vultr"
  proxied = true
  ttl     = 1
  type    = "A"
  value   = vultr_instance.main.main_ip
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_vultr_aaaa" {
  name    = "vultr"
  proxied = true
  ttl     = 1
  type    = "AAAA"
  value   = vultr_instance.main.v6_main_ip
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_tencent_a" {
  name    = "tencent"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = var.tencent_ip
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_nexusbytes_a" {
  name    = "nexusbytes"
  proxied = true
  ttl     = 1
  type    = "A"
  value   = var.nexusbytes_ip
  zone_id = cloudflare_zone.com_li7g.id
}

# -------------
# CNAME records

resource "cloudflare_record" "li7g_home" {
  name    = "home"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "ae370c7d335a.sn.mynetname.net"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g" {
  name    = "li7g.com"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "vultr.li7g.com"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_cache" {
  name    = "cache"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "nuc.li7g.com"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_dst" {
  name    = "dst"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "tencent.li7g.com"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_matrix" {
  name    = "matrix"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "nuc.li7g.com"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_nuc_proxy" {
  name    = "nuc-proxy"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "vultr.li7g.com"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_portal" {
  name    = "portal"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "vultr.li7g.com"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_derp_shanghai" {
  name    = "shanghai.derp"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "tencent.li7g.com"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_tar" {
  name    = "tar"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "vultr.li7g.com"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_vault" {
  name    = "vault"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "nuc.li7g.com"
  zone_id = cloudflare_zone.com_li7g.id
}

# --------------------------
# smtp records for receiving

resource "cloudflare_record" "li7g_mx68" {
  name     = "li7g.com"
  priority = 68
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "amir.mx.cloudflare.net"
  zone_id  = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_mx43" {
  name     = "li7g.com"
  priority = 43
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "linda.mx.cloudflare.net"
  zone_id  = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_mx2" {
  name     = "li7g.com"
  priority = 2
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "isaac.mx.cloudflare.net"
  zone_id  = cloudflare_zone.com_li7g.id
}

# ------------------------
# smtp records for sending

resource "cloudflare_record" "li7g_nexusbytes_aaaa" {
  name    = "smtp"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "nexusbytes.li7g.com"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_ts_smtp" {
  name    = "smtp.ts"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "nexusbytes.ts.li7g.com"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_dkim" {
  name    = "default._domainkey"
  proxied = false
  ttl     = 1
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAozlZRnVQ/ZuPw6ohn2Ahy51KG4MMysqkhDt3irQwopIUpIgDZdP+HnCxlPv3dKKCkwdqXlHC/swoCUdhu5aS/JmUGKsXU21ETy17+VUeyBSs0N3Ytg4RePRfQli7J4setvEhWEyZHpO9ofJEmGfN8H256Cwvqi+2HuZxIQDxpqJXGlfEUqNxj5Ij9bFvWT/hDfGpxvRxLAHd0WrrnizGWHS73S0i7VmRcfLQhZhnc4ujF3MgC7W8BDZuWdIwKUkcOKSUtALq6L8W0edR1xctRFhMa7rvT8wjdIAAneJLrPFgBN1JCV85PMrV4Hch9C/XCd92Nh9gCRuea2Bj3TtuDQIDAQAB"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_dmarc" {
  name    = "_dmarc"
  proxied = false
  ttl     = 1
  type    = "TXT"
  value   = "v=DMARC1; p=quarantine; ruf=mailto:postmaster@li7g.com"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_spf" {
  name    = "li7g.com"
  proxied = false
  ttl     = 1
  type    = "TXT"
  value   = "v=spf1 include:_spf.mx.cloudflare.net redirect=smtp.li7g.com"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_smtp_spf" {
  name    = "smtp"
  proxied = false
  ttl     = 1
  type    = "TXT"
  value   = "v=spf1 a ~all"
  zone_id = cloudflare_zone.com_li7g.id
}

# -----------------
# tailscale records

resource "cloudflare_record" "li7g_ts_aws" {
  name    = "aws.ts"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "100.115.115.106"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_ts_g150t" {
  name    = "g150ts.ts"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "100.107.253.26"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_ts_mix2s" {
  name    = "mix2s.ts"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "100.97.39.42"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_ts_nexusbytes" {
  name    = "nexusbytes.ts"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "100.81.121.63"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_ts_vault" {
  name    = "vault.ts"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "nuc.ts.li7g.com"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_ts_matrix" {
  name    = "matrix.ts"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "nuc.ts.li7g.com"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_ts_nuc" {
  name    = "nuc.ts"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "100.95.57.26"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_ts_t460p" {
  name    = "t460p.ts"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "100.106.218.38"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_ts_tencent" {
  name    = "tencent.ts"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "100.98.18.47"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_ts_vultr" {
  name    = "vultr.ts"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "100.98.21.41"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_ts_x200s" {
  name    = "x200s.ts"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "100.115.15.96"
  zone_id = cloudflare_zone.com_li7g.id
}

resource "cloudflare_record" "li7g_ts_xps8930" {
  name    = "xps8930.ts"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "100.67.95.76"
  zone_id = cloudflare_zone.com_li7g.id
}

# ------------
# DDNS records

resource "cloudflare_record" "li7g_nuc_a" {
  name    = "nuc"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "127.0.0.1" # create for ddns
  zone_id = cloudflare_zone.com_li7g.id
  lifecycle { ignore_changes = [value] }
}

resource "cloudflare_record" "li7g_nuc_aaaa" {
  name    = "nuc"
  proxied = false
  ttl     = 1
  type    = "AAAA"
  value   = "::1" # create for ddns
  zone_id = cloudflare_zone.com_li7g.id
  lifecycle { ignore_changes = [value] }
}

resource "cloudflare_record" "li7g_t460p_a" {
  name    = "t460p"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "127.0.0.1" # create for ddns
  zone_id = cloudflare_zone.com_li7g.id
  lifecycle { ignore_changes = [value] }
}

resource "cloudflare_record" "li7g_t460p_aaaa" {
  name    = "t460p"
  proxied = false
  ttl     = 1
  type    = "AAAA"
  value   = "::1" # create for ddns
  zone_id = cloudflare_zone.com_li7g.id
  lifecycle { ignore_changes = [value] }
}

resource "cloudflare_record" "li7g_xps8930_a" {
  name    = "xps8930"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "127.0.0.1" # create for ddns
  zone_id = cloudflare_zone.com_li7g.id
  lifecycle { ignore_changes = [value] }
}

resource "cloudflare_record" "li7g_xps8930_aaaa" {
  name    = "xps8930"
  proxied = false
  ttl     = 1
  type    = "AAAA"
  value   = "::1" # create for ddns
  zone_id = cloudflare_zone.com_li7g.id
  lifecycle { ignore_changes = [value] }
}
