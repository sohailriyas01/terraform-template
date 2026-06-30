output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "azs" {
  description = "Availability zones the subnets are spread across."
  value       = local.azs
}

output "public_subnet_ids" {
  description = "Public subnet IDs, ordered by AZ."
  value       = [for az in local.azs : aws_subnet.public[az].id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs, ordered by AZ."
  value       = [for az in local.azs : aws_subnet.private[az].id]
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Private route table IDs, ordered by AZ."
  value       = [for az in local.azs : aws_route_table.private[az].id]
}

output "internet_gateway_id" {
  description = "ID of the internet gateway."
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT gateways."
  value       = aws_nat_gateway.this[*].id
}

output "nat_public_ips" {
  description = "Public IPs of the NAT gateways."
  value       = aws_eip.nat[*].public_ip
}
