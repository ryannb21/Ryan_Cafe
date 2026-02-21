locals {
  web_acl_name = "${var.cafe_waf_prefix}-web-acl"
}

#Configuring the IP set for explicit blocked IPs
resource "aws_wafv2_ip_set" "cafe_waf_blocked_ips" {
  name               = "${var.cafe_waf_prefix}-blocked-ips"
  description        = "IP Set for explicit manually blocked IPs"
  scope              = var.waf_scope
  ip_address_version = "IPV4"
  addresses          = var.blocked_ips
}

#Configuring the regex pattern set for exploit and probe paths
resource "aws_wafv2_regex_pattern_set" "cafe_waf_blocked_exploit_paths" {
  name        = "${var.cafe_waf_prefix}-blocked-exploit-patterns"
  scope       = var.waf_scope
  description = "Regex pattern set for disallowed exploit paths"

  regular_expression {
    regex_string = ".*phpunit.*eval-stdin\\.php.*"
  }
  regular_expression {
    regex_string = ".*\\.php.*\\.shell.*"
  }
  regular_expression {
    regex_string = ".*allow_url_include=.*"
  }
  regular_expression {
    regex_string = ".*auto_prepend_file=.*"
  }
  regular_expression {
    regex_string = ".*disable_functions=.*"
  }
  regular_expression {
    regex_string = ".*open_basedir=.*"
  }
  regular_expression {
    regex_string = ".*safe_mode=.*"
  }
}

#Configuring the regex pattern set to label known benign user agents
resource "aws_wafv2_regex_pattern_set" "cafe_waf_benign_users" {
  name        = "${var.cafe_waf_prefix}-benign-users"
  scope       = var.waf_scope
  description = "Regex pattern set for benign user agents"

  dynamic "regular_expression" {
    for_each = var.allowed_user_agent_regexes
    content {
      regex_string = regular_expression.value
    }
  }
}

#Configuring the Web ACL
resource "aws_wafv2_web_acl" "cafe_waf_acl" {
  name        = local.web_acl_name
  scope       = var.waf_scope
  description = "Cafe Web ACL protecting the ALB"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.cafe_waf_prefix}"
    sampled_requests_enabled   = true
  }

#Configuring the custom blocking of exploit paths
  rule {
    name     = "block-exploit-paths"
    priority = 1

    statement {
      or_statement {
        statement {
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.cafe_waf_blocked_exploit_paths.arn
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 0
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 1
              type = "LOWERCASE"
            }
          }
        }
        statement {
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.cafe_waf_blocked_exploit_paths.arn
            field_to_match {
              query_string {}
            }
            text_transformation {
              priority = 0
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 1
              type = "LOWERCASE"
            }
          }
        }
      }
    }

    action {
      block {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.cafe_waf_prefix}-block-exploit-paths"
      sampled_requests_enabled   = true
    }
  }

#Configuring rate limiting for high bursts
#Rate limit warning using count, as a first step to observe high bursts 
  rule {
    name     = "rate-limit-warning"
    priority = 2

    statement {
      rate_based_statement {
        limit              = 100
        aggregate_key_type = "IP"

        scope_down_statement {
          not_statement {
            statement {
              label_match_statement {
                scope = "LABEL"
                key = "cafe:benign-ua"
              }
            }
          }
        }
      }
    }

    action {
      count {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.cafe_waf_prefix}-rate-limit-warning"
      sampled_requests_enabled   = true
    }
  }
  #Rate limit using block to block users with high bursts
  rule {
    name     = "rate-limit-block"
    priority = 3

    statement {
      rate_based_statement {
        limit              = 200
        aggregate_key_type = "IP"

        scope_down_statement {
          not_statement {
            statement {
              label_match_statement {
                scope = "LABEL"
                key = "cafe:benign-ua"
              }
            }
          }
        }
      }
    }

    action {
      block {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.cafe_waf_prefix}-rate-limit-block"
      sampled_requests_enabled   = true
    }
  }

#Configuring the blocklisted IPs
  rule {
    name     = "block-listed-ips"
    priority = 4

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.cafe_waf_blocked_ips.arn
      }
    }

    action {
      block {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.cafe_waf_prefix}-blocked-ips"
      sampled_requests_enabled   = true
    }
  }

#Labeling the known benign user agents so they can be excluded or deprioritized
  rule {
    name     = "label-benign-user-agents"
    priority = 5

    statement {
      regex_pattern_set_reference_statement {
        arn = aws_wafv2_regex_pattern_set.cafe_waf_benign_users.arn
        field_to_match {
          single_header {
            name = "user-agent"
          }
        }
        text_transformation {
          priority = 0
          type     = "LOWERCASE"
        }
      }
    }

    action {
      count {}
    }
    rule_label {
      name = "cafe:benign-ua"
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.cafe_waf_prefix}-benign-users"
      sampled_requests_enabled   = true
    }
  }

#Adding the AWS managed rule sets for wider security
  rule {
    name     = "aws-managed-core"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.cafe_waf_prefix}-managed-core"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-managed-known-bad-inputs"
    priority = 11

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.cafe_waf_prefix}-managed-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-managed-ip-reputation"
    priority = 12

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.cafe_waf_prefix}-managed-ip-reputation"
      sampled_requests_enabled   = true
    }
  }
}

#Associating the Web ACL to ALB
resource "aws_wafv2_web_acl_association" "assoc" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.cafe_waf_acl.arn
}
