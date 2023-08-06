# Find available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Using a http data source to get own IP
data "http" "myip" {
  url = "https://api.ipify.org/"
}

# Using Ubuntu-20 official AMI
data "aws_ami" "amazon_ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}