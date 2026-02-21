# Creating security groups first without ingress rules
resource "aws_security_group" "cafe_security_groups" {
  for_each = var.security_groups

  name = "${var.vpc_name}-${each.key}-sg"
  description = each.value.description
  vpc_id = var.vpc_id

  # General egress rule for all the SGs

  egress {
  from_port = 0
  to_port = 0
  protocol = -1
  cidr_blocks = [ "0.0.0.0/0" ]
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.vpc_name}-${each.key}-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Creating the ingress rules separetly to avoid circular dependency
locals {
  ingress_rules = flatten([
    for sg_key, sg_config in var.security_groups : [
      for idx, rule in sg_config.ingress_rules : {
        sg_key = sg_key
        rule_key = "${sg_key}-${idx}"
        from_port = rule.from_port
        to_port = rule.to_port
        protocol = rule.protocol
        cidr_blocks = rule.cidr_blocks
        source_sg = rule.source_sg
      }
    ]
  ])
}

resource "aws_security_group_rule" "cafe_ingress_rules" {
  for_each = { for rule in local.ingress_rules : rule.rule_key => rule }

  type = "ingress"
  from_port = each.value.from_port
  to_port = each.value.to_port
  protocol = each.value.protocol
  security_group_id = aws_security_group.cafe_security_groups[each.value.sg_key].id

  # Making possible to use either CIDR Blocks or SGs
cidr_blocks = each.value.cidr_blocks
source_security_group_id = each.value.source_sg != null ? aws_security_group.cafe_security_groups[each.value.source_sg].id : null
}

