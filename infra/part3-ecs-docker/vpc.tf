
############################################
# VPC
############################################

resource "aws_vpc" "main" {
cidr_block = "172.20.0.0/16"
}

############################################
# PUBLIC SUBNET 1
############################################

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.20.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

############################################
# PUBLIC SUBNET 2 (IMPORTANT FOR ALB)
############################################

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block = "172.20.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
}

############################################
# INTERNET GATEWAY
############################################

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

############################################
# ROUTE TABLE
############################################

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
}

############################################
# INTERNET ROUTE
############################################

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

############################################
# SUBNET ASSOCIATIONS
############################################

resource "aws_route_table_association" "rta_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rta_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.rt.id
}
