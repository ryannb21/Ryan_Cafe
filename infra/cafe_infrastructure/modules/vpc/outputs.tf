output "vpc_id" {
  value = aws_vpc.ryan_cafe_vpc.id
}

output "vpc_name" {
  value = var.vpc_name
}
