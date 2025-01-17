locals {
  s3_origin_id   = "${var.s3_name}-origin"
  s3_domain_name = "${var.s3_name}.s3-website-${var.region}.amazonaws.com"
}

resource "aws_cloudfront_distribution" "this" {

  enabled             = true
  default_root_object = "index.html"
  origin {
    origin_id                = local.s3_origin_id
    domain_name              = aws_s3_bucket.web_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.example.id
  }



  default_cache_behavior {

    target_origin_id = local.s3_origin_id
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  aliases = ["aceraney.com"]

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.aceraney_cert_east.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  price_class = "PriceClass_100"

  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress                   = true
    default_ttl                = 0
    max_ttl                    = 0
    min_ttl                    = 0
    path_pattern               = "*.js"
    response_headers_policy_id = "aae1ba4e-b5af-4220-bd62-9a037808a0ea"
    smooth_streaming           = false
    target_origin_id           = "acer-web-bucket-origin"
    trusted_key_groups         = []
    trusted_signers            = []
    viewer_protocol_policy     = "allow-all"
    # (3 unchanged attributes hidden)
  }
  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress                   = true
    default_ttl                = 0
    max_ttl                    = 0
    min_ttl                    = 0
    path_pattern               = "*.css"
    response_headers_policy_id = "f017493c-fbf7-4006-b9fb-1cdf90519891"
    smooth_streaming           = false
    target_origin_id           = "acer-web-bucket-origin"
    trusted_key_groups         = []
    trusted_signers            = []
    viewer_protocol_policy     = "allow-all"
    # (3 unchanged attributes hidden)
  }
  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = true
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    path_pattern           = "*"
    smooth_streaming       = false
    target_origin_id       = "acer-web-bucket-origin"
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"
    # (4 unchanged attributes hidden)
  }
}

resource "aws_cloudfront_origin_access_control" "example" {
  name                              = "ace-website"
  description                       = "Ace Website"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

