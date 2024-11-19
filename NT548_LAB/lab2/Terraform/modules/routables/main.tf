resource "aws_internet_gateway" "ig" {
  vpc_id = var.vpc_id

  tags = {
    Name = "internet-gateway"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_ids[0]

  tags = {
    Name = "nat-gateway"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_association" {
  for_each       = { for idx, subnet_id in var.public_subnet_ids : idx => subnet_id }
  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_association" {
  for_each       = { for idx, subnet_id in var.private_subnet_ids : idx => subnet_id }
  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}


