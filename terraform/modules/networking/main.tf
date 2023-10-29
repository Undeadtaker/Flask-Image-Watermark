resource "aws_vpc" "main" {
  cidr_block               = var.main_cidr_block
  instance_tenancy         = "default"
  enable_dns_support       = true
  enable_dns_hostnames     = true
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name              = var.internal_dn
  domain_name_servers      = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id                   = aws_vpc.main.id
  dhcp_options_id          = aws_vpc_dhcp_options.main.id
}

resource "aws_internet_gateway" "main" {
  vpc_id                   = aws_vpc.main.id
}

resource "aws_subnet" "main_public" {
  vpc_id                   = aws_vpc.main.id
  availability_zone        = var.primary_zone
  cidr_block               = cidrsubnet(var.main_cidr_block, 0, 1)
  map_public_ip_on_launch  = true
  depends_on               = [aws_internet_gateway.main]

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "main_private" {
  vpc_id                   = aws_vpc.main.id
  availability_zone        = var.primary_zone
  cidr_block               = cidrsubnet(var.main_cidr_block, 0, 3)
  
  tags = {
    Name = "private subenet"
  }
}

resource "aws_route_table" "main_public" {
  vpc_id                   = aws_vpc.main.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id           = aws_route_table.main_public.id
  destination_cidr_block   = "0.0.0.0/0"
  gateway_id               = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  subnet_id                = aws_subnet.main_public.id
  route_table_id           = aws_route_table.main_public.id
}