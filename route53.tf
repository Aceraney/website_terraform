resource "aws_acm_certificate" "aceraney_cert" {
  domain_name       = "aceraney.com"
  validation_method = "DNS"

  tags = {
    Environment = "dev"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "aceraney_cert_east" {
  domain_name       = "aceraney.com"
  validation_method = "DNS"

  tags = {
    Environment = "dev"
  }

  provider = aws.us_east

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "api_aceraney_cert" {
  domain_name       = "api.aceraney.com"
  validation_method = "DNS"

  tags = {
    Environment = "dev"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "api_aceraney_cert_east" {
  domain_name       = "api.aceraney.com"
  validation_method = "DNS"

  tags = {
    Environment = "dev"
  }

  provider = aws.us_east

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_zone" "main" {
  name = "aceraney.com"
}

resource "aws_route53_zone" "api" {
  name = "api.aceraney.com"
}

resource "aws_route53_record" "dev-ns" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.aceraney.com"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.api.name_servers
}

resource "aws_route53_record" "aceraney_com_verification" {
  for_each = {
    for dvo in aws_acm_certificate.aceraney_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

resource "aws_acm_certificate_validation" "aceraney_com" {
  certificate_arn         = aws_acm_certificate.aceraney_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.aceraney_com_verification : record.fqdn]
}

resource "aws_route53_record" "api_aceraney_com_verification" {
  for_each = {
    for dvo in aws_acm_certificate.api_aceraney_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.api.zone_id
}

resource "aws_acm_certificate_validation" "api_aceraney_com" {
  certificate_arn         = aws_acm_certificate.api_aceraney_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.api_aceraney_com_verification : record.fqdn]
}

resource "aws_route53_record" "aceraney_com_verification_east" {
  for_each = {
    for dvo in aws_acm_certificate.aceraney_cert_east.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}


resource "aws_route53_record" "api_aceraney_com_verification_east" {
  for_each = {
    for dvo in aws_acm_certificate.api_aceraney_cert_east.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.api.zone_id
}


resource "aws_api_gateway_domain_name" "api" {
  regional_certificate_arn = aws_acm_certificate.api_aceraney_cert.arn
  domain_name     = "api.aceraney.com"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "api" {
  name    = aws_api_gateway_domain_name.api.domain_name
  type    = "A"
  zone_id = aws_route53_zone.api.id
  

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api.regional_zone_id
  }
}

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "aceraney.com"
  type    = "A"

  alias  {
    name                   = "${aws_cloudfront_distribution.this.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.this.hosted_zone_id}"
    evaluate_target_health = false
  }
}