# Application Load Balancer Security Group
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Security group for the ALB allowing HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.vpc-sunny.id 

  # Inbound Rules
  ingress {
    description = "Allow HTTP traffic from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from any IPv4 address
  }

  ingress {
    description = "Allow HTTPS traffic from anywhere (if needed)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from any IPv4 address
  }

  # Outbound Rules
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allows all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "vic-sunny-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id] 
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id] 

  tags = {
    Name = "vic-sunny-lb"
  }
}

# Load Balancer Target Group
resource "aws_lb_target_group" "target_group" {
  name     = "vic-sunny-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc-sunny.id  

  health_check {
    path                = "/"         
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "vic-sunny-tg"
  }
}

# Load Balancer Listener
resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}
