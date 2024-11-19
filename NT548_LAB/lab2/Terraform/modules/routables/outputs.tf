output "ig_id" {
  value = aws_internet_gateway.ig.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}


output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}
