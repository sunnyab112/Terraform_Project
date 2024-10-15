resource "aws_security_group" "mysql_sg" {
  name        = "mysql-rds-sg"
  description = "Security group for MySQL RDS instance"
  vpc_id      = aws_vpc.vpc-sunny.id

  # Allow MySQL traffic from the bastion security group
  ingress {
    description     = "MySQL access from the bastion security group"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]  
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySQL RDS Security Group"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  instance_class         = "db.t3.micro"
  engine                 = "mysql"
  engine_version         = "8.0.35"
  db_name                = "mydb"
  username               = "admin"
  password               = "admin!123"
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.mysql_subnet_group.name  
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]  
  multi_az               = true
  skip_final_snapshot    = true

  tags = {
    Name = "MySQL RDS Instance"
  }
}
