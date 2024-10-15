# Launch Template
resource "aws_launch_template" "launch_template" {
  name_prefix   = "launch-template"
  image_id      = "ami-08d8ac128e0a1b91c"
  instance_type = "t2.micro"       
  key_name      = "keyss"
  
  lifecycle {
    create_before_destroy = true
  }
}

# AutoScaling Group
resource "aws_autoscaling_group" "AutoScalingGroup" {
  name                      = "vic-sunny-asg"
  max_size                  = 4
  min_size                  = 1
  desired_capacity          = 2
  
  vpc_zone_identifier       = [aws_subnet.public1.id, aws_subnet.public2.id]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.target_group.arn]

  tag {
    key                 = "Name"
    value               = "WordPress-ASG"
    propagate_at_launch = true
  }
}

# CloudWatch Alarm for Scaling Up
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.AutoScalingGroup.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}

# CloudWatch Alarm for Scaling Down
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.AutoScalingGroup.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_down.arn]
}

# Auto Scaling Policy for Scaling Up
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.AutoScalingGroup.name
}

# Auto Scaling Policy for Scaling Down
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.AutoScalingGroup.name
}
