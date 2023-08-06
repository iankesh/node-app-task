# Creating 2 Public Subnets in each AZ
resource "aws_subnet" "public" {
  count             = var.total_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.10.${1 + count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

# Creating 2 Private Subnets in each AZ
resource "aws_subnet" "private" {
  count             = var.total_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.10.${3 + count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
}