terraform {
	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = "~> 3.0"
		}
	}
}

provider "aws" {
	region		= var.region
	profile		= "arthur-bryan"
}

resource "aws_vpc" "main" {
	cidr_block				= "10.50.0.0/16"
    enable_dns_hostnames	= true
    enable_dns_support		= true

	tags = var.app_tags
}

resource "aws_internet_gateway" "main" {
	vpc_id	= aws_vpc.main.id

	tags	=var.app_tags
}


resource "aws_subnet" "main" {
	vpc_id			   		= aws_vpc.main.id
	cidr_block         		= "10.50.22.0/24"
	availability_zone  		= var.availability_zone
	map_public_ip_on_launch = "true"


    tags					= var.app_tags
}

resource "aws_route_table" "main" {
	vpc_id			= aws_vpc.main.id
	route {
		cidr_block	= "0.0.0.0/0"
		gateway_id	= aws_internet_gateway.main.id
	}

	tags			= var.app_tags
}


resource "aws_route_table_association" "main" {
	subnet_id      = aws_subnet.main.id
	route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "main" {
	name        = "Allow RDP and WinRM inbound"
	vpc_id      = aws_vpc.main.id
	description = "Allow RDP and WinRM inbound traffic"

	ingress {
		from_port   = 3389
		to_port     = 3389
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
		from_port   = 5985
		to_port     = 5985
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = var.app_tags
}


resource "aws_network_interface" "main" {
	subnet_id			= aws_subnet.main.id
	private_ips			= ["${var.private_ip_address}"]
	security_groups		= [aws_security_group.main.id]

	tags				= var.app_tags
}


resource "tls_private_key" "main" {
	algorithm = "RSA"
	rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
	key_name	= "key-${var.vm_instance_name}"
	public_key	= tls_private_key.main.public_key_openssh

	tags		= var.app_tags
}

data "template_file" "main" {
	template = "${file("allow_ansible.txt")}"
}

resource "local_file" "main" {
	content  = "${data.template_file.main.rendered}"
	filename = "user_data-${sha1(data.template_file.main.rendered)}.ps"
}

resource "aws_instance" "main" {
	ami           			= "ami-00090b5fc7dd8d34b"
	instance_type			= "t2.large"
	availability_zone		= var.availability_zone
	key_name   				= aws_key_pair.main.key_name
	user_data				= "${local_file.main.content}"

	network_interface {
		network_interface_id = aws_network_interface.main.id
		device_index         = 0
	}


    tags = var.instance_tags
}
