# VPC
resource "aws_vpc" "vpc-sunny" {
  cidr_block = "10.100.0.0/16"
  tags = {
    Name = "vic-sunny-vpc"
  }
}

# Subnets
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.vpc-sunny.id
  cidr_block        = "10.100.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "vic-sunny-public-1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.vpc-sunny.id
  cidr_block        = "10.100.2.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "vic-sunny-public-2"
  }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.vpc-sunny.id
  cidr_block        = "10.100.3.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "vic-sunny-private-1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.vpc-sunny.id
  cidr_block        = "10.100.4.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "vic-sunny-private-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-sunny.id
  tags = {
    Name = "vic-sunny-igw"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "eip" {
  domain = "vpc"
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id
  tags = {
    Name = "vic-sunny-nat"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc-sunny.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "vic-sunny-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc-sunny.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "vic-sunny-private-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "mysql-subnet-group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id] 
  tags = {
    Name = "MySQL Subnet Group"
  }
}
