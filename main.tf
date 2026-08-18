resource "aws_vpc" "main" {
   cidr_block = var.vpc_cidr
   enable_dns_support = true
   enable_dns_hostnames = true

   tags = {
      Name = "hug-terraform-vpc"
   }
}

resource "aws_subnet" "public_subnet" {
   vpc_id = aws_vpc.main.id
   cidr_block = var.public_subnet_cidr
   map_public_ip_on_launch = true

   tags = {
      Name = "hug-terraform-public-subnet"
   }
}

resource "aws_internet_gateway" "igw" {
   vpc_id = aws_vpc.main.id

   tags = {
      Name = "hug-terraform-igw"
   }
}

resource "aws_route_table" "public_rt" {
   vpc_id = aws_vpc.main.id

   route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
   }

   tags = {
      Name = "hug-terraform-public-rt"
   }
}

resource "aws_route_table_association" "public_rt_association" {
   subnet_id = aws_subnet.public_subnet.id
   route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
   name = "hug-terraform-web-sg"
   description = "Allow SSH and HTTP"
   vpc_id = aws_vpc.main.id

   ingress {
      description = "SSH"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
      description = "HTTP"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
      Name = "hug-terraform-web-sg"
   }
}

data "aws_ami" "ubuntu" {
   most_recent = true
   owners = ["099720109477"]

   filter {
      name = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
   }
}

locals {
   user_data = <<-EOF
      #!/bin/bash
      apt-get update -y
      apt-get install -y nginx
      cat <<'HTML' > /var/www/html/index.html
      <html>
         <head><title>HUG Terraform Challenge 1</title></head>
         <body>
           <h1>Samuel Evi Udueya</h1>
           <h2>HUG Lagos/Ibadan Terraform Challenge</h2>
         </body>
      </html>
      HTML
      systemctl enable nginx
      systemctl start nginx
   EOF
}

resource "aws_instance" "web" {
   ami = data.aws_ami.ubuntu.id
   instance_type = var.instance_type
   subnet_id = aws_subnet.public_subnet.id
   vpc_security_group_ids = [aws_security_group.web_sg.id]
   user_data = local.user_data

   tags = {
      Name = "hug-terraform-web-instance"
   }
}
