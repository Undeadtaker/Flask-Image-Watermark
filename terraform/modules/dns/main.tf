resource "aws_route53_zone" "private_zone" {
  name = var.internal_dn
  force_destroy = true
  vpc {
    vpc_id = var.main_vpc.id
    vpc_region = var.region
  }
}

resource "aws_route53_zone" "reverse_zone" {
  name = var.internal_dn
  force_destroy = true
  vpc {
    vpc_id = var.main_vpc.id
    vpc_region = var.region
  }
}

resource "aws_route53_record" "flask_private" {
  count   = 2
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = format("validator-0%d.internal", count.index)
  type    = "A"
  ttl     = "60"
  records = [element(var.flask_private_ips, count.index)]
}
resource "aws_route53_record" "flask_private_reverse" {
  count   = 2
  zone_id = aws_route53_zone.reverse_zone.zone_id
  records = [format("validator-0%d.internal", count.index)]
  type    = "PTR"
  ttl     = "60"
  name    = join(".", reverse(split(".", element(var.flask_private_ips, count.index))))
}

resource "aws_route53_record" "monitoring" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "monitoring-01.internal"
  type    = "A"
  ttl     = "60"
  records = [var.observe_private_ip]
}
resource "aws_route53_record" "monitoring_reverse" {
  count   = var.monitoring_count
  zone_id = aws_route53_zone.reverse_zone.zone_id
  records = ["monitoring_01.internal"]
  type    = "PTR"
  ttl     = "60"
  name    = join(".", reverse(split(".", element(var.monitoring_private_ips, count.index))))
}

resource "aws_acm_certificate" "main_flask" {
  domain_name       = "flask_project.${data.aws_route53_zone.private_zone.name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}