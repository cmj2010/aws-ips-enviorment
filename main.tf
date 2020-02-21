provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_vpc" "terraformvpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terraformvpc.id
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-vpc"
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.terraformvpc.id
  cidr_block        = var.public_subnet_cidr1
  availability_zone = var.availability_zone1
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-public-subnet1"
  }
}


resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.terraformvpc.id
  cidr_block        = var.private_subnet_cidr1
  availability_zone = var.availability_zone1
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-private-subnet1"
  }
}



resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.terraformvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-public-rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.terraformvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_network_interface.eni1.id
  }
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-private-rt"
  }
}

resource "aws_route_table_association" "public_rt_association1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_association1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "secgrp" {
  name        = "${var.tag_name_prefix}-fgt${var.tag_name_unique}-secgrp"
  description = "secgrp"
  vpc_id      = aws_vpc.terraformvpc.id
  ingress {
    description = "Allow remote access to FGT"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.tag_name_prefix}-fgt${var.tag_name_unique}-secgrp"
  }
}

resource "aws_network_interface" "eni0" {
  subnet_id         = aws_subnet.public_subnet1.id
  security_groups   = [aws_security_group.secgrp.id]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt${var.tag_name_unique}-eni0"
  }
}

resource "aws_network_interface" "eni1" {
  subnet_id         = aws_subnet.private_subnet1.id
  security_groups   = [aws_security_group.secgrp.id]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt${var.tag_name_unique}-eni1"
  }
}


resource "aws_eip" "eip1" {
  vpc               = true
  network_interface = aws_network_interface.eni0.id
  tags = {
    Name = "${var.tag_name_prefix}-fgt${var.tag_name_unique}-eip"
  }
}


resource "aws_instance" "fgt" {
  ami               = "ami-0673ab1b3858bc422"
  instance_type     = "c5.large"
  availability_zone = var.availability_zone1
  key_name          = var.keypair
  user_data         = data.template_file.fgt_userdata.rendered
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.eni0.id
  }
  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.eni1.id
  }
  tags = {
    Name = "${var.tag_name_prefix}-fgt${var.tag_name_unique}"
  }
}
data "template_file" "fgt_userdata" {
  template = file("./fgt-userdata.tpl")

  vars = {
    fgt_byol_license = file("${path.root}/${var.fgt_byol_license}")
    fgt_id           = "fgt-ips"
    port1            = aws_network_interface.eni0.private_ip
    port2            = aws_network_interface.eni1.private_ip
    ubuntuip         = aws_network_interface.eni2.private_ip

  }
}

resource "aws_network_interface" "eni2" {
  subnet_id         = aws_subnet.private_subnet1.id
  security_groups   = [aws_security_group.secgrp.id]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt${var.tag_name_unique}-eni2"
  }
}

resource "aws_instance" "ubuntu" {
  ami               = "ami-01d4e30d4d4952d0f"
  instance_type     = "c5.large"
  availability_zone = var.availability_zone1
  key_name          = var.keypair
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.eni2.id
  }
  tags = {
    Name = "${var.tag_name_prefix}-fgt${var.tag_name_unique}"
  }
}