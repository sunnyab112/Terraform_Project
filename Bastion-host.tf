# Bastion Host Instance
resource "aws_instance" "bastion_host" {
  ami                    = "ami-08d8ac128e0a1b91c"  # Amazon Linux 2 AMI
  instance_type          = "t2.micro"
  availability_zone      = "us-west-2a"
  subnet_id              = aws_subnet.public1.id
  security_groups        = [aws_security_group.bastion_sg.id]
  key_name               = aws_key_pair.bastion_key.key_name
  associate_public_ip_address = true

  tags = {
    Name = "bastion-host"
  }
}

