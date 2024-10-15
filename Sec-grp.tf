# Security Group for EC2 Instances (Allow SSH and HTTP)
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.vpc-sunny.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}

# Security Group for Bastion Host (SSH access)
resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.vpc-sunny.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Bastion_sg"
  }
}

# Key Pair for Bastion Host
resource "aws_key_pair" "bastion_key" {
  key_name   = "vic-sunny-key"
  public_key = file("~/.ssh/id_rsa.pub")
}