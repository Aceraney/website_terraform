resource "aws_wafv2_ip_set" "block_ip_set" {
  name = "generated-ips"

  scope              = "REGIONAL"
  ip_address_version = "IPV4"

  addresses = ["10.0.0.1/32"]

  lifecycle {
    ignore_changes = [
      addresses
    ]
  }
}


resource "aws_wafv2_web_acl" "example" {
  name        = "managed-rule-example"
  description = "IP block rule."
  scope       = "REGIONAL"
  custom_response_body {
    content = jsonencode(
      {
        message = "You or someone on your network already blocked this IP. Swap networks, jump on a VPN, spoof some headers, or email me to remove the block. Thanks"
      }
    )
    content_type = "APPLICATION_JSON"
    key          = "already_blocked"
  }

  default_action {
    allow {}
  }

  rule {
    name     = "ipset-block"
    priority = 1

    action {
      block {
        custom_response {
          custom_response_body_key = "already_blocked"
          response_code            = 403
        }
      }
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.block_ip_set.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "ipset-block"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}

