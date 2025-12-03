resource "aws_launch_template" "app_lt" {
  name = "app-launch-template"

  image_id      = var.ec2_ami
  instance_type = "t2.micro"
  key_name      = var.ec2_key_name

  network_interfaces {
    security_groups = [aws_security_group.ec2_sg.id]
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {}))
}

resource "aws_autoscaling_group" "app_asg" {
  name              = "app-asg"
  desired_capacity  = 2
  max_size          = 2
  min_size          = 2
  health_check_type = "ELB"
  vpc_zone_identifier = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  tag {
    key                 = "Name"
    value               = "app-ec2"
    propagate_at_launch = true
  }
}
