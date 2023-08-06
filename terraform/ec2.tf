# Create the key pair
resource "aws_key_pair" "key" {
  key_name   = "key-pair"
  public_key = file("../id_rsa.pub")
}

# Create Bastion EC2 instance
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_ubuntu.id
  key_name                    = aws_key_pair.key.key_name
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.0.id
  vpc_security_group_ids      = [aws_security_group.bastion_host.id]
  associate_public_ip_address = true
}

# Create Jenkins EC2 instance
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.amazon_ubuntu.id
  key_name               = aws_key_pair.key.key_name
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.0.id
  vpc_security_group_ids = [aws_security_group.private_instance.id]
  #   associate_public_ip_address = true
}

# Create App EC2 instance
resource "aws_instance" "app" {
  ami                         = data.aws_ami.amazon_ubuntu.id
  key_name                    = aws_key_pair.key.key_name
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private.1.id
  vpc_security_group_ids      = [aws_security_group.private_instance.id]
  associate_public_ip_address = false
}