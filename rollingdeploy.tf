resource "aws_launch_configuration" "mylaunchconfiguration" {
  name_prefix = "launchconfiguration"
  image_id = "ami-0e335603e186cdd94"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.mysecuritygroup.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = "10"
  }

  key_name = "linuxmachinekey"

  lifecycle {
    create_before_destroy = true
  }

resource "aws_security_group" "mysecuritygroup" {
  name = "mysecuritygroup"
  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
    ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
    ingress {
    description      = "TLS from VPC"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
    ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Terraform-SG"
  }
}


resource "aws_autoscaling_group" "myautoscalinggroup" {
  name          = "aws_group_${aws_launch_configuration.mylaunchconfiguration.name}"
  launch_configuration = aws_launch_configuration.mylaunchconfiguration.name
  load_balancers = [aws_elb.myloadbalancer.name]
  availability_zones = data.aws_availability_zones.zones.names

  min_size             = 1
  max_size             = 2

  health_check_grace_period = 300
  health_check_type         = "EC2"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "myautoscalingpolicy" {
    name = "myautoscalingpolicy"
    policy_type = "TargetTrackingScaling"
    autoscaling_group_name = "${aws_autoscaling_group.myautoscalinggroup.name}"
    estimated_instance_warmup = 200

    target_tracking_configuration {
    predefined_metric_specification {
    predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = "60"
    }
}

data "aws_availability_zones" "zones" {
  state = "available"
}

resource "aws_elb" "myloadbalancer" {
  name               = "myloadbalancer"
  availability_zones = data.aws_availability_zones.zones.names
  security_groups = [aws_security_group.mysecuritygroup.id]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/"
    interval            = 10
  }
}

}
