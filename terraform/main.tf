#############################
#TERRAFORM MAIN CONFIGURATION
##############################

terraform {
  required_providers { 
#Wich provider to use
    aws = {
      source  = "hashicorp/aws" //Who maintains the supplier
      version = "~> 5.0" //Any version 5.x is allowed
    }
  }
  required_version = ">= 1.3.0" //Minimum version of terraform requerired
}
#######################
# AWS PROVIDER 
#######################
#Indicated in which region the resources will be created
provider "aws" {
  region = "us-east-1"
}

#####################
#  MAIN VPC 
#################

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16" //Private IPs range
  enable_dns_support   = true //Allows AWS to return internal dns
  enable_dns_hostnames = true //Alloes dns names within the VCP
  tags = { Name = "pokeapi-vpc" }  //Name of the VCP within AWS
 }

###################
# Subnets (public)
###################
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id //Wich VPC does it belong to
  cidr_block              = "10.0.1.0/24" //Ip range within the VPC
  availability_zone       = "us-east-1a" //AZ where the sunet is created
  map_public_ip_on_launch = true // Automatically assiigns a public IP address
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

#################################
# Internet Gateway + Route table
#################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id  //Conect the VPC to public internet 
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.rt.id
}

################################################
# Security Group - allow HTTP (80) and SSH (22)
################################################

resource "aws_security_group" "asg_sg" {
  name        = "pokeapi-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
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

  tags = { Name = "pokeapi-sg" }
}

##################
# Load Balancer
#################

resource "aws_lb" "app_lb" {
  name               = "pokeapi-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  security_groups    = [aws_security_group.asg_sg.id]
  enable_deletion_protection = false
}

##################
# Target Group
#################

resource "aws_lb_target_group" "tg" {
  name        = "pokeapi-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# User data to install Docker + Docker Compose + run app
locals {
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update packages
    apt-get update -y
    apt-get install -y docker.io curl

    systemctl enable docker
    systemctl start docker

    # Install docker-compose (standalone binary)
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # Create app directory
    mkdir -p /home/ubuntu/app
    cat > /home/ubuntu/app/docker-compose.yml << 'EOC'
    version: "3.8"
    services:
      db:
        image: postgres:15
        environment:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: "Liliana0912"
          POSTGRES_DB: pokemon_db
        volumes:
          - pgdata:/var/lib/postgresql/data

      backend:
        image: alexa1209/pokeapi-app-backend:latest
        environment:
          - DATABASE_URL=postgresql://postgres:Liliana0912@db:5432/pokemon_db
        depends_on:
          - db

      frontend:
        image: alexa1209/pokeapi-app-frontend:latest
        depends_on:
          - backend
        ports:
          - "80:3000"

    volumes:
      pgdata:
    networks:
      default:
        driver: bridge
    EOC

    cd /home/ubuntu/app
    /usr/local/bin/docker-compose up -d
  EOF
}

# Launch Template
resource "aws_launch_template" "lt" {
  name_prefix   = "pokeapi-lt-"
  image_id      = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  user_data     = base64encode(local.user_data)
  vpc_security_group_ids = [aws_security_group.asg_sg.id]
}

# Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  name                = "pokeapi-asg"
  min_size            = 3
  max_size            = 3
  desired_capacity    = 3
  vpc_zone_identifier = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 120

  tag {
    key                 = "Name"
    value               = "pokeapi-instance"
    propagate_at_launch = true
  }
}

# -------------------------
# CPU SCALING POLICY
# -------------------------

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

resource "aws_autoscaling_policy" "scale_out_cpu" {
  name                   = "scale-out-cpu"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
  alarm_names            = [aws_cloudwatch_metric_alarm.cpu_high.alarm_name]
}

# -------------------------
# MEMORY SCALING POLICY
# -------------------------

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 75

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

resource "aws_autoscaling_policy" "scale_out_memory" {
  name                   = "scale-out-memory"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
  alarm_names            = [aws_cloudwatch_metric_alarm.memory_high.alarm_name]
}

# -------------------------
# NETWORK (REQUESTS) POLICY
# -------------------------

resource "aws_cloudwatch_metric_alarm" "network_high" {
  alarm_name          = "high-network-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 100

  dimensions = {
    TargetGroup  = aws_lb_target_group.tg.arn_suffix
    LoadBalancer = aws_lb.app_lb.arn_suffix
  }
}

resource "aws_autoscaling_policy" "scale_out_network" {
  name                   = "scale-out-network"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
  alarm_names            = [aws_cloudwatch_metric_alarm.network_high.alarm_name]
}


# Output ALB DNS
output "alb_dns" {
  description = "ALB DNS name"
  value       = aws_lb.app_lb.dns_name
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_a" {
  value = aws_subnet.public_a.id
}

output "public_subnet_b" {
  value = aws_subnet.public_b.id
}

output "security_group_id" {
  value = aws_security_group.asg_sg.id
}

output "target_group_arn" {
  value = aws_lb_target_group.tg.arn
}

//Change
output "asg_instance_ids" {
  value = aws_autoscaling_group.asg.instances
}
