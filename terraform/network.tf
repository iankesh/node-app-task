# Creating the VPC
resource "aws_vpc" "vpc" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"
}

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

# Create Security Group for Bastion Host
resource "aws_security_group" "bastion_host" {
  name        = "bastion-host-sg"
  description = "bastion-host-sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Public"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Create Security Group for Private Instance
resource "aws_security_group" "private_instance" {
  name        = "private-instance-sg"
  description = "private-instance-sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Private"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Create Security Group for Public Web
resource "aws_security_group" "public_web" {
  name        = "public-web-sg"
  description = "public-web-sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Public"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Creating a public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associating public subnets to public route table
resource "aws_route_table_association" "public" {
  count          = var.total_count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# Creating a Private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.network_interface.id
  }
}
# Associating private subnets to private route table
resource "aws_route_table_association" "private" {
  count          = var.total_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

# Creating an elastic IP
resource "aws_eip" "eip" {
  domain = "vpc"
}

# Creating a NAT Gatway
resource "aws_nat_gateway" "network_interface" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.0.id
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}