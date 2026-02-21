#Creating S3 Gateway Endpoint
resource "aws_vpc_endpoint" "cafe_s3_endpoint" {
  vpc_id = var.vpc_id
  service_name = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = var.route_table_ids

  tags = merge(var.common_tags, {
    Name = "${var.vpc_name}-vpce.s3"
  })
}