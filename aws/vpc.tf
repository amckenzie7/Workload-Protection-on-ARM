data "aws_availability_zones" "az" {
  state = "available"
}
resource "aws_vpc" "vpc-tf" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "vpc-tf"
  }
}

resource "aws_subnet" "subnet-tf" {
  vpc_id                  = aws_vpc.vpc-tf.id
  cidr_block              = var.subnet1_cidr
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.az.names, 0)
  tags = {
    Name = "subnet-tf"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-tf.id
  tags = {
    Name = "igw-tf"
  }
}

resource "aws_default_route_table" "internet_route_table" {
  default_route_table_id = aws_vpc.vpc-tf.default_route_table_id

  route {
    cidr_block = var.rt_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "default-route-table"
  }
}