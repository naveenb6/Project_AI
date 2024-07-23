terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/26"
  tags = {
    Name = "My VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block          = "10.0.0.0/28"
  availability_zone  = "us-east-1a"
  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Internet Gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public_route_table.id
  destination_ipv6_cidr_block = aws_vpc.my_vpc.ipv6_cidr_block
  gateway_id     = aws_internet_gateway.internet_gateway.id
}


resource "aws_route_table_association" "public_subnet_association" {
  subnet_id         = aws_subnet.public_subnet.id
  route_table_id     = aws_route_table.public_route_table.id
}

resource "aws_security_group" "ec2_sg" {
  name = "My EC2 Security Group"
  description = "Security group for EC2 instance"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port = 22
    to_port   = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from anywhere (replace with specific IP for better security)
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic (replace with specific rules if needed)
  }
}

resource "aws_instance" "Web_server" {
  ami    = "ami-00beae93a2d981137"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

 tags = {
    Name = "Test Instance"
  }
}