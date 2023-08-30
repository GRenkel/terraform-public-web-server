provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}


resource "aws_vpc" "app-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "app-main-vpc"
  }
}

resource "aws_subnet" "public-subnet-a" {
  vpc_id                  = aws_vpc.app-vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-a"
  }
}

resource "aws_route_table_association" "pub_a-to-pub_route" {
  subnet_id      = aws_subnet.public-subnet-a.id
  route_table_id = aws_route_table.public-route.id
}

resource "aws_subnet" "private-subnet-a" {
  vpc_id            = aws_vpc.app-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet-a"
  }
}

resource "aws_route_table_association" "pv_a-to-pv_route" {
  subnet_id      = aws_subnet.private-subnet-a.id
  route_table_id = aws_route_table.private-route.id
}

resource "aws_internet_gateway" "app-igw" {
  vpc_id = aws_vpc.app-vpc.id

  tags = {
    Name = "app-igw"
  }
}

resource "aws_egress_only_internet_gateway" "egress-igw" {
  vpc_id = aws_vpc.app-vpc.id

  tags = {
    Name = "eggress-only-igw"
  }
}

resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.app-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app-igw.id
  }

  tags = {
    Name = "app-public-router"
  }
}

resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.app-vpc.id

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.egress-igw.id
  }
  tags = {
    Name = "app-private-router"
  }
}

resource "aws_security_group" "web-sg" {
  name        = "web-sg"
  description = "Allow public trafic"
  vpc_id      = aws_vpc.app-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = [aws_subnet.public-subnet-a.cidr_block]
    # ipv6_cidr_blocks = [aws_subnet.public-subnet-a.ipv6_cidr_block]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = [aws_subnet.public-subnet-a.cidr_block]
    # ipv6_cidr_blocks = [aws_subnet.public-subnet-a.ipv6_cidr_block]
  }


  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = [aws_subnet.public-subnet-a.cidr_block]
    # ipv6_cidr_blocks = [aws_subnet.public-subnet-a.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow-web-http"
  }
}

resource "aws_network_interface" "web-eni" {
  subnet_id       = aws_subnet.public-subnet-a.id
  private_ips     = ["10.0.0.10"]
  security_groups = [aws_security_group.web-sg.id]
}

resource "aws_eip" "web-eip" {
  network_interface         = aws_network_interface.web-eni.id
  associate_with_private_ip = "10.0.0.10"
  depends_on                = [aws_internet_gateway.app-igw, aws_instance.web-app]
}

resource "aws_instance" "web-app" {
  ami               = "ami-053b0d53c279acc90"
  availability_zone = "us-east-1a"
  instance_type     = "t2.micro"
  key_name          = "terraform"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-eni.id
  }
  user_data = <<-EOF
                  #!/bin/bash
                  sudo apt update -y
                  sudo apt install apache2 -y
                  sudo systemctl start apache2
                  sudo bash -c 'echo here we go > /var/www/html/index.html'
                  EOF
  tags = {
    Name = "web-app"
  }
} 
