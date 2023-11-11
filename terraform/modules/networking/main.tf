resource "aws_vpc" "main" {
  cidr_block               = var.main_cidr_block
  instance_tenancy         = "default"
  enable_dns_support       = true
  enable_dns_hostnames     = false
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name_servers      = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id                   = aws_vpc.main.id
  dhcp_options_id          = aws_vpc_dhcp_options.main.id
}

resource "aws_internet_gateway" "main" {
  vpc_id                   = aws_vpc.main.id
}

data "aws_availability_zones" "primary_zone" {
  state = "available"
}

resource "aws_subnet" "main_public" {
  vpc_id                   = aws_vpc.main.id
  availability_zone        = data.aws_availability_zones.primary_zone.names[0]
  cidr_block               = cidrsubnet(var.main_cidr_block, 2, 1)
  map_public_ip_on_launch  = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "second_public" {
  vpc_id                   = aws_vpc.main.id
  availability_zone        = data.aws_availability_zones.primary_zone.names[1]
  cidr_block               = cidrsubnet(var.main_cidr_block, 2, 2)
  map_public_ip_on_launch  = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "main_private" {
  vpc_id                   = aws_vpc.main.id
  availability_zone        = data.aws_availability_zones.primary_zone.names[0]
  cidr_block               = cidrsubnet(var.main_cidr_block, 2, 3)
  
  tags = {
    Name = "private subnet"
  }
}

resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]
  tags = {
    Name = "eip-for-NAT"
  }
}

resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.main_public.id
  allocation_id = aws_eip.nat.id
  tags = {
    Name = "nat-gateway-01"
  }
}

resource "aws_route_table" "main_public" {
  vpc_id                   = aws_vpc.main.id
}
resource "aws_route_table" "main_private" {
  vpc_id                   = aws_vpc.main.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id           = aws_route_table.main_public.id
  destination_cidr_block   = "0.0.0.0/0"
  gateway_id               = aws_internet_gateway.main.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id           = aws_route_table.main_private.id
  destination_cidr_block   = "0.0.0.0/0"
  nat_gateway_id           = aws_nat_gateway.nat.id
}


resource "aws_route_table_association" "public" {
  subnet_id                = aws_subnet.main_public.id
  route_table_id           = aws_route_table.main_public.id
}
resource "aws_route_table_association" "public_second" {
  subnet_id                = aws_subnet.second_public.id
  route_table_id           = aws_route_table.main_public.id
}
resource "aws_route_table_association" "private" {
  subnet_id                = aws_subnet.main_private.id
  route_table_id           = aws_route_table.main_private.id
}
