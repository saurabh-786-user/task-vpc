

resource "aws_vpc" "vpc" {
  cidr_block = var.public.vpc

  tags = {
    Name = var.aws_vpc
  }
}

resource "aws_subnet" "public-1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public.public-1

  tags = {
    Name = "public-sub-1"
  }
}

resource "aws_subnet" "public-2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public.public-2

  tags = {
    Name = "public-subnet-2"
  }

}

resource "aws_subnet" "private-1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public.private-1

  tags = {
    Name = "private-subnet-1"
  }

}
resource "aws_subnet" "private-2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public.private-2

  tags = {
    Name = "private-subnet-2"
  }

}
resource "aws_subnet" "private-3" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public.private-3

  tags = {
    Name = "private-subnet-3"
  }

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.aws_internet_gateway
  }

}

resource "aws_route_table" "route-vpc" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.public.route
    gateway_id = aws_internet_gateway.igw.id

  }
}
resource "aws_route_table_association" "route1" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.route-vpc.id
}

resource "aws_route_table_association" "route2" {
  subnet_id      = aws_subnet.public-2.id
  route_table_id = aws_route_table.route-vpc.id
}


resource "aws_instance" "saurabh" {
  ami                         = "ami-078a289ddf4b09ae0"
  instance_type               = "t3.nano"
  key_name                    = aws_key_pair.saurabh-key.id
  security_groups             = [aws_security_group.saurabh-sg.id]
  subnet_id                   = aws_subnet.public-1.id
  associate_public_ip_address = true
  tags = {
    Name = var.aws_instance
  }

  user_data = <<EOF
		#! /bin/bash
    sudo apt-get update
		sudo apt-get install -y apache2
		sudo systemctl start apache2
		sudo systemctl enable apache2
		echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
	EOF

}
resource "tls_private_key" "saurabh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "saurabh-key" {
  key_name   = "saurabh-key"
  public_key = tls_private_key.saurabh-key.public_key_openssh
}

resource "aws_security_group" "saurabh-sg" {
  name        = "saurabh-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
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
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sk"
  }
}
 