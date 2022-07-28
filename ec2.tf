resource "aws_launch_configuration" "mylaunchconfiguration" {
  name_prefix = "launchconfiguration"
  image_id = "ami-0f2451e7497de8a7b"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.mysecuritygroup2.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = "10"
  }

  key_name = "linuxmachinekey"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "mysecuritygroup2" {
  name = "mysecuritygroup2"
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
  security_groups = [aws_security_group.mysecuritygroup2.id]

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
# #Security Group for our application
# resource "aws_security_group" "mysecuritygroup" {
#   name = "mysecuritygroup"
# #  vpc_id = aws_vpc.myvpc.id
#   ingress {
#     description      = "TLS from VPC"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }
#     ingress {
#     description      = "TLS from VPC"
#     from_port        = 443
#     to_port          = 443
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }
#     ingress {
#     description      = "TLS from VPC"
#     from_port        = 3306
#     to_port          = 3306
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }
#     ingress {
#     description      = "TLS from VPC"
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#     egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "Terraform-SG"
#   }
# }

# #Creating EC2 Instances
# resource "aws_instance" "myec2instances" {
#   ami = "ami-0667149a69bc2c367" 
#   instance_type = "t2.micro"
# #  subnet_id = aws_subnet.mysubnet.id
# #  vpc_security_group_ids = [aws_security_group.mysecuritygroup.id]
#   key_name = "linuxmachinekey"
#   root_block_device {
#     volume_type = "gp2"
#     volume_size = "10"
#   }
#   tags = {
#     Name = "Thoughtworks-application"
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
#   provisioner "local-exec" {
#     command = "chmod 600 linuxmachinekey.pem"
#   }
# #Running ansible from our machine to the managed node
#   provisioner "local-exec" {
#         command = "sleep 120; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u centos --private-key ./linuxmachinekey.pem -i '${aws_instance.myec2instances.public_ip},' mediawiki.yaml"
#      }
# }
