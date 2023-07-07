# Terraform provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# configure aws provider
provider "aws" {
  region = "ap-south-1"
}

# creating vpc
resource "aws_vpc" "demo-vpc" {
cidr_block = "10.10.0.0/16"

tags = {
    Name = "Demo_vpc"
  } 
}

# creating subnet-1 in ap-south-1a AZ
resource "aws_subnet" "demo-subnet-1a" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.10.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Demo-subnet-1a"
  }
}

# creating subnet-2 in ap-south-1a AZ
resource "aws_subnet" "demo-subnet-1b" {
  vpc_id = aws_vpc.demo-vpc.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Demo-subnet-1b"
  } 
}

# creating subnet-3 in ap-south-1a AZ
resource "aws_subnet" "demo-subnet-1c" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Demo-subnet-1c"
  }
}

# creating subnet-4 in ap-south-1a AZ
resource "aws_subnet" "demo-subnet-1d" {
  vpc_id = aws_vpc.demo-vpc.id
  cidr_block = "10.10.3.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Demo-subnet-1d"
  }
}


 # creating the security group

  resource "aws_security_group" "Demo_SG_allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.demo-vpc.id

  ingress {
    description      = "SSH from PC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP from PC"
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
    Name = "allow_ssh_http"
  }
}

# crating Internet Gateway
resource "aws_internet_gateway" "demo_IG" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "Demo-IG"
  }
}


# creating the public Route table
resource "aws_route_table" "demo-RT-Public" {
  vpc_id = aws_vpc.demo-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_IG.id
  }
  tags = {
    Name = "Demo-Public-RT"
  }
}
# creating the private Route table
resource "aws_route_table" "demo-RT-Private" {
  vpc_id = aws_vpc.demo-vpc.id
  tags = {
    Name = "Demo-Private-RT"
  }
}
# creating route table association for public subnet-1a in ap-south-1a AZ
resource "aws_route_table_association" "demo-RT-associaciation-1" {
  subnet_id      = aws_subnet.demo-subnet-1a.id
  route_table_id = aws_route_table.demo-RT-Public.id
}
# creating route table association for public subnet-1c in ap-south-1b AZ
 resource "aws_route_table_association" "demo-RT-associaciation-2" {
  subnet_id      = aws_subnet.demo-subnet-1c.id
  route_table_id = aws_route_table.demo-RT-Public.id
}
# creating route table association for private subnet-1b in ap-south-1a AZ
resource "aws_route_table_association" "demo-RT-associaciation-3" {
  subnet_id      = aws_subnet.demo-subnet-1b.id
  route_table_id = aws_route_table.demo-RT-Private.id
}
# creating route table association for private subnet-1d in ap-south-1b AZ
resource "aws_route_table_association" "demo-RT-associaciation-4" {
  subnet_id      = aws_subnet.demo-subnet-1d.id
  route_table_id = aws_route_table.demo-RT-Private.id
}



# creating keypair
resource "aws_key_pair" "demo-key-pair" {
  key_name   = "demo-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1h8416Yo6CdA8Fn2dplKbru4dDG5kGfiVl8ZyPtszlXEygrAm1gUdT4FLV8QD/CmIJl8v5Nn50RCFSVY+0LifiPF5zlwFWsXkvxXzXWd0gGjmFapNTVdcGfrat7LcNo/MApX1zlkGxqWbIoqij1wA+exJaV9/CWnveubSeGHRLLW5QdkezsRJ2HkqAizvO7vRdyIidmp7dpufWjoi3MWZ+DdyEmdL0I4TOsrjshWz0IIfKNoo2sU1OwSV7SHqbjerO15XATH9n6ACh5cUL+gIfHHUguhVH+OWENGJ7++2D9Zi8CjSeixMZgM5IIBto6XpFxBw5WRjper/xg4WSB5Sqvlo/t/REAfaC/tufb/lnJa70odZ5zM/l8BNTaDczKnhfpAK6hZHbh96XBHauOZcvxj5l5lZFQHAlJCty3Q0zKYrYQ9YbtbAbHXPEZVOS8yjHLUS8PvaoRHnrPSCU6XFF+Ix2wVCqQ6CPM+oPxc9j+/P/Yl7c/6lwTFK4JzL/HM= DELL@DESKTOP-0F3QRMG"
  }

# creating demo inastance-1
resource "aws_instance" "demo-instance-1" {
  ami           = "ami-00905669203982f88"
  instance_type = var.demo_instance_type
  key_name = aws_key_pair.demo-key-pair.id
  subnet_id = aws_subnet.demo-subnet-1a.id
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.Demo_SG_allow_ssh_http.id]

  tags = {
    Name = "Demo-Instance-1"
  }
}

# creating demo inastance-2
resource "aws_instance" "demo-instance-2" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  key_name = aws_key_pair.demo-key-pair.id
  subnet_id = aws_subnet.demo-subnet-1c.id
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.Demo_SG_allow_ssh_http.id]

  tags = {
    Name = "Demo-Instance-2"
  }
}

# creating launch template
resource "aws_launch_template" "Demo-Template" {
  name = "Demo-Template"

  image_id = "ami-0f5ee92e2d63afc18"
 
  instance_type = "t2.micro"

  key_name = aws_key_pair.demo-key-pair.id


  monitoring {
    enabled = true
  }


  placement {
    availability_zone = "ap-south-1"
  }

  vpc_security_group_ids = [aws_security_group.Demo_SG_allow_ssh_http.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Demo-instance-ASG"
    }
  }

  #user_data = filebase64("userdata.sh")
}

# creating ASG
resource "aws_autoscaling_group" "demo-ASG" {
  vpc_zone_identifier = [aws_subnet.demo-subnet-1a.id, aws_subnet.demo-subnet-1c.id]
  
  desired_capacity   = 2
  max_size           = 5
  min_size           = 2

  
  launch_template {
    id      = aws_launch_template.Demo-Template.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.demo-TG-1.arn]
}

# ALB TG with ASG
resource "aws_lb_target_group" "demo-TG-1" {
  name     = "demo-TG-1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.demo-vpc.id
}


#load balancer with ASG

resource "aws_lb" "demo-LB-1" {
  name               = "demo-LB-1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Demo_SG_allow_ssh_http.id]
  subnets            = [aws_subnet.demo-subnet-1a.id, aws_subnet.demo-subnet-1c.id]

  tags = {
    Environment = "production"
  }
}


# LB Listener with ASG

resource "aws_lb_listener" "demo-listener-1" {
  load_balancer_arn = aws_lb.demo-LB-1.arn
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo-TG-1.arn
  }
}


